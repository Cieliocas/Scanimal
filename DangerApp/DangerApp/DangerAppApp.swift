//
//  DangerAppApp.swift
//  DangerApp / Scanimal
//
//  Created by Franciélio Castro on 18/06/26.
//

import SwiftUI

@main
struct DangerAppApp: App {

    /// Preferência de aparência controlada na tela de Opções.
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
