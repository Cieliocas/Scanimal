//
//  Theme.swift
//  DangerApp / Vitalis
//
//  Paleta de cores e tipografia extraídas do design (Stitch "Serpente").
//  Mantém a identidade nativa iOS com suporte a Modo Claro/Escuro.
//

import SwiftUI
import UIKit

// MARK: - Helpers de cor (hex e adaptativo claro/escuro)

private extension UIColor {
    convenience init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    /// Cor fixa a partir de um hex (ex.: "006a65").
    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex))
    }

    /// Cor adaptativa que muda entre Modo Claro e Escuro.
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

// MARK: - Tokens de cor do app (Vitalis)

enum Theme {
    // Marca / Saúde (System Teal)
    static let primary    = Color(light: "006a65", dark: "39dcd2")
    static let onPrimary  = Color(light: "ffffff", dark: "003734")

    // Emergência / Perigo (System Red)
    static let danger     = Color(hex: "e2241f")
    static let dangerText = Color(light: "bc000a", dark: "ffb4aa")

    // Risco médio (System Orange)
    static let warning     = Color(hex: "ff9a23")
    static let warningText = Color(light: "8c5000", dark: "ffb874")

    // Superfícies
    static let background        = Color(light: "faf9fe", dark: "121316")
    static let groupedBackground = Color(light: "f2f1f7", dark: "0e0f12")
    static let card              = Color(light: "ffffff", dark: "1c1d21")
    static let field             = Color(light: "e9e7ed", dark: "2a2c30")

    // Texto / contornos
    static let onSurface        = Color(light: "1a1b1f", dark: "e3e2e7")
    static let onSurfaceVariant = Color(light: "3c4948", dark: "bacac7")
    static let outlineVariant   = Color(light: "cfdedb", dark: "3c4948")
}
