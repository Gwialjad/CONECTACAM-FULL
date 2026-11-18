//
//  CarHUD.swift
//  Conecta CAM
//
//  Lo que se ve arriba durante la carrera: salir, zona, corazones,
//  estrellas, pausa y la barra de progreso.
//  Todo va en cápsulas blancas con texto oscuro para que se lea sobre cualquier cielo.
//

import SwiftUI

struct CarHUD: View {
    let engine: CarGameEngine
    let onExit: () -> Void
    let onPause: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                CarIconButton(systemName: "xmark", label: "Salir del juego",
                              color: CarStyle.accent(1), action: onExit)

                zonePill

                Spacer(minLength: 8)

                hearts
                starsPill

                CarIconButton(systemName: "pause.fill", label: "Pausa y ayudas",
                              color: CarStyle.accent(0), action: onPause)
            }
            progressBar
        }
    }

    // MARK: Zona

    private var zonePill: some View {
        let zones = engine.level.zones
        let index = min(engine.zoneIndex, zones.count - 1)
        return Text("ZONA \(index + 1) · \(zones[index].name.uppercased())")
            .camFont(22, .heavy)
            .foregroundStyle(CarStyle.deep(0))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.white, in: Capsule())
            .overlay(Capsule().stroke(CarStyle.pale(0), lineWidth: 3))
            .accessibilityLabel("Zona \(index + 1) de \(zones.count): \(zones[index].name)")
    }

    // MARK: Corazones y estrellas

    private var hearts: some View {
        HStack(spacing: 4) {
            ForEach(0..<CarGameEngine.maxLives, id: \.self) { i in
                Image(systemName: i < engine.lives ? "heart.fill" : "heart")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(CarStyle.heart)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white, in: Capsule())
        .overlay(Capsule().stroke(CarStyle.pale(1), lineWidth: 3))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Corazones")
        .accessibilityValue("\(engine.lives) de \(CarGameEngine.maxLives)")
    }

    private var starsPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(hex: 0xF5A800))
            Text("\(engine.starsCollected)")
                .camFont(24, .heavy)
                .foregroundStyle(CarStyle.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.white, in: Capsule())
        .overlay(Capsule().stroke(Color(hex: 0xFFE9A0), lineWidth: 3))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Estrellas")
        .accessibilityValue("\(engine.starsCollected)")
    }

    // MARK: Progreso

    private var progressBar: some View {
        let zoneCount = engine.level.zones.count
        return GeometryReader { geo in
            let width = geo.size.width
            let markerX = min(max(width * engine.progress - 23, 0), max(width - 46, 0))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white)
                    .frame(height: 18)
                    .overlay(Capsule().stroke(.black.opacity(0.15), lineWidth: 2))

                Capsule()
                    .fill(Color(hex: 0x43C463))
                    .frame(width: max(18, width * engine.progress), height: 18)

                // Marcas de los puntos de control
                ForEach(1..<max(zoneCount, 2), id: \.self) { i in
                    Rectangle()
                        .fill(CarStyle.ink.opacity(0.55))
                        .frame(width: 3, height: 18)
                        .offset(x: width * CGFloat(i) / CGFloat(zoneCount) - 1.5)
                }

                Image("car")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 46, height: 30)
                    .offset(x: markerX)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 34)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progreso de la carrera")
        .accessibilityValue("\(engine.progressPercent) por ciento")
    }
}
