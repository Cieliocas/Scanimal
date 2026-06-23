//
//  MapView.swift
//  DangerApp / Vitalis
//

import SwiftUI
import MapKit

struct MapView: View {
    // Uso correto do @State para gerenciar classes estruturadas em @Observable (iOS 17+)
    @State private var viewModel = MapViewModel()
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -23.55052, longitude: -46.633308),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    ForEach(viewModel.markers) { marker in
                        Marker(marker.title, coordinate: marker.coordinate)
                            .tint(marker.kind == .hospital ? .blue : .red)
                    }
                }
                .navigationTitle("Hospitais & Riscos")
                .navigationBarTitleDisplayMode(.inline)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            .task {
                let centroAtual = CLLocationCoordinate2D(latitude: -23.55052, longitude: -46.633308)
                await viewModel.carregarMarcadoresDoNodeRed(around: centroAtual)
            }
        }
    }
}
