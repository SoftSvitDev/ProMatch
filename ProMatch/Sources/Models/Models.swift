import UIKit

struct Team: Codable, Identifiable {
    let id: UUID
    var name: String
    var city: String
    var foundedYear: Int?
    var initials: String
    var primaryColorHex: UInt32
    var secondaryColorHex: UInt32
    var players: [Player]
    var notes: String?
    var logoFilename: String?

    init(id: UUID = UUID(),
         name: String,
         city: String,
         foundedYear: Int? = nil,
         initials: String,
         primaryColorHex: UInt32,
         secondaryColorHex: UInt32,
         players: [Player] = [],
         notes: String? = nil,
         logoFilename: String? = nil) {
        self.id = id
        self.name = name
        self.city = city
        self.foundedYear = foundedYear
        self.initials = initials
        self.primaryColorHex = primaryColorHex
        self.secondaryColorHex = secondaryColorHex
        self.players = players
        self.notes = notes
        self.logoFilename = logoFilename
    }

    var color: UIColor { UIColor(hex: primaryColorHex) }
    var secondaryColor: UIColor { UIColor(hex: secondaryColorHex) }
    var playerCountText: String { "\(players.count) \(players.count == 1 ? "player" : "players")" }
}

struct Player: Codable, Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var nickname: String?
    var jerseyNumber: Int
    var position: Position
    var preferredFoot: Foot
    var birthDate: Date?
    var heightCm: Int?
    var weightKg: Int?

    init(id: UUID = UUID(),
         firstName: String,
         lastName: String,
         nickname: String? = nil,
         jerseyNumber: Int,
         position: Position,
         preferredFoot: Foot,
         birthDate: Date? = nil,
         heightCm: Int? = nil,
         weightKg: Int? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.jerseyNumber = jerseyNumber
        self.position = position
        self.preferredFoot = preferredFoot
        self.birthDate = birthDate
        self.heightCm = heightCm
        self.weightKg = weightKg
    }

    var initials: String {
        let f = firstName.first.map { String($0) } ?? ""
        let l = lastName.first.map { String($0) } ?? ""
        return (f + l).uppercased()
    }
    var fullName: String { "\(firstName) \(lastName)" }
}

enum Position: String, CaseIterable, Codable {
    case GK, LB, CB, RB, LM, CM, RM, LW, ST, RW
}

enum Foot: String, CaseIterable, Codable {
    case left = "Left", right = "Right", both = "Both"
}

struct Tournament: Codable, Identifiable {
    enum Format: String, Codable, CaseIterable {
        case roundRobin = "Round-Robin"
        case knockout = "Knockout"
        case groupsPlayoffs = "Groups + Playoffs"
    }
    enum Tiebreaker: String, Codable, CaseIterable {
        case goalDifference = "Goal Difference"
        case headToHead = "Head-to-Head"
        case goalsScored = "Goals Scored"
        case coinToss = "Coin Toss"
    }
    enum Status { case live, scheduled, completed }

    let id: UUID
    var name: String
    var format: Format
    var startDate: Date?
    var endDate: Date?
    var teamIds: [UUID]
    var matchDurationMin: Int
    var pointsWin: Int
    var pointsDraw: Int
    var pointsLoss: Int
    var tiebreaker: Tiebreaker
    var matches: [Match]
    var createdAt: Date

    init(id: UUID = UUID(),
         name: String,
         format: Format,
         startDate: Date? = nil,
         endDate: Date? = nil,
         teamIds: [UUID],
         matchDurationMin: Int = 90,
         pointsWin: Int = 3,
         pointsDraw: Int = 1,
         pointsLoss: Int = 0,
         tiebreaker: Tiebreaker = .goalDifference,
         matches: [Match] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.format = format
        self.startDate = startDate
        self.endDate = endDate
        self.teamIds = teamIds
        self.matchDurationMin = matchDurationMin
        self.pointsWin = pointsWin
        self.pointsDraw = pointsDraw
        self.pointsLoss = pointsLoss
        self.tiebreaker = tiebreaker
        self.matches = matches
        self.createdAt = createdAt
    }

