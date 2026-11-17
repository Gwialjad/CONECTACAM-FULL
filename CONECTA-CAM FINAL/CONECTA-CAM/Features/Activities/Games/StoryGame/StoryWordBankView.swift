//
//  StoryWordBankView.swift
//  Conecta CAM
//
//  Las 10 palabras del turno (dos filas de cinco).
//  Cuando cambia el turno llegan palabras nuevas con un fundido suave.
//

import SwiftUI

struct StoryWordBankView: View {
    let words: [StoryWord]
    let theme: StoryTheme
    let onPick: (StoryWord) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Con texto muy grande se usan menos columnas para que las palabras no se corten.
    private var columns: Int { typeSize.isAccessibilitySize ? 3 : 5 }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns),
            spacing: 12
        ) {
            ForEach(words) { word in
                Button { onPick(word) } label: {
                    Text(word.text)
                        .camFont(21, .bold)
                        .foregroundStyle(theme.deep)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .background(theme.chip, in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.9), lineWidth: 3))
                        .shadow(color: .black.opacity(0.14), radius: 3, y: 4)
                }
                .buttonStyle(StoryPressableStyle())
                .accessibilityLabel("Agregar \(word.text)")
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: words)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Banco de palabras")
    }
}
