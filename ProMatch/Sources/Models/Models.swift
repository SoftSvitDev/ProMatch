import UIKit

struct Team {
    var name: String
    var city: String
    var foundedYear: Int?
    var initials: String
    var color: UIColor
    var wins: Int
    var draws: Int
    var losses: Int
    var players: [Player]
    var notes: String?

    var playerCountText: String { "\(players.count) players" }
}

struct Player {
    var firstName: String
    var lastName: String
    var nickname: String?
    var jerseyNumber: Int
    var position: Position
    var preferredFoot: Foot
    var heightCm: Int?
    var weightKg: Int?

    var initials: String {
        let f = firstName.first.map { String($0) } ?? ""
        let l = lastName.first.map { String($0) } ?? ""
        return (f + l).uppercased()
    }
    var fullName: String { "\(firstName) \(lastName)" }
}

enum Position: String, CaseIterable {
    case GK, LB, CB, RB, LM, CM, RM, LW, ST, RW
}

enum Foot: String, CaseIterable {
    case left = "Left", right = "Right", both = "Both"
}

struct Tournament {
    enum Status { case live, scheduled, completed }
    enum Format: String { case roundRobin = "Round-Robin", knockout = "Knockout", groupsPlayoffs = "Groups + Playoffs" }
    var name: String
    var format: Format
    var status: Status
    var teamCount: Int
    var matchesPlayed: Int
    var remaining: Int
    var date: String
}

struct StandingRow {
    var position: Int
    var team: String
    var played: Int
    var won: Int
    var drawn: Int
    var lost: Int
    var goalsFor: Int
    var goalsAgainst: Int
    var goalDiff: Int
    var points: Int
}

struct MatchResult {
    var home: String
    var away: String
    var homeScore: Int
    var awayScore: Int
}

struct UpcomingMatch {
    var home: String
    var away: String
    var time: String
}

struct ScorerEntry {
    var team: String
    var goals: Int
}

enum SampleData {
    static let teams: [Team] = [
        Team(name: "FC Predators", city: "Manchester", foundedYear: 2018, initials: "FP",
             color: Theme.Color.pillRed, wins: 8, draws: 3, losses: 2, players: predatorRoster, notes: nil),
        Team(name: "Sky Blues", city: "London", foundedYear: 2019, initials: "SB",
             color: Theme.Color.pillBlue, wins: 6, draws: 4, losses: 3, players: [], notes: nil),
        Team(name: "Green Hornets", city: "Birmingham", foundedYear: 2017, initials: "GH",
             color: Theme.Color.pillGreen, wins: 4, draws: 2, losses: 7, players: [], notes: nil),
    ]

    static let predatorRoster: [Player] = [
        Player(firstName: "Marcus", lastName: "Johnson", nickname: nil, jerseyNumber: 9, position: .ST, preferredFoot: .right, heightCm: 182, weightKg: 78),
        Player(firstName: "Kyle", lastName: "Reeves", nickname: nil, jerseyNumber: 1, position: .GK, preferredFoot: .right, heightCm: 188, weightKg: 82),
        Player(firstName: "James", lastName: "Ortega", nickname: nil, jerseyNumber: 5, position: .CB, preferredFoot: .left, heightCm: 186, weightKg: 80),
        Player(firstName: "Tyler", lastName: "Chen", nickname: nil, jerseyNumber: 10, position: .CM, preferredFoot: .right, heightCm: 178, weightKg: 74),
        Player(firstName: "Diego", lastName: "Morales", nickname: nil, jerseyNumber: 7, position: .LW, preferredFoot: .right, heightCm: 175, weightKg: 70),
        Player(firstName: "Aaron", lastName: "Blake", nickname: nil, jerseyNumber: 3, position: .LB, preferredFoot: .left, heightCm: 180, weightKg: 76),
    ]

    static let tournaments: [Tournament] = [
        Tournament(name: "City Cup 2026", format: .roundRobin, status: .live, teamCount: 4, matchesPlayed: 4, remaining: 2, date: "2026-04"),
        Tournament(name: "Summer League", format: .groupsPlayoffs, status: .scheduled, teamCount: 4, matchesPlayed: 0, remaining: 0, date: "2026-07"),
        Tournament(name: "Winter Cup 2025", format: .knockout, status: .completed, teamCount: 8, matchesPlayed: 7, remaining: 0, date: "2025-12"),
    ]

    static let standings: [StandingRow] = [
        StandingRow(position: 1, team: "FC Predators", played: 2, won: 2, drawn: 0, lost: 0, goalsFor: 3, goalsAgainst: 2, goalDiff: 1, points: 6),
        StandingRow(position: 2, team: "Sky Blues", played: 2, won: 1, drawn: 1, lost: 0, goalsFor: 3, goalsAgainst: 2, goalDiff: 1, points: 4),
        StandingRow(position: 3, team: "Green Hornets", played: 2, won: 0, drawn: 1, lost: 1, goalsFor: 1, goalsAgainst: 4, goalDiff: -3, points: 1),
        StandingRow(position: 4, team: "Red Devils", played: 2, won: 0, drawn: 0, lost: 2, goalsFor: 1, goalsAgainst: 4, goalDiff: -3, points: 1),
    ]

    static let results: [MatchResult] = [
        MatchResult(home: "FC Predators", away: "Sky Blues", homeScore: 2, awayScore: 1),
        MatchResult(home: "Green Hornets", away: "Red Devils", homeScore: 1, awayScore: 1),
        MatchResult(home: "Sky Blues", away: "Green Hornets", homeScore: 2, awayScore: 0),
        MatchResult(home: "Red Devils", away: "FC Predators", homeScore: 0, awayScore: 3),
    ]

    static let upcoming: [UpcomingMatch] = [
        UpcomingMatch(home: "FC Predators", away: "Green Hornets", time: "05:20"),
        UpcomingMatch(home: "Sky Blues", away: "Red Devils", time: "05:20"),
    ]

    static let scorers: [ScorerEntry] = [
        ScorerEntry(team: "FC Predators", goals: 5),
        ScorerEntry(team: "Sky Blues", goals: 3),
        ScorerEntry(team: "Green Hornets", goals: 1),
        ScorerEntry(team: "Red Devils", goals: 1),
    ]
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
