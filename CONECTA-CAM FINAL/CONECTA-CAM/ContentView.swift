//
//  ContentView.swift
//  Conecta CAM
//

import SwiftUI

// El punto de entrada (@main) ya existe en MyApp.swift de la plantilla de Xcode,
// que muestra ContentView. Por eso aquí solo definimos ContentView.
struct ContentView: View {
    @StateObject private var store = AppStore()
    var body: some View {
        RootView()
            .environmentObject(store)
            // Dynamic Type: sigue al sistema o al tamaño elegido en el panel de Accesibilidad.
            .modifier(AppTextSize())
    }
}
