//
//  OutlinedTitle.swift
//  Conecta CAM
//

import SwiftUI

/// Título blanco con contorno naranja y sombra, como "2 JUGADORES".
struct OutlinedTitle: View {
    let text: String
    var size: CGFloat = 60
    var outline: Color = Color(hex: 0xF28A1E)
    var depth: Color = Color(hex: 0xD9700E)

    private let offsets: [(CGFloat, CGFloat)] = [
        (-3, 0), (3, 0), (0, -3), (0, 3), (-2, -2), (2, -2), (-2, 2), (2, 2)
    ]

    var body: some View {
        ZStack {
            // Capas decorativas (VoiceOver las ignora; solo lee el texto de encima)
            Group {
                Text(text).camFont(size, .heavy).foregroundStyle(depth).offset(y: 7)
                ForEach(offsets.indices, id: \.self) { i in
                    Text(text).camFont(size, .heavy).foregroundStyle(outline)
                        .offset(x: offsets[i].0, y: offsets[i].1)
                }
            }
            .accessibilityHidden(true)

            Text(text)
                .camFont(size, .heavy)
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)
        }
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }
}
