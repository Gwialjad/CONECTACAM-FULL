//
//  ScreenHeader.swift
//  Conecta CAM
//

import SwiftUI

/// Encabezado con título y cinta roja con "X" para cerrar.
struct ScreenHeader: View {
    let title: String
    var titleColor: Color = .white
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .camFont(52, .heavy)
                .foregroundStyle(titleColor)
                .minimumScaleFactor(0.5)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button {
                Haptics.impact(.light)
                onClose()
            } label: {
                ZStack(alignment: .topTrailing) {
                    RibbonShape().fill(Color.camRed).frame(width: 220, height: 80)
                    Text("X")
                        .camFont(44, .heavy)
                        .foregroundStyle(.white)
                        .padding(.trailing, 28)
                }
            }
            .accessibilityLabel("Cerrar")
            .accessibilityHint("Regresa a la pantalla anterior")
        }
        .padding(.leading, 32)
    }
}
