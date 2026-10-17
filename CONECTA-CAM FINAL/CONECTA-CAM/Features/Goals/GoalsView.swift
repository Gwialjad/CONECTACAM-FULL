//
//  GoalsView.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Metas y rachas

struct GoalsView: View {
    @EnvironmentObject var store: AppStore
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.camBlue.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "MIS METAS", onClose: onClose)
                ScrollView {
                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .leading, spacing: 34) {
                            bar("JUGADO CON \(store.peopleCount) PERSONAS",
                                spoken: "Personas con las que has jugado",
                                value: store.peopleCount, target: store.goals.people)
                            bar("RACHA DIARIA \(store.weekStreak)/\(store.goals.streak)",
                                spoken: "Racha de días activos esta semana",
                                value: store.weekStreak, target: store.goals.streak)
                            bar("GRUPOS \(store.groupsCount)/\(store.goals.groups)",
                                spoken: "Partidas en grupo de tres o más personas",
                                value: store.groupsCount, target: store.goals.groups)
                        }
                        .frame(maxWidth: .infinity)

                        // Ajuste de metas simples (para docentes/cuidadores)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Ajustar metas").camFont(28, .heavy)
                                .accessibilityAddTraits(.isHeader)
                            Stepper("Personas: \(store.goals.people)", value: $store.goals.people, in: 1...30)
                            Stepper("Días de racha: \(store.goals.streak)", value: $store.goals.streak, in: 1...7)
                            Stepper("Grupos: \(store.goals.groups)", value: $store.goals.groups, in: 1...30)
                        }
                        .camFont(22)
                        .padding(24)
                        .frame(width: 340)
                        .background(RoundedRectangle(cornerRadius: 24).fill(.white))
                        // Vibración suave al cambiar cualquier meta.
                        .onChange(of: store.goals) { _, _ in Haptics.selection() }
                    }
                    .padding(.horizontal, 32)
                }
            }
            .padding(.top, 20)
        }
    }

    private func bar(_ label: String, spoken: String, value: Int, target: Int) -> some View {
        let p = target > 0 ? min(Double(value) / Double(target), 1) : 0
        return VStack(alignment: .leading, spacing: 10) {
            Text(label).camFont(44, .heavy).foregroundStyle(.white)
                .minimumScaleFactor(0.5)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white)
                    Capsule().fill(Color.camGreen)
                        .frame(width: max(geo.size.height, geo.size.width * p))
                        .opacity(value == 0 ? 0.35 : 1)
                }
            }
            .frame(height: 70)
            Text(p >= 1 ? "¡Meta cumplida! 🎉" : "Meta: \(target)")
                .camFont(20).foregroundStyle(.white.opacity(0.9))
        }
        // Un solo elemento para VoiceOver: nombre + progreso, en lugar de textos sueltos y una barra muda.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
        .accessibilityValue(p >= 1 ? "\(value) de \(target). Meta cumplida" : "\(value) de \(target)")
    }
}
