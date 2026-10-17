//
//  PlaySession.swift
//  Conecta CAM
//

import Foundation

struct PlaySession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var gameID: String
    var players: [String]
}
