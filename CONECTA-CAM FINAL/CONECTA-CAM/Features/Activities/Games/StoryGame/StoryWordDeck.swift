//
//  StoryWordDeck.swift
//  Conecta CAM
//
//  Reparte las palabras de cada turno y arma las frases.
//

import Foundation

/// Reparte "manos" de palabras como si fuera una baraja:
/// cada tipo de palabra tiene su propio mazo revuelto y no se repite ninguna
/// hasta que se acaban todas las de ese tipo. Así, en una partida normal
/// casi nunca aparece la misma palabra dos veces.
struct StoryWordDeck {
    private var queues: [StoryWordKind: [StoryWord]] = [:]
    private var generator = SystemRandomNumberGenerator()

    /// Una mano nueva de 10 palabras. Ya viene en orden de frase
    /// (comienzo, personaje, acción, cosa, lugar, cómo, platicar),
    /// lo que ayuda a armar frases con sentido.
    mutating func nextHand() -> [StoryWord] {
        var hand: [StoryWord] = []
        var usedTexts = Set<String>()

        for (kind, count) in StoryWordBank.handRecipe {
            for _ in 0..<count {
                guard let word = draw(kind, avoiding: usedTexts) else { continue }
                usedTexts.insert(word.text)
                hand.append(word)
            }
        }
        return hand
    }

    /// Saca una palabra del mazo de ese tipo; si el mazo se acabó, lo vuelve a revolver.
    private mutating func draw(_ kind: StoryWordKind, avoiding used: Set<String>) -> StoryWord? {
        for _ in 0..<2 { // la segunda vuelta usa el mazo recién revuelto
            while let word = queues[kind]?.popLast() {
                if !used.contains(word.text) { return word }
            }
            queues[kind] = StoryWordBank.words(of: kind).shuffled(using: &generator)
        }
        return nil
    }
}

/// Junta las palabras elegidas en una frase bien escrita.
enum StorySentence {

    /// - Parameter addingPeriod: al guardar la frase se le pone punto final
    ///   (si no termina ya en `.`, `!`, `?` o `…`). Mientras se arma, no.
    static func compose(_ words: [String], addingPeriod: Bool = false) -> String {
        var text = words.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return "" }

        // Mayúscula en la primera letra (saltando signos como "¡" o "¿").
        if let index = text.firstIndex(where: { $0.isLetter }) {
            text.replaceSubrange(index...index, with: String(text[index]).uppercased())
        }

        if addingPeriod, let last = text.last, !".!?…".contains(last) {
            text += "."
        }
        return text
    }
}
