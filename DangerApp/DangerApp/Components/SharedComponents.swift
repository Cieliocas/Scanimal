//
//  SharedComponents.swift
//  DangerApp / Scanimal
//
//  Componentes visuais reutilizados entre as telas (marca, barra superior).
//

import SwiftUI

/// Logo da marca (ícone médico + "Scanimal") usado no topo das telas.
struct ScanimalLogo: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 20, weight: .bold))
            Text("Scanimal")
                .font(.system(size: 20, weight: .bold))
        }
        .foregroundStyle(Theme.primary)
    }
}

/// Barra superior translúcida com a marca à esquerda e uma ação à direita.
/// Usada nas telas que não dependem de NavigationStack (Mapa e Chat).
struct ScanimalHeader<Trailing: View>: View {
    var centerTitle: String? = nil
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack {
            ScanimalLogo()
            Spacer()
            if let centerTitle {
                Text(centerTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.onSurfaceVariant)
                Spacer()
            }
            trailing
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.bar)
    }
}

extension ScanimalHeader where Trailing == EmptyView {
    init(centerTitle: String? = nil) {
        self.init(centerTitle: centerTitle) { EmptyView() }
    }
}

/// Botão circular de ação (ex.: perfil) no canto da barra superior.
struct CircleIconButton: View {
    let systemName: String
    var tint: Color = Theme.onSurface
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(Theme.field, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
