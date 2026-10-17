//
//  DiaryView.swift
//  Conecta CAM
//

import SwiftUI

// MARK: - Diario

struct DiaryView: View {
    @EnvironmentObject var store: AppStore
    let onClose: () -> Void
    @State private var selectedDay = 1
    @State private var text = ""
    @FocusState private var focused: Bool

    private var today: Int { store.dayNumber() }
    private var days: [Int] {
        Set(store.entries.map(\.dayNumber)).union([today]).sorted(by: >)
    }

    var body: some View {
        ZStack {
            Color.camYellow.ignoresSafeArea()
            VStack(spacing: 12) {
                ScreenHeader(title: "DÍA \(selectedDay)", onClose: onClose)
                HStack(alignment: .top, spacing: 20) {
                    // Apartados por día
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(days, id: \.self) { d in
                                Button {
                                    Haptics.selection()
                                    select(d)
                                } label: {
                                    VStack(spacing: 2) {
                                        Text("Día \(d)").camFont(26, .heavy)
                                            .minimumScaleFactor(0.6)
                                        if d == today { Text("Hoy").camFont(18) }
                                        else if let e = store.entry(forDay: d) {
                                            Text(e.date, format: .dateTime.day().month(.abbreviated))
                                                .camFont(18)
                                        }
                                    }
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, minHeight: 44).padding(.vertical, 14)
                                    .background(RoundedRectangle(cornerRadius: 18)
                                        .fill(d == selectedDay ? Color.camBlue : Color.camLavender))
                                }
                                .accessibilityLabel(d == today ? "Día \(d), hoy" : "Día \(d)")
                                .accessibilityHint("Abre las notas de este día")
                                .accessibilityAddTraits(d == selectedDay ? .isSelected : [])
                            }
                        }
                    }
                    .frame(width: 170)

                    // Escritura
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HOY CONOCÍ…")
                            .camFont(38, .black)
                            .accessibilityAddTraits(.isHeader)
                        TextEditor(text: $text)
                            .camFont(30)
                            .scrollContentBackground(.hidden)
                            .focused($focused)
                            .accessibilityLabel("Notas del día \(selectedDay)")
                            .accessibilityHint("Escribe lo que conociste hoy")
                    }
                    .padding(28)
                    .background(RoundedRectangle(cornerRadius: 24).fill(.white))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 12)
            }
            .padding(.top, 20)
        }
        .onAppear { select(today) }
        .onChange(of: text) { _, new in store.saveEntry(day: selectedDay, text: new) }
    }

    private func select(_ day: Int) {
        // guarda lo actual antes de cambiar
        store.saveEntry(day: selectedDay, text: text)
        selectedDay = day
        text = store.entry(forDay: day)?.text ?? ""
    }
}
