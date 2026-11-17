//
//  StoryPanel.swift
//  Conecta CAM
//
//  La tarjeta blanca grande: título, la historia hasta ahora
//  y, abajo, la frase que el jugador está armando.
//

import SwiftUI

/// Una frase ya guardada en la historia.
struct StoryContribution: Identifiable {
    let id = UUID()
    let playerIndex: Int
    let author: String
    let text: String
}

struct StoryPanel: View {
    let prompt: String
    let story: [StoryContribution]
    /// Frase en curso (vacía si todavía no eligió palabras).
    let sentence: String
    let theme: StoryTheme
    let onDelete: () -> Void
    let onAdd: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var hasWords: Bool { !sentence.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            board
            composer
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 36))
        .overlay(RoundedRectangle(cornerRadius: 36).stroke(theme.pale, lineWidth: 8))
        .overlay(alignment: .topLeading) {
            titlePill.offset(x: 6, y: -34)
        }
        .padding(.top, 34) // espacio para el título que sobresale
    }

    // MARK: Título

    private var titlePill: some View {
        HStack(spacing: 4) {
            Sparkle()
            Text(prompt)
                .camFont(34, .heavy)
                .foregroundStyle(theme.deep)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 26)
                .padding(.vertical, 10)
                .background(.white, in: Capsule())
                .overlay(Capsule().stroke(theme.pale, lineWidth: 4))
                .accessibilityAddTraits(.isHeader)
        }
    }

    // MARK: La historia

    private var board: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if story.isEmpty {
                        Text("Aquí aparecerá su historia...")
                            .camFont(28, .medium)
                            .foregroundStyle(theme.deep.opacity(0.75))
                    } else {
                        ForEach(story) { part in
                            row(part).id(part.id)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 46)   // deja libre el título que sobresale
                .padding(.bottom, 14)
            }
            .onChange(of: story.count) {
                guard let last = story.last else { return }
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    private func row(_ part: StoryContribution) -> some View {
        let partTheme = StoryTheme.forPlayer(part.playerIndex)
        return VStack(alignment: .leading, spacing: 4) {
            Text(part.text)
                .camFont(26, .medium)
                .foregroundStyle(StoryStyle.ink)
            Text("— \(part.author)")
                .camFont(18, .semibold)
                .foregroundStyle(partTheme.deep)
        }
        .padding(.leading, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) {
            Capsule().fill(partTheme.accent).frame(width: 7)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(part.author): \(part.text)")
    }

    // MARK: Frase en curso

    private var composer: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        return layout {
            sentenceField
            addButton
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(theme.pale.opacity(0.55))
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 28, bottomTrailingRadius: 28))
    }

    private var sentenceField: some View {
        HStack(spacing: 10) {
            Image(systemName: "pencil")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(theme.deep)
                .accessibilityHidden(true)

            Text(hasWords ? sentence : "Elige palabras para crear tu frase...")
                .camFont(24, hasWords ? .semibold : .regular)
                .foregroundStyle(hasWords ? theme.deep : theme.deep.opacity(0.75))
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(hasWords ? "Tu frase: \(sentence)" : "Tu frase está vacía")

            if hasWords {
                Button(action: onDelete) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(theme.deep)
                        .frame(width: 48, height: 48)
                }
                .accessibilityLabel("Borrar última palabra")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .frame(minHeight: 64)
        .background(theme.chip, in: RoundedRectangle(cornerRadius: 30))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(theme.pale, lineWidth: 3))
    }

    private var addButton: some View {
        Button(action: onAdd) {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                Text("AGREGAR").camFont(24, .heavy)
            }
            .foregroundStyle(StoryStyle.ink)
            .lineLimit(1)
            .padding(.horizontal, 28)
            .frame(maxWidth: typeSize.isAccessibilitySize ? .infinity : nil, minHeight: 64)
            .background(Color.camGreen, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.8), lineWidth: 3))
        }
        .buttonStyle(StoryPressableStyle())
        .disabled(!hasWords)
        .opacity(hasWords ? 1 : 0.5)
        .accessibilityHint(hasWords
            ? "Guarda tu frase y pasa el turno al siguiente jugador"
            : "Primero elige al menos una palabra")
    }
}
