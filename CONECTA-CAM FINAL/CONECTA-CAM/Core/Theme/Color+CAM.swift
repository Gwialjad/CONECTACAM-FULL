//
//  Color+CAM.swift
//  Conecta CAM
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
    static let camBlue = Color(hex: 0x5271FF)
    static let camGreen = Color(hex: 0x7ED957)
    static let camYellow = Color(hex: 0xFACE6B)
    static let camCyan = Color(hex: 0x5CE1E6)
    static let camRed = Color(hex: 0xFF5757)
    static let camLavender = Color(hex: 0x9A9CFF)
}
