//
//  CustomizeSheet.swift
//  Conecta CAM
//

import SwiftUI

/// Ahora solo cambia el nombre. El personaje se elige en la pantalla "Elige a tu amigo".
struct CustomizeSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Mi nombre") {
                    TextField("Nombre", text: $store.profile.name)
                        .accessibilityLabel("Mi nombre")
                        .accessibilityHint("Escribe tu nombre")
                }
            }
            .navigationTitle("Personalizar")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        Haptics.impact(.light)
                        dismiss()
                    }
                    .accessibilityHint("Guarda los cambios y cierra")
                }
            }
        }
    }
}
