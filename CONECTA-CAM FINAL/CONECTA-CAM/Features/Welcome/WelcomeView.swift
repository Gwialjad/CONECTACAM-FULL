//
//  WelcomeView.swift
//  Conecta CAM
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var store: AppStore
    let onPlay: () -> Void
    @State private var showCustomize = false
    @State private var showAccessibility = false

    var body: some View {
        ZStack {
            AnimatedFlagBackground()

            // Saludo arriba a la izquierda
            VStack(alignment: .leading, spacing: 4) {
                Text("¡HOLA!")
                    .camFont(64, .heavy)
                    .accessibilityAddTraits(.isHeader)
                Text(store.profile.name)
                    .camFont(32, .semibold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .accessibilityLabel("Nombre: \(store.profile.name)")
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
            .padding(.leading, 60)
            .padding(.top, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilitySortPriority(3)

            // Botones de texto a la derecha
            VStack(alignment: .trailing, spacing: 22) {
                Button {
                    Haptics.impact(.medium)
                    onPlay()
                } label: {
                    Text("INICIAR")
                        .camFont(80, .heavy)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(minHeight: 44)
                }
                .accessibilityLabel("Iniciar")
                .accessibilityHint("Abre el menú principal")

                Button {
                    Haptics.impact(.light)
                    showCustomize = true
                } label: {
                    Text("PERSONALIZAR")
                        .camFont(52, .heavy)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(minHeight: 44)
                }
                .accessibilityLabel("Personalizar perfil")
                .accessibilityHint("Cambia tu nombre.")

                Button {
                    Haptics.impact(.light)
                    showAccessibility = true
                } label: {
                    Text("ACCESIBILIDAD")
                        .camFont(36, .bold)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(minHeight: 44)
                }
                .accessibilityLabel("Ajustes de accesibilidad")
                .accessibilityHint("Cambia el tamaño del texto y la vibración, y revisa VoiceOver")
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
            .padding(.trailing, 70)
            .padding(.top, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .accessibilitySortPriority(2)
        }
        .sheet(isPresented: $showCustomize) { CustomizeSheet() }
        .sheet(isPresented: $showAccessibility) { AccessibilitySheet() }
    }
}

//New menu screen