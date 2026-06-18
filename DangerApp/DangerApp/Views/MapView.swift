//
//  MapView.swift
//  DangerApp / Vitalis
//
//  TELA 1 — Home / Mapa de Ameaças.
//  Usa o MapKit moderno (Map + MapCameraPosition), exibe a localização do
//  usuário (UserAnnotation) e marcadores de ocorrências/hospitais.
//

import SwiftUI
import MapKit

struct MapView: View {

    @State private var locationManager = LocationManager()
    @State private var viewModel = MapViewModel()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: .saoPaulo,
                           latitudinalMeters: 4000,
                           longitudinalMeters: 4000)
    )

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
                .ignoresSafeArea()
            overlay
        }
        .onAppear { locationManager.requestPermission() }
        .onChange(of: locationManager.lastLocation) { _, location in
            guard let coordinate = location?.coordinate else { return }
            viewModel.generateMarkers(around: coordinate)
            withAnimation(.easeInOut) {
                cameraPosition = .region(
                    MKCoordinateRegion(center: coordinate,
                                       latitudinalMeters: 3500,
                                       longitudinalMeters: 3500)
                )
            }
        }
        .task {
            // Garante marcadores visíveis já na inicialização (caso sem permissão).
            if viewModel.markers.isEmpty {
                viewModel.generateMarkers(around: .saoPaulo)
            }
        }
    }

    // MARK: Mapa

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            ForEach(viewModel.markers) { marker in
                Annotation(marker.title, coordinate: marker.coordinate) {
                    MarkerBadge(kind: marker.kind)
                }
            }
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
        }
    }

    // MARK: Sobreposições (barra + card de risco + botão localizar)

    private var overlay: some View {
        VStack(spacing: 12) {
            VitalisHeader {
                CircleIconButton(systemName: "person.crop.circle")
            }

            RiskCard(level: viewModel.riskLevel)
                .padding(.horizontal, 16)

            Spacer()

            HStack {
                Spacer()
                LocateMeButton {
                    if let coordinate = locationManager.lastLocation?.coordinate {
                        withAnimation {
                            cameraPosition = .region(
                                MKCoordinateRegion(center: coordinate,
                                                   latitudinalMeters: 3000,
                                                   longitudinalMeters: 3000)
                            )
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Card flutuante de risco

private struct RiskCard: View {
    let level: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.danger)
                .frame(width: 40, height: 40)
                .background(Theme.danger.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("RISCO NA SUA REGIÃO")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(0.6)
                    .foregroundStyle(Theme.onSurfaceVariant)
                Text(level)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.danger)
            }

            Spacer()

            Button {
                // 🔧 Acionar fluxo de emergência (ex.: ligar 192 / abrir chat).
            } label: {
                Text("Emergência")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Theme.danger, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
    }
}

// MARK: - Marcador customizado do mapa

private struct MarkerBadge: View {
    let kind: ThreatKind

    private var color: Color {
        switch kind {
        case .highRisk:   return Theme.danger
        case .mediumRisk: return Theme.warning
        case .hospital:   return Theme.primary
        }
    }

    var body: some View {
        Image(systemName: kind.symbol)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(color, in: Circle())
            .overlay(Circle().stroke(.white, lineWidth: 2))
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
    }
}

// MARK: - Botão "minha localização"

private struct LocateMeButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "location.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.primary)
                .frame(width: 48, height: 48)
                .background(.regularMaterial, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MapView()
}
