//
//  AccessibilitySheet.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Panel de Accesibilidad (dentro de la app)

struct AccessibilitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @AppStorage(AccessPrefs.textSizeKey) private var textSizeIndex = 0
    @AppStorage(Haptics.enabledKey) private var hapticsOn = true

    var body: some View {
        NavigationStack {
            Form {
                // VoiceOver: iOS no permite que una app lo encienda; aquí se muestra su estado,
                // se explica dónde activarlo y se puede probar la lectura en voz alta.
                Section("VoiceOver") {
                    Label(voiceOver ? "VoiceOver está activado" : "VoiceOver está desactivado",
                          systemImage: voiceOver ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.headline)
                    Text("VoiceOver lee en voz alta los botones y textos de la app. Para activarlo ve a Ajustes > Accesibilidad > VoiceOver.")
                        .font(.body)
                    Button {
                        Haptics.impact(.light)
                        announce("Así suena VoiceOver en Conecta CAM")
                    } label: {
                        Label("Probar lectura en voz alta", systemImage: "play.circle.fill")
                            .frame(minHeight: 44)
                    }
                    .accessibilityHint("VoiceOver dirá una frase de prueba. Solo funciona con VoiceOver activado.")
                }

                Section("Tamaño del texto") {
                    Stepper(value: $textSizeIndex, in: 0...AccessPrefs.sizes.count) {
                        Text(AccessPrefs.name(textSizeIndex))
                            .font(.headline)
                    }
                    .accessibilityLabel("Tamaño del texto")
                    .accessibilityValue(AccessPrefs.name(textSizeIndex))
                    .onChange(of: textSizeIndex) { _, _ in Haptics.selection() }

                    Text("Así se ve el texto de la app.")
                        .camFont(28, .bold)
                    Text("Automático usa el tamaño configurado en Ajustes del iPad.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Vibración") {
                    Toggle("Vibración al tocar", isOn: $hapticsOn)
                        .onChange(of: hapticsOn) { _, on in
                            if on { Haptics.impact(.medium) }
                        }
                    Button {
                        Haptics.impact(.heavy)
                    } label: {
                        Label("Probar vibración", systemImage: "iphone.radiowaves.left.and.right")
                            .frame(minHeight: 44)
                    }
                    .disabled(!hapticsOn)
                    Text("La vibración solo se siente en un iPad físico, no en el simulador.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Accesibilidad")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        Haptics.impact(.light)
                        dismiss()
                    }
                    .accessibilityHint("Cierra los ajustes de accesibilidad")
                }
            }
        }
    }
}
