//
//  Profile.swift
//  Conecta CAM
//

import Foundation

struct Profile: Codable {
    var name: String = "Alumno"
    /// Id del personaje elegido (ver Friend.swift). Ej: "oveja", "koala".
    var avatar: String = "oveja"
}
