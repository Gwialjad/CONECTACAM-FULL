//
//  RootView.swift
//  Conecta CAM
//

import SwiftUI

enum Route { case welcome, characters, menu, activities, diary, goals }

struct RootView: View {
    @State private var route: Route = .welcome

    var body: some View {
        ZStack {
            switch route {
            case .welcome:
                WelcomeView(onPlay: { route = .characters })
            case .characters:
                CharacterSelectionView(onContinue: { route = .menu },
                                       onBack: { route = .welcome })
            case .menu:
                MenuView(go: { route = $0 }, onClose: { route = .welcome })
            case .activities:
                ActivitiesView(onClose: { route = .menu })
            case .diary:
                DiaryView(onClose: { route = .menu })
            case .goals:
                GoalsView(onClose: { route = .menu })
            }
        }
        .animation(.easeInOut(duration: 0.25), value: route)
    }
}
