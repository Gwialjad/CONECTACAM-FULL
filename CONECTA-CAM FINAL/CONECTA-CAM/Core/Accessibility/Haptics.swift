//
//  Haptics.swift
//  Conecta CAM
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Vibraciones táctiles centralizadas. Se usan en las interacciones reales de la app.
enum Haptics {
    enum Style { case light, medium, heavy, soft, rigid }

    /// Llave en UserDefaults; el interruptor del panel de Accesibilidad usa la misma.
    static let enabledKey = "conectacam.haptics"
    static var enabled: Bool {
        UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
    }

#if canImport(UIKit)
    static func impact(_ style: Style = .medium) {
        guard enabled else { return }
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: uiStyle = .light
        case .medium: uiStyle = .medium
        case .heavy: uiStyle = .heavy
        case .soft: uiStyle = .soft
        case .rigid: uiStyle = .rigid
        }
        let g = UIImpactFeedbackGenerator(style: uiStyle)
        g.prepare()
        g.impactOccurred()
    }
    static func selection() {
        guard enabled else { return }
        let g = UISelectionFeedbackGenerator()
        g.prepare()
        g.selectionChanged()
    }
    static func success() {
        guard enabled else { return }
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.success)
    }
    static func warning() {
        guard enabled else { return }
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.warning)
    }
#else
    // Plataformas sin UIKit (p. ej. macOS): no hay vibración, pero el código compila.
    static func impact(_ style: Style = .medium) {}
    static func selection() {}
    static func success() {}
    static func warning() {}
#endif
}
