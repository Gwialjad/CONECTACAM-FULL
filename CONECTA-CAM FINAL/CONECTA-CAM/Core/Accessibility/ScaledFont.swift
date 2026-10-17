//
//  ScaledFont.swift
//  Conecta CAM
//

import SwiftUI

/// Escala el tamaño de letra con los ajustes del sistema (Ajustes > Accesibilidad > Texto más grande).
/// Conserva el diseño original (tamaños grandes y redondeados) pero ahora responde a Dynamic Type.
struct ScaledFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design
    private let italic: Bool

    init(size: CGFloat, weight: Font.Weight, design: Font.Design, italic: Bool) {
        // Estilo de texto de referencia: define cuánto escala según el tamaño base.
        let style: Font.TextStyle
        switch size {
        case 44...: style = .largeTitle
        case 30..<44: style = .title
        case 24..<30: style = .title3
        default: style = .body
        }
        _size = ScaledMetric(wrappedValue: size, relativeTo: style)
        self.weight = weight
        self.design = design
        self.italic = italic
    }

    func body(content: Content) -> some View {
        let base = Font.system(size: size, weight: weight, design: design)
        content.font(italic ? base.italic() : base)
    }
}

extension View {
    /// Fuente redondeada que escala con Dynamic Type.
    func camFont(_ size: CGFloat, _ weight: Font.Weight = .regular, italic: Bool = false) -> some View {
        modifier(ScaledFont(size: size, weight: weight, design: .rounded, italic: italic))
    }
}
