//
//  VoiceOverHelpers.swift
//  Conecta CAM
//

import SwiftUI

/// Anuncia un mensaje en voz alta con VoiceOver (por ejemplo, cambio de turno).
func announce(_ message: String) {
    AccessibilityNotification.Announcement(message).post()
}
