//
//  Friend.swift
//  Conecta CAM
//

import Foundation

/// Un personaje que el alumno puede elegir en la pantalla "Elige a tu amigo".
/// La imagen vive en Assets.xcassets con el nombre "char_<id>".
struct Friend: Identifiable, Hashable {
    let id: String      // se guarda en Profile.avatar
    let name: String    // nombre en español (también lo lee VoiceOver)
    var imageName: String { "char_\(id)" }

    static let all: [Friend] = [
        Friend(id: "oveja", name: "Oveja"),
        Friend(id: "caracol", name: "Caracol"),
        Friend(id: "pulpo", name: "Pulpo"),
        Friend(id: "abeja", name: "Abeja"),
        Friend(id: "elefante", name: "Elefante"),
        Friend(id: "tortuga", name: "Tortuga"),
        Friend(id: "cerdito", name: "Cerdito"),
        Friend(id: "rana", name: "Rana"),
        Friend(id: "gato", name: "Gato"),
        Friend(id: "jirafa", name: "Jirafa"),
        Friend(id: "dino", name: "Dino"),
        Friend(id: "koala", name: "Koala")
    ]

    /// Busca por id. Si no existe (por ejemplo, un perfil guardado con el emoji viejo),
    /// devuelve la Oveja para que nunca falte un personaje.
    static func with(id: String) -> Friend {
        all.first { $0.id == id } ?? all[0]
    }
}
