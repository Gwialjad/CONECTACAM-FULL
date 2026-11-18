//
//  CarControls.swift
//  Conecta CAM
//
//  Los controles de los dos jugadores:
//    Jugador 1 (azul, izquierda): ACELERAR.
//    Jugador 2 (rojo, derecha):   SALTAR.
//
//  Acelerar se puede hacer de dos maneras: mantener apretado, o con un toque
//  (para empezar) y otro (para parar), según la ayuda elegida.
//  Con VoiceOver o Control de interruptores basta con activar el botón.
//

import SwiftUI

struct CarControls: View {
    let engine: CarGameEngine
    let players: [String]
    let friends: [Friend]
    let tapToAccelerate: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var jumpHeld = false

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(spacing: 8) {
                playerTag(0)
                accelerateButton
            }
            Spacer(minLength: 24)
            VStack(spacing: 8) {
                playerTag(1)
                jumpButton
            }
        }
    }

    private func name(_ index: Int) -> String {
        players.indices.contains(index) ? players[index] : "Jugador \(index + 1)"
    }

    // MARK: Etiqueta del jugador

    private func playerTag(_ index: Int) -> some View {
        HStack(spacing: 8) {
            if friends.indices.contains(index) {
                Image(friends[index].imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .accessibilityHidden(true)
            }
            Text(name(index))
                .camFont(20, .heavy)
                .foregroundStyle(CarStyle.deep(index))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .padding(.vertical, 5)
        .background(.white, in: Capsule())
        .overlay(Capsule().stroke(CarStyle.pale(index), lineWidth: 3))
        .accessibilityHidden(true) // el nombre ya lo dice cada botón
    }

    // MARK: Acelerar (jugador 1)

    private var accelerateLabel: some View {
        let isOn = engine.isAccelerating
        return VStack(spacing: 4) {
            Image(systemName: tapToAccelerate && isOn ? "pause.fill" : "arrow.right")
                .font(.system(size: 42, weight: .heavy))
            Text(tapToAccelerate && isOn ? "PARAR" : "ACELERAR")
                .camFont(22, .heavy)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(.white)
        .frame(minWidth: 190, minHeight: 112)
        .padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: 30).fill(CarStyle.accent(0)))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white, lineWidth: 4))
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        .scaleEffect(isOn && !reduceMotion ? 0.94 : 1)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: isOn)
    }

    @ViewBuilder
    private var accelerateButton: some View {
        Group {
            if tapToAccelerate {
                accelerateLabel
                    .onTapGesture {
                        Haptics.impact(.light)
                        engine.toggleAccelerating()
                    }
            } else {
                accelerateLabel
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in engine.setAccelerating(true) }
                            .onEnded { _ in engine.setAccelerating(false) }
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Acelerar, \(name(0))")
        .accessibilityValue(engine.isAccelerating ? "Acelerando" : "Parado")
        .accessibilityHint("Toca dos veces para acelerar o para parar")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { engine.toggleAccelerating() }
    }

    // MARK: Saltar (jugador 2)

    private var jumpButton: some View {
        VStack(spacing: 4) {
            Image(systemName: "arrow.up")
                .font(.system(size: 42, weight: .heavy))
            Text("SALTAR")
                .camFont(22, .heavy)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(.white)
        .frame(minWidth: 190, minHeight: 112)
        .padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: 30).fill(CarStyle.accent(1)))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white, lineWidth: 4))
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        .scaleEffect(jumpHeld && !reduceMotion ? 0.94 : 1)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: jumpHeld)
        // Salta en cuanto lo tocan (no cuando sueltan), para que se sienta rápido.
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !jumpHeld {
                        jumpHeld = true
                        engine.jump()
                    }
                }
                .onEnded { _ in jumpHeld = false }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Saltar, \(name(1))")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { engine.jump() }
    }
}
