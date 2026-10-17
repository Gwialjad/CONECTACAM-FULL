//
//  FinishedView.swift
//  Conecta CAM
//

import SwiftUI

struct FinishedView: View {
    let onExit: () -> Void
    var body: some View {
        VStack(spacing: 30) {
            Text("🎉").font(.system(size: 140)) // decorativo
                .accessibilityHidden(true)
            Text("¡Lo lograron juntos!")
                .camFont(52, .heavy).foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Button {
                Haptics.impact(.light)
                onExit()
            } label: {
                Text("VOLVER")
                    .camFont(34, .heavy)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 60).padding(.vertical, 18)
                    .background(Capsule().fill(Color.camGreen))
            }
            .accessibilityLabel("Volver a actividades")
        }
        .onAppear { announce("¡Lo lograron juntos! Actividad terminada.") }
    }
}