    var status: Status {
        if matches.isEmpty { return .scheduled }
        let played = matches.filter { $0.isPlayed }.count
        if played == 0 { return .scheduled }
        if played == matches.count { return .completed }
        return .live
    }
    var matchesPlayed: Int { matches.filter { $0.isPlayed }.count }
    var matchesRemaining: Int { matches.filter { !$0.isPlayed }.count }
    var dateText: String {
        if let d = startDate {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM"
            return f.string(from: d)
        }
        return ""
    }
}

struct Goal: Codable, Identifiable {
    let id: UUID
    var playerId: UUID
    var teamId: UUID

    init(id: UUID = UUID(), playerId: UUID, teamId: UUID) {
        self.id = id
        self.playerId = playerId
        self.teamId = teamId
    }
}

struct Match: Codable, Identifiable {
    let id: UUID
    var homeTeamId: UUID
    var awayTeamId: UUID
    var homeScore: Int?
    var awayScore: Int?
    var scheduledTime: String?
    var round: Int
    var goals: [Goal]

    init(id: UUID = UUID(),
         homeTeamId: UUID,
         awayTeamId: UUID,
         homeScore: Int? = nil,
         awayScore: Int? = nil,
         scheduledTime: String? = nil,
         round: Int = 1,
         goals: [Goal] = []) {
        self.id = id
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.scheduledTime = scheduledTime
        self.round = round
        self.goals = goals
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        homeTeamId = try c.decode(UUID.self, forKey: .homeTeamId)
        awayTeamId = try c.decode(UUID.self, forKey: .awayTeamId)
        homeScore = try c.decodeIfPresent(Int.self, forKey: .homeScore)
        awayScore = try c.decodeIfPresent(Int.self, forKey: .awayScore)
        scheduledTime = try c.decodeIfPresent(String.self, forKey: .scheduledTime)
        round = (try? c.decode(Int.self, forKey: .round)) ?? 1
        goals = (try? c.decode([Goal].self, forKey: .goals)) ?? []
    }

    var isPlayed: Bool { homeScore != nil && awayScore != nil }
    var winnerId: UUID? {
        guard let h = homeScore, let a = awayScore else { return nil }
        if h > a { return homeTeamId }
        if a > h { return awayTeamId }
        return nil
    }

    func goalCount(for teamId: UUID) -> Int {
        goals.filter { $0.teamId == teamId }.count
    }

    func goalCount(for playerId: UUID, teamId: UUID) -> Int {
        goals.filter { $0.playerId == playerId && $0.teamId == teamId }.count
    }
}

struct StandingRow {
    var position: Int
    var teamId: UUID
    var teamName: String
    var played: Int
    var won: Int
    var drawn: Int
    var lost: Int
    var goalsFor: Int
    var goalsAgainst: Int
    var goalDiff: Int { goalsFor - goalsAgainst }
    var points: Int
}

extension Position {
    var pillColor: UIColor {
        switch self {
        case .GK: return Theme.Color.pillOrange
        case .CB, .LB, .RB: return Theme.Color.pillCyan
        case .CM, .LM, .RM: return Theme.Color.pillGreen
        case .LW, .RW: return Theme.Color.pillBlue
        case .ST: return Theme.Color.pillRed
        }
    }
}

extension Team {
    func record(in tournaments: [Tournament]) -> (wins: Int, draws: Int, losses: Int) {
        var w = 0, d = 0, l = 0
        for t in tournaments {
            for m in t.matches where m.isPlayed {
                guard let hs = m.homeScore, let as_ = m.awayScore else { continue }
                if m.homeTeamId == id {
                    if hs > as_ { w += 1 }
                    else if hs == as_ { d += 1 }
                    else { l += 1 }
                } else if m.awayTeamId == id {
                    if as_ > hs { w += 1 }
                    else if as_ == hs { d += 1 }
                    else { l += 1 }
                }
            }
        }
        return (w, d, l)
    }
}
