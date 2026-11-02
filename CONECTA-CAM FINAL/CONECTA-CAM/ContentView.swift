//
//  ContentView.swift
//  Conecta CAM
//

import SwiftUI

// El punto de entrada (@main) ya existe en MyApp.swift de la plantilla de Xcode,
// que muestra ContentView. Por eso aquí solo definimos ContentView.
struct ContentView: View {
    @StateObject private var store = AppStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        RootView()
            .environmentObject(store)
            // Dynamic Type: sigue al sistema o al tamaño elegido en el panel de Accesibilidad.
            .modifier(AppTextSize())
            // Música de fondo: suena mientras la app está en primer plano.
            .onAppear { MusicPlayer.shared.start() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    MusicPlayer.shared.start()
                } else {
                    MusicPlayer.shared.pause()
                }
            }
    }
}
