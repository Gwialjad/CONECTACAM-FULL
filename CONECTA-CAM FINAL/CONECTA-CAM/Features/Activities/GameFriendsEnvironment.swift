//
//  GameFriendsEnvironment.swift
//  Conecta CAM
//

import SwiftUI

private struct GameFriendsKey: EnvironmentKey {
    static let defaultValue: [Friend] = []
}

extension EnvironmentValues {
    /// Personajes de los jugadores de la partida actual, en el mismo orden que `players`.
    /// En cualquier juego: `@Environment(\.gameFriends) private var friends`
    /// y luego `friends[i]` es el personaje de `players[i]`.
    var gameFriends: [Friend] {
        get { self[GameFriendsKey.self] }
        set { self[GameFriendsKey.self] = newValue }
    }
}
