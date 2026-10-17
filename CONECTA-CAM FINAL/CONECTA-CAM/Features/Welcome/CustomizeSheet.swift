//
//  CustomizeSheet.swift
//  Conecta CAM
//

import SwiftUI

struct CustomizeSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    private let avatars = ["🦖", "🐱", "🐶", "🦊", "🐼", "🐸", "🦄", "🚀"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Mi nombre") {
                    TextField("Nombre", text: $store.profile.name)
                        .accessibilityLabel("Mi nombre")
                        .accessibilityHint("Escribe tu nombre")
                }
                Section("Mi personaje") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(avatars, id: \.self) { a in
                            // Antes era un Text con onTapGesture (VoiceOver no lo detectaba como botón).
                            Button {
                                Haptics.selection()
                                store.profile.avatar = a
                            } label: {
                                Text(a).font(.system(size: 60))
                                    .padding(8)
                                    .frame(minWidth: 60, minHeight: 60)
                                    .background(RoundedRectangle(cornerRadius: 16)
                                        .fill(store.profile.avatar == a ? Color.camGreen.opacity(0.4) : .clear))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(avatarName(a))
                            .accessibilityAddTraits(store.profile.avatar == a ? .isSelected : [])
                        }
                    }
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
