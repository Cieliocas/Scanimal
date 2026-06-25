//
//  MapView.swift
//  DangerApp / Vitalis
//

import SwiftUI
import MapKit

struct MapView: View {
    // Uso correto do @State para gerenciar classes estruturadas em @Observable (iOS 17+)
    @State private var viewModel = MapViewModel()
    
    // Instanciando o gerenciador de localização que criamos
    @State private var locationManager = LocationManager()
    
    // Posição inicial da câmera (usa a localização padrão do viewModel até o GPS responder)
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Adicionamos 'showsUserLocation' para mostrar a bolinha azul nativa do GPS
                Map(position: $position) {
                    ForEach(viewModel.markers) { marker in
                        Marker(marker.title, coordinate: marker.coordinate)
                            .tint(marker.kind == .hospital ? .blue : .red)
                    }
                }
                .mapControls {
                    MapUserLocationButton() // Botão nativo para focar no usuário quando ele se mover
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
            // Dispara o pedido de permissão assim que a View aparece na tela
            .onAppear {
                locationManager.requestPermission()
            }
            // Fica "escutando" as mudanças de localização vindas do GPS do aparelho
            .onChange(of: locationManager.lastLocation) { _, newLocation in
                if let newLocation = newLocation {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: newLocation.latitude,
                        longitude: newLocation.longitude
                    )
                    
                    // Atualiza a câmera do mapa para focar na nova posição com um efeito suave
                    withAnimation {
                        position = .region(
                            MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            )
                        )
                    }
                    
                    // Alimenta o ViewModel para atualizar as coordenadas e buscar os dados da API
                    Task {
                        await viewModel.atualizarLocalizacaoAtual(coordinate)
                    }
                }
            }
            // Carrega marcadores padrão/iniciais caso queira garantir dados antes do GPS responder
            .task {
                await viewModel.carregarMarcadoresDoNodeRed(around: viewModel.activeLocation)
            }
        }
    }
}
