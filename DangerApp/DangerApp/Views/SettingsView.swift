//
//  SettingsView.swift
//  DangerApp / Scanimal
//
//  TELA 4 — Opções / Configurações. Form em estilo "inset grouped" do iOS,
//  com versão do app, alternância de Modo Escuro, suporte e seção "Sobre".
//

import SwiftUI

struct SettingsView: View {

    /// Preferência de Modo Escuro (aplicada no nível do app — ver DangerAppApp).
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: App
                Section("App") {
                    SettingsRow(icon: "info.circle.fill", tint: Theme.primary, title: "Versão") {
                        Text("1.0.0").foregroundStyle(Theme.onSurfaceVariant)
                    }
                }

                // MARK: Aparência
                Section("Aparência") {
                    Toggle(isOn: $isDarkMode) {
                        Label {
                            Text("Modo Escuro")
                        } icon: {
                            IconBadge(icon: "moon.fill", tint: .blue)
                        }
                    }
                    .tint(Theme.primary)
                }

                // MARK: Suporte
                Section("Suporte") {
                    NavigationLink {
                        ManualView()
                    } label: {
                        Label {
                            Text("Manual de Primeiros Socorros")
                        } icon: {
                            IconBadge(icon: "book.fill", tint: .orange)
                        }
                    }

                    NavigationLink {
                        HelpView()
                    } label: {
                        Label {
                            Text("Central de Ajuda")
                        } icon: {
                            IconBadge(icon: "questionmark.circle.fill", tint: Theme.primary)
                        }
                    }
                }

                // MARK: Sobre
                Section("Sobre") {
                    SettingsRow(icon: "cross.case.fill", tint: Theme.danger, title: "Antídoto Ágil") {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Theme.onSurfaceVariant)
                    }
                    Button {
                        // 🔧 Abrir Termos e Privacidade (Safari / link do Node-RED).
                    } label: {
                        SettingsRow(icon: "checkmark.shield.fill", tint: Theme.onSurfaceVariant, title: "Termos e Privacidade") {
                            Image(systemName: "arrow.up.forward.square")
                                .foregroundStyle(Theme.onSurfaceVariant)
                        }
                    }
                    .tint(Theme.onSurface)
                }

                // MARK: - Futuras Integrações
                // Section("Futuras Integrações") {
                //     // TODO: contatos de emergência, sincronização com o SUS,
                //     // histórico de ocorrências do usuário, notificações de risco, etc.
                // }

                // MARK: Ação destrutiva
                Section {
                    Button(role: .destructive) {
                        // 🔧 Limpar dados locais do app.
                    } label: {
                        Text("Redefinir Dados do Aplicativo")
                            .frame(maxWidth: .infinity)
                    }
                } footer: {
                    Text("Desenvolvido para salvar vidas.\n© 2024 Scanimal Brazil.")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.groupedBackground)
            .navigationTitle("Configurações")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { ScanimalLogo() }
                ToolbarItem(placement: .principal) {
                    Text("Opções")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.onSurfaceVariant)
                }
            }
            .tint(Theme.primary)
        }
    }
}

// MARK: - Linha de configuração reutilizável

private struct SettingsRow<Trailing: View>: View {
    let icon: String
    let tint: Color
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack {
            Label {
                Text(title).foregroundStyle(Theme.onSurface)
            } icon: {
                IconBadge(icon: icon, tint: tint)
            }
            Spacer()
            trailing
        }
    }
}

/// Ícone em "selo" arredondado e colorido (padrão dos Ajustes do iOS).
private struct IconBadge: View {
    let icon: String
    let tint: Color

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 28, height: 28)
            .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

// MARK: - Telas de suporte (placeholders)

private struct ManualView: View {
    var body: some View {
        List {
            Section("Em caso de picada") {
                Text("Mantenha a vítima calma e em repouso.")
                Text("Lave o local com água e sabão.")
                Text("Não faça torniquete nem corte o local.")
                Text("Procure a unidade de saúde mais próxima com soro.")
            }
        }
        .navigationTitle("Primeiros Socorros")
    }
}

private struct HelpView: View {
    var body: some View {
        List {
            Text("Central de Ajuda do Scanimal.")
            Text("Em emergências, ligue 192 (SAMU).")
        }
        .navigationTitle("Central de Ajuda")
    }
}

#Preview {
    SettingsView()
}
