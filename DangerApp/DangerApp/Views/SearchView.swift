//
//  SearchView.swift
//  DangerApp / Scanimal
//
//  TELA 2 — Pesquisa. Campo `.searchable` nativo + seções "Hospitais Próximos"
//  (carrossel) e "Animais Comuns" (grid de cards).
//

import SwiftUI // <--- O segredo para corrigir todos os erros da imagem está aqui!
import MapKit

struct SearchView: View {

    @State private var viewModel = SearchViewModel()

    /// Animal exibido em tela cheia (toque no card abre a imagem completa).
    @State private var detailAnimal: VenomousAnimal?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        // Criamos o wrapper dinâmico para que o .searchable consiga fazer o Binding ($viewModel.query)
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    hospitalsSection
                    animalsSection
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Theme.background)
            .onAppear { viewModel.iniciarGPS() }
            .sheet(item: $detailAnimal) { animal in
                AnimalDetailView(animal: animal) {
                    // "Ver hospitais com antídoto": ativa o filtro de emergência e fecha.
                    viewModel.selectedAnimalForEmergency = animal
                    detailAnimal = nil
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { ScanimalLogo() }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "person.crop.circle")
                        .foregroundStyle(Theme.onSurfaceVariant)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Hospitais, animais ou primeiros socorros"
            )
            .tint(Theme.primary)
        }
    }

    // MARK: Hospitais Próximos (carrossel horizontal)

    private var hospitalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Hospitais Próximos",
                         subtitle: "Unidades com soro antiofídico")
                .padding(.horizontal, 16)

            // Filtro de emergência ativo: hospitais com antídoto para o animal escolhido.
            if let emergency = viewModel.selectedAnimalForEmergency {
                Button {
                    viewModel.selectedAnimalForEmergency = nil
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "cross.case.fill")
                        Text("Emergência: \(emergency.name)")
                            .fontWeight(.semibold)
                        Image(systemName: "xmark.circle.fill")
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.onPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Theme.danger, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.hospitals) { hospital in
                        HospitalCard(hospital: hospital)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: Animais Comuns (grid 2 colunas)

    private var animalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "Animais Comuns",
                         subtitle: "Toque para ver a foto e os detalhes")

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.animals) { animal in
                    Button {
                        detailAnimal = animal
                    } label: {
                        AnimalCard(animal: animal,
                                   isSelected: viewModel.selectedAnimalForEmergency?.id == animal.id)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Título de seção (estilo large title)

private struct SectionTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.onSurface)
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundStyle(Theme.onSurfaceVariant)
        }
    }
}

// MARK: - Card de hospital

private struct HospitalCard: View {
    let hospital: Hospital

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(hospital.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.onSurface)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if hospital.isOpen {
                    Text("ABERTO")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Theme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.primary.opacity(0.12), in: Capsule())
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                Text(String(format: "%.1f km de você", hospital.distanceKm))
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(Theme.onSurfaceVariant)

            Spacer(minLength: 0)

            Button {
                openRouteInMaps(for: hospital)
            } label: {
                Label("Navegar", systemImage: "location.north.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.primary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 280, height: 176, alignment: .top)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.outlineVariant.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 12, y: 8)
    }

    private func openRouteInMaps(for hospital: Hospital) {
        let coordinate = CLLocationCoordinate2D(latitude: hospital.latitude, longitude: hospital.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = hospital.name
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

// MARK: - Card de animal

private struct AnimalCard: View {
    let animal: VenomousAnimal
    var isSelected: Bool = false

    var body: some View {
        // A cor base define o tamanho do card (preenche a célula da grade, altura fixa).
        // Imagem, gradiente e textos vão como OVERLAYS — não influenciam o tamanho,
        // então a foto nunca "estica" o card nem invade os vizinhos.
        Color(hex: animal.tintHex)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            // Marca d'água (SF Symbol) — fallback visual enquanto a foto não carrega.
            .overlay {
                Image(systemName: animal.symbol)
                    .font(.system(size: 96))
                    .foregroundStyle(.white.opacity(0.12))
                    .offset(x: 30, y: -10)
            }
            // Foto do animal (Assets.xcassets/Animals/<imageName>), recortada ao card.
            .overlay {
                if let imageName = animal.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.85), .black.opacity(0.1), .clear],
                    startPoint: .bottom, endPoint: .top
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Theme.danger)
                            .frame(width: 7, height: 7)
                        Text(animal.level.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    Text(animal.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(animal.scientificName)
                        .font(.system(size: 13))
                        .italic()
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.danger, lineWidth: isSelected ? 3 : 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
}

// MARK: - Detalhe do animal (imagem completa + ação de emergência)

private struct AnimalDetailView: View {
    let animal: VenomousAnimal
    /// Acionado pelo botão "Ver hospitais com antídoto".
    var onEmergency: () -> Void

    @Environment(\.dismiss) private var dismiss

    /// Estado do zoom por pinça na imagem.
    @State private var zoom: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Imagem completa (scaledToFit mostra a foto inteira, sem cortar).
                    ZStack {
                        Color.black
                        if let imageName = animal.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(zoom)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { zoom = max(1.0, $0) }
                                        .onEnded { _ in withAnimation { zoom = 1.0 } }
                                )
                        } else {
                            Image(systemName: animal.symbol)
                                .font(.system(size: 90))
                                .foregroundStyle(.white.opacity(0.3))
                                .frame(height: 320)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 320)
                    .clipped()

                    // Infos
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Circle().fill(Theme.danger).frame(width: 8, height: 8)
                            Text(animal.level.rawValue.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(Theme.danger)
                        }

                        Text(animal.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Theme.onSurface)

                        Text(animal.scientificName)
                            .font(.system(size: 16))
                            .italic()
                            .foregroundStyle(Theme.onSurfaceVariant)

                        Button(action: onEmergency) {
                            Label("Ver hospitais com antídoto", systemImage: "cross.case.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.onPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.danger, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
            }
            .background(Theme.background)
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white, .black.opacity(0.4))
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
