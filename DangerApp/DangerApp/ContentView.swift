//
//  ContentView.swift
//  DangerApp / Vitalis
//
//  Navegação principal: TabView com exatamente 4 telas.
//

import SwiftUI

struct ContentView: View {
    // Aba inicial (0 = Map). Lê um valor opcional de UserDefaults — útil para
    // testes/screenshots; em produção começa em 0 (Mapa).
    @State private var selection = UserDefaults.standard.integer(forKey: "startTab")

    var body: some View {
        TabView(selection: $selection) {
            MapView()
                .tag(0)
                .tabItem { Label("Map", systemImage: "map.fill") }

            SearchView()
                .tag(1)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            ChatView()
                .tag(2)
                .tabItem { Label("AI Chat", systemImage: "brain.head.profile") }

            SettingsView()
                .tag(3)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.primary)
    }
}

#Preview {
    ContentView()
}
