//
//  SearchView.swift
//  DangerApp / Vitalis
//
//  TELA 2 — Pesquisa. Campo `.searchable` nativo + seções "Hospitais Próximos"
//  (carrossel) e "Animais Comuns" (grid de cards).
//

import SwiftUI // <--- O segredo para corrigir todos os erros da imagem está aqui!
import MapKit

struct SearchView: View {

    @State private var viewModel = SearchViewModel()

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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { VitalisLogo() }
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
                         subtitle: "Identificação rápida na sua região")

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.animals) { animal in
                    AnimalCard(animal: animal)
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

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(hex: animal.tintHex)
            
            Image(systemName: animal.symbol)
                .font(.system(size: 96))
                .foregroundStyle(.white.opacity(0.12))
                .offset(x: 30, y: -10)

            LinearGradient(
                colors: [.black.opacity(0.85), .black.opacity(0.1), .clear],
                startPoint: .bottom, endPoint: .top
            )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Theme.danger)
                        .frame(width: 7, height: 7)
                    Text(animal.level.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white)
                }
                Text(animal.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Text(animal.scientificName)
                    .font(.system(size: 13))
                    .italic()
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(14)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    SearchView()
}
