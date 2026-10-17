//
//  AppStore.swift
//  Conecta CAM
//

import SwiftUI
import Combine

// MARK: - Almacenamiento y lógica de rachas/metas

final class AppStore: ObservableObject {
    @Published var profile = Profile() { didSet { save() } }
    @Published var entries: [DiaryEntry] = [] { didSet { save() } }
    @Published var sessions: [PlaySession] = [] { didSet { save() } }
    @Published var goals = Goals() { didSet { save() } }
    private(set) var startDate = Calendar.current.startOfDay(for: Date())

    private struct Snapshot: Codable {
        var profile: Profile
        var entries: [DiaryEntry]
        var sessions: [PlaySession]
        var goals: Goals
        var startDate: Date
    }

    private let key = "conectacam.snapshot.v1"
    private var loading = true

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let snap = try? JSONDecoder().decode(Snapshot.self, from: data) {
            profile = snap.profile
            entries = snap.entries
            sessions = snap.sessions
            goals = snap.goals
            startDate = snap.startDate
        }
        loading = false
        save()
    }

    private func save() {
        guard !loading else { return }
        let snap = Snapshot(profile: profile, entries: entries, sessions: sessions,
                            goals: goals, startDate: startDate)
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // Diario
    func dayNumber(for date: Date = Date()) -> Int {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: startDate, to: cal.startOfDay(for: date)).day ?? 0
        return max(days, 0) + 1
    }

    func entry(forDay day: Int) -> DiaryEntry? {
        entries.first { $0.dayNumber == day }
    }

    func saveEntry(day: Int, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let i = entries.firstIndex(where: { $0.dayNumber == day }) {
            if trimmed.isEmpty { entries.remove(at: i) } else { entries[i].text = text }
        } else if !trimmed.isEmpty {
            entries.append(DiaryEntry(dayNumber: day, date: Date(), text: text))
        }
    }

    // Juegos
    func logSession(game: Game, players: [String]) {
        sessions.append(PlaySession(date: Date(), gameID: game.rawValue, players: players))
    }

    // Métricas para metas
    var peopleCount: Int {
        let me = profile.name.lowercased()
        var others = Set<String>()
        for s in sessions {
            for p in s.players where p.lowercased() != me { others.insert(p.lowercased()) }
        }
        return others.count
    }

    var groupsCount: Int { sessions.filter { $0.players.count >= 3 }.count }

    /// Días con actividad (diario o juego) en los últimos 7 días.
    var weekStreak: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let from = cal.date(byAdding: .day, value: -6, to: today) else { return 0 }
        var days = Set<Date>()
        for e in entries { days.insert(cal.startOfDay(for: e.date)) }
        for s in sessions { days.insert(cal.startOfDay(for: s.date)) }
        return days.filter { $0 >= from && $0 <= today }.count
    }
}
