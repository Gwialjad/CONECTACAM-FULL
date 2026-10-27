//
//  MenuView.swift
//  Conecta CAM
//

import SwiftUI

/// Datos de cada panel del menú (posición, colores, ícono y texto).
/// Las posiciones están en proporción (0...1) del ancho y alto de la pantalla.
private struct PanelSpec {
    let title: String
    let label: String          // lo que lee VoiceOver
    let hint: String
    let route: Route
    let colors: [Color]
    let points: [(CGFloat, CGFloat)]   // esquinas del panel
    let icon: String                   // nombre en Assets.xcassets
    let iconCenter: (CGFloat, CGFloat)
    let iconHeight: CGFloat            // proporción del alto de pantalla
    let titleCenter: (CGFloat, CGFloat)
    let titleWidth: CGFloat            // proporción del ancho de pantalla
    let titleAngle: Double
    let pulseDelay: Double
}

struct MenuView: View {
    let go: (Route) -> Void
    let onClose: () -> Void
    @EnvironmentObject var store: AppStore

    private var friend: Friend { Friend.with(id: store.profile.avatar) }

    private let panels: [PanelSpec] = [
        PanelSpec(title: "Actividades", label: "Actividades",
                  hint: "Juegos para jugar con otras personas",
                  route: .activities,
                  colors: [Color(hex: 0x9AE04F), Color(hex: 0x55B83D)],
                  points: [(0.03, 0.57), (0.085, 0.16), (0.49, 0.055), (0.49, 0.50), (0.38, 0.535)],
                  icon: "icon_actividades",
                  iconCenter: (0.24, 0.215), iconHeight: 0.29,
                  titleCenter: (0.215, 0.44), titleWidth: 0.31, titleAngle: -6,
                  pulseDelay: 0),
        PanelSpec(title: "Diario", label: "Diario",
                  hint: "Escribe lo que conociste hoy",
                  route: .diary,
                  colors: [Color(hex: 0xFFD95A), Color(hex: 0xF5A623)],
                  points: [(0.51, 0.055), (0.915, 0.15), (0.975, 0.575), (0.63, 0.535), (0.51, 0.50)],
                  icon: "icon_diario",
                  iconCenter: (0.785, 0.26), iconHeight: 0.31,
                  titleCenter: (0.785, 0.47), titleWidth: 0.28, titleAngle: 5,
                  pulseDelay: 0.6),
        PanelSpec(title: "Metas", label: "Metas",
                  hint: "Mira tu progreso y tus rachas",
                  route: .goals,
                  colors: [Color(hex: 0x74E6EE), Color(hex: 0x35C9DC)],
                  points: [(0.14, 0.64), (0.86, 0.635), (0.80, 0.90), (0.21, 0.905)],
                  icon: "icon_metas",
                  iconCenter: (0.36, 0.765), iconHeight: 0.20,
                  titleCenter: (0.61, 0.775), titleWidth: 0.28, titleAngle: 0,
                  pulseDelay: 1.2)
    ]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                ForEach(panels, id: \.title) { spec in
                    panelButton(spec, w: w, h: h)
                }
                characterBadge(w: w, h: h)
                closeButton
            }
            .frame(width: w, height: h)
        }
        .background(SkyBackground())
    }

    // MARK: - Panel (botón con ícono que late)

    private func panelButton(_ spec: PanelSpec, w: CGFloat, h: CGFloat) -> some View {
        let shape = RoundedPolygon(points: spec.points, radius: 34)
        return Button {
            Haptics.impact(.light)
            go(spec.route)
        } label: {
            ZStack {
                shape.fill(LinearGradient(colors: spec.colors, startPoint: .top, endPoint: .bottom))
                shape.stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineJoin: .round))
                Image(spec.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: h * spec.iconHeight)
                    .pulse(delay: spec.pulseDelay)
                    .position(x: w * spec.iconCenter.0, y: h * spec.iconCenter.1)
                Text(spec.title)
                    .camFont(64, .heavy)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.18), radius: 3, y: 3)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .frame(width: w * spec.titleWidth)
                    .rotationEffect(.degrees(spec.titleAngle))
                    .position(x: w * spec.titleCenter.0, y: h * spec.titleCenter.1)
            }
            .frame(width: w, height: h)
            .contentShape(shape) // solo se puede tocar dentro del panel
        }
        .buttonStyle(.plain)
        // Un solo elemento para VoiceOver, sin leer la imagen ni el texto por separado.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spec.label)
        .accessibilityHint(spec.hint)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Personaje elegido en el centro

    private func characterBadge(w: CGFloat, h: CGFloat) -> some View {
        let d = min(w * 0.26, h * 0.5)
        return Circle()
            .fill(LinearGradient(colors: [Color(hex: 0xBFEBFF), Color(hex: 0x74CBF8)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(Circle().stroke(Color.white, lineWidth: 12))
            .overlay(
                Image(friend.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(d * 0.17)
            )
            .frame(width: d, height: d)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .position(x: w * 0.5, y: h * 0.455)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Tu personaje: \(friend.name)")
            .accessibilitySortPriority(-1)
    }

    // MARK: - Cinta roja para volver

    private var closeButton: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom, 24)
        .accessibilityLabel("Cerrar")
        .accessibilityHint("Regresa a la pantalla de inicio")
    }
}
