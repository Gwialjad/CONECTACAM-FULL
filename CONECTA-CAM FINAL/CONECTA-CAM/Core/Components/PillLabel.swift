//
//  PillLabel.swift
//  Conecta CAM
//

import SwiftUI

/// Etiqueta en forma de cápsula, compartida por los botones de los juegos.
struct PillLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text).camFont(28, .heavy).foregroundStyle(.white)
            .padding(.horizontal, 44).padding(.vertical, 16)
            .background(Capsule().fill(color))
    }
}
