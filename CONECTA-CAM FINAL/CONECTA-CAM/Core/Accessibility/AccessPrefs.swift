//
//  AccessPrefs.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Accesibilidad: ajuste de tamaño de texto dentro de la app

enum AccessPrefs {
    static let textSizeKey = "conectacam.textSize"
    /// Índice 0 = automático (sigue el tamaño del sistema). 1...8 = tamaño elegido en la app.
    static let sizes: [DynamicTypeSize] = [.small, .medium, .large, .xLarge, .xxLarge,
                                           .xxxLarge, .accessibility1, .accessibility2]
    static let names = ["Pequeño", "Mediano", "Grande", "Muy grande", "Extra grande",
                        "Enorme", "Accesibilidad 1", "Accesibilidad 2"]
    static func name(_ index: Int) -> String {
        (1...names.count).contains(index) ? names[index - 1] : "Automático (sigue al sistema)"
    }
}

/// Aplica a toda la app el tamaño elegido en el panel de Accesibilidad.
/// En "Automático" respeta el tamaño del sistema, con tope en Accesibilidad 2
/// (más allá se desbordarían los contenedores de tamaño fijo).
struct AppTextSize: ViewModifier {
    @AppStorage(AccessPrefs.textSizeKey) private var index = 0
    @Environment(\.dynamicTypeSize) private var system

    func body(content: Content) -> some View {
        let size = (1...AccessPrefs.sizes.count).contains(index)
            ? AccessPrefs.sizes[index - 1]
            : min(system, .accessibility2)
        content.dynamicTypeSize(size)
    }
}
