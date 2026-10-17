//
//  VoiceOverHelpers.swift
//  Conecta CAM
//

import SwiftUI

/// Anuncia un mensaje en voz alta con VoiceOver (por ejemplo, cambio de turno).
func announce(_ message: String) {
    AccessibilityNotification.Announcement(message).post()
}

/// Nombre hablado de cada personaje (VoiceOver leería el emoji de forma confusa).
let avatarNames: [String: String] = [
    "🦖": "Dinosaurio", "🐱": "Gato", "🐶": "Perro", "🦊": "Zorro",
    "🐼": "Panda", "🐸": "Rana", "🦄": "Unicornio", "🚀": "Cohete"
]
func avatarName(_ emoji: String) -> String { avatarNames[emoji] ?? "Personaje" }
