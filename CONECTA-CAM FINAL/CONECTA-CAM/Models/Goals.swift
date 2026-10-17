//
//  Goals.swift
//  Conecta CAM
//

import Foundation

struct Goals: Codable, Equatable {
    var people: Int = 5   // personas con las que jugar
    var streak: Int = 7   // días activos en la semana
    var groups: Int = 3   // partidas de 3 o más personas
}
