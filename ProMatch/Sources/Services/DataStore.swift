import UIKit

extension Notification.Name {
    static let teamsDidChange = Notification.Name("DataStore.teamsDidChange")
    static let tournamentsDidChange = Notification.Name("DataStore.tournamentsDidChange")
}

final class DataStore {
    static let shared = DataStore()

    private enum Keys {
        static let teams = "datastore.teams.v1"
        static let tournaments = "datastore.tournaments.v1"
    }

    private let defaults = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private(set) var teams: [Team] = []
    private(set) var tournaments: [Tournament] = []

    private init() {
        load()
        ensureLogosDirectory()
        backfillMissingMatches()
    }

    private func backfillMissingMatches() {
        var changed = false
        for i in tournaments.indices where tournaments[i].matches.isEmpty {
            tournaments[i].matches = generateInitialMatches(for: tournaments[i])
            changed = changed || !tournaments[i].matches.isEmpty
        }
        if changed { saveTournaments() }
    }

    // MARK: - Logos

    private lazy var logosDir: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("team_logos", isDirectory: true)
    }()

    private func ensureLogosDirectory() {
        try? FileManager.default.createDirectory(at: logosDir, withIntermediateDirectories: true)
    }

    @discardableResult
    func saveTeamLogo(_ image: UIImage, for teamId: UUID) -> String? {
        let resized = image.resizedForLogo()
        guard let data = resized.jpegData(compressionQuality: 0.85) else { return nil }
        let filename = "\(teamId.uuidString).jpg"
        let url = logosDir.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    func loadTeamLogo(filename: String) -> UIImage? {
        let url = logosDir.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func deleteTeamLogo(filename: String) {
        let url = logosDir.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Load / Save

    private func load() {
        if let data = defaults.data(forKey: Keys.teams),
           let decoded = try? decoder.decode([Team].self, from: data) {
            teams = decoded
        }
        if let data = defaults.data(forKey: Keys.tournaments),
           let decoded = try? decoder.decode([Tournament].self, from: data) {
            tournaments = decoded
        }
    }

    private func saveTeams() {
        if let data = try? encoder.encode(teams) {
            defaults.set(data, forKey: Keys.teams)
        }
        NotificationCenter.default.post(name: .teamsDidChange, object: nil)
    }

    private func saveTournaments() {
        if let data = try? encoder.encode(tournaments) {
            defaults.set(data, forKey: Keys.tournaments)
        }
        NotificationCenter.default.post(name: .tournamentsDidChange, object: nil)
    }

    // MARK: - Teams

    func addTeam(_ team: Team) {
        teams.append(team)
        saveTeams()
    }

    func updateTeam(_ team: Team) {
        guard let idx = teams.firstIndex(where: { $0.id == team.id }) else { return }
        teams[idx] = team
        saveTeams()
    }

    func deleteTeam(id: UUID) {
        if let team = teams.first(where: { $0.id == id }),
           let filename = team.logoFilename {
            deleteTeamLogo(filename: filename)
        }
        teams.removeAll { $0.id == id }
        for i in tournaments.indices {
            tournaments[i].teamIds.removeAll { $0 == id }
            tournaments[i].matches.removeAll { $0.homeTeamId == id || $0.awayTeamId == id }
        }
        saveTeams()
        saveTournaments()
    }

    func team(id: UUID) -> Team? {
        teams.first { $0.id == id }
    }

    func teamLogo(for team: Team) -> UIImage? {
        guard let filename = team.logoFilename else { return nil }
        return loadTeamLogo(filename: filename)
    }

    // MARK: - Players

    func addPlayer(_ player: Player, toTeam teamId: UUID) {
        guard let idx = teams.firstIndex(where: { $0.id == teamId }) else { return }
        teams[idx].players.append(player)
        saveTeams()
    }

    func removePlayer(playerId: UUID, fromTeam teamId: UUID) {
        guard let idx = teams.firstIndex(where: { $0.id == teamId }) else { return }
        teams[idx].players.removeAll { $0.id == playerId }
        saveTeams()
    }

    // MARK: - Tournaments

    func addTournament(_ tournament: Tournament) {
        var t = tournament
        if t.matches.isEmpty {
            t.matches = generateInitialMatches(for: t)
        }
        tournaments.append(t)
        saveTournaments()
    }

    private func generateInitialMatches(for tournament: Tournament) -> [Match] {
        switch tournament.format {
        case .roundRobin:
            return generateRoundRobin(teamIds: tournament.teamIds)
        case .knockout:
            return generateKnockoutRound(teamIds: tournament.teamIds, round: 1)
        case .groupsPlayoffs:
            // No proper group-stage UI yet — fall back to round-robin among all teams.
            return generateRoundRobin(teamIds: tournament.teamIds)
        }
    }

    func updateTournament(_ tournament: Tournament) {
        guard let idx = tournaments.firstIndex(where: { $0.id == tournament.id }) else { return }
        tournaments[idx] = tournament
        saveTournaments()
    }

    func deleteTournament(id: UUID) {
        tournaments.removeAll { $0.id == id }
        saveTournaments()
    }

    func tournament(id: UUID) -> Tournament? {
        tournaments.first { $0.id == id }
    }

    func recordScore(tournamentId: UUID, matchId: UUID, home: Int, away: Int) {
        recordMatch(tournamentId: tournamentId, matchId: matchId, home: home, away: away, goals: nil)
    }

    func recordMatch(tournamentId: UUID, matchId: UUID, home: Int, away: Int, goals: [Goal]?) {
        guard let tIdx = tournaments.firstIndex(where: { $0.id == tournamentId }) else { return }
        guard let mIdx = tournaments[tIdx].matches.firstIndex(where: { $0.id == matchId }) else { return }
        tournaments[tIdx].matches[mIdx].homeScore = home
        tournaments[tIdx].matches[mIdx].awayScore = away
        if let goals { tournaments[tIdx].matches[mIdx].goals = goals }
        advanceKnockoutIfNeeded(tournamentIdx: tIdx)
        saveTournaments()
    }

    private func advanceKnockoutIfNeeded(tournamentIdx: Int) {
        let t = tournaments[tournamentIdx]
        guard t.format == .knockout else { return }
        let currentRound = t.matches.map { $0.round }.max() ?? 1
        let currentMatches = t.matches.filter { $0.round == currentRound }
        guard !currentMatches.isEmpty,
              currentMatches.allSatisfy({ $0.isPlayed }) else { return }
        let winners = currentMatches.compactMap { $0.winnerId }
        // If any current match was a draw, can't advance — winner is unresolved.
        guard winners.count == currentMatches.count else { return }
        // Include teams that had a bye in this round.
        let teamsInCurrent = Set(currentMatches.flatMap { [$0.homeTeamId, $0.awayTeamId] })
        let priorParticipants = teamsAt(round: currentRound, in: t)
        let byeAdvances = priorParticipants.subtracting(teamsInCurrent)
        let advancing = winners + Array(byeAdvances)
        guard advancing.count > 1 else { return }
        let next = generateKnockoutRound(teamIds: advancing, round: currentRound + 1)
        tournaments[tournamentIdx].matches.append(contentsOf: next)
    }

    private func teamsAt(round: Int, in tournament: Tournament) -> Set<UUID> {
        if round == 1 { return Set(tournament.teamIds) }
        // Teams in round R = winners of round R-1 ∪ byes of round R-1.
        let prev = tournament.matches.filter { $0.round == round - 1 }
        let prevTeams = Set(prev.flatMap { [$0.homeTeamId, $0.awayTeamId] })
        let priorPool = teamsAt(round: round - 1, in: tournament)
        let byeFromPrev = priorPool.subtracting(prevTeams)
        let winnersFromPrev = Set(prev.compactMap { $0.winnerId })
        return winnersFromPrev.union(byeFromPrev)
    }

    // MARK: - Round-Robin generation

    private func generateRoundRobin(teamIds: [UUID]) -> [Match] {
        var matches: [Match] = []
        for i in 0..<teamIds.count {
            for j in (i+1)..<teamIds.count {
                matches.append(Match(homeTeamId: teamIds[i], awayTeamId: teamIds[j], round: 1))
            }
        }
        return matches
    }

    private func generateKnockoutRound(teamIds: [UUID], round: Int) -> [Match] {
        let shuffled = round == 1 ? teamIds.shuffled() : teamIds
        var matches: [Match] = []
        var i = 0
        while i + 1 < shuffled.count {
            matches.append(Match(homeTeamId: shuffled[i], awayTeamId: shuffled[i+1], round: round))
            i += 2
        }
        return matches
    }

    // MARK: - Standings

    func standings(for tournament: Tournament) -> [StandingRow] {
        var rows: [UUID: StandingRow] = [:]
        for tid in tournament.teamIds {
            let name = team(id: tid)?.name ?? "—"
            rows[tid] = StandingRow(position: 0, teamId: tid, teamName: name,
                                    played: 0, won: 0, drawn: 0, lost: 0,
                                    goalsFor: 0, goalsAgainst: 0, points: 0)
        }
        for m in tournament.matches where m.isPlayed {
            guard let hs = m.homeScore, let as_ = m.awayScore else { continue }
            if var home = rows[m.homeTeamId] {
                home.played += 1
                home.goalsFor += hs
                home.goalsAgainst += as_
                if hs > as_ { home.won += 1; home.points += tournament.pointsWin }
                else if hs == as_ { home.drawn += 1; home.points += tournament.pointsDraw }
                else { home.lost += 1; home.points += tournament.pointsLoss }
                rows[m.homeTeamId] = home
            }
            if var away = rows[m.awayTeamId] {
                away.played += 1
                away.goalsFor += as_
                away.goalsAgainst += hs
                if as_ > hs { away.won += 1; away.points += tournament.pointsWin }
                else if as_ == hs { away.drawn += 1; away.points += tournament.pointsDraw }
                else { away.lost += 1; away.points += tournament.pointsLoss }
                rows[m.awayTeamId] = away
            }
        }
        var sorted = Array(rows.values).sorted { lhs, rhs in
            if lhs.points != rhs.points { return lhs.points > rhs.points }
            switch tournament.tiebreaker {
            case .goalDifference, .coinToss:
                if lhs.goalDiff != rhs.goalDiff { return lhs.goalDiff > rhs.goalDiff }
                return lhs.goalsFor > rhs.goalsFor
            case .goalsScored:
                return lhs.goalsFor > rhs.goalsFor
            case .headToHead:
                return lhs.goalDiff > rhs.goalDiff
            }
        }
        for i in sorted.indices { sorted[i].position = i + 1 }
        return sorted
    }

    func scorersByTeam(for tournament: Tournament) -> [(teamId: UUID, teamName: String, goals: Int)] {
        var counts: [UUID: Int] = [:]
        for m in tournament.matches where m.isPlayed {
            if let hs = m.homeScore { counts[m.homeTeamId, default: 0] += hs }
            if let as_ = m.awayScore { counts[m.awayTeamId, default: 0] += as_ }
        }
        return tournament.teamIds.map { tid in
            (tid, team(id: tid)?.name ?? "—", counts[tid, default: 0])
        }.sorted { $0.goals > $1.goals }
    }
}
