//
//  MapViewModel.swift
//  DangerApp / Vitalis
//
//  Lógica da Tela 1 (Home / Mapa): nível de risco e marcadores integrados à API.
//

import Foundation
import CoreLocation
import Observation

@Observable
final class MapViewModel {

    /// Marcadores (ocorrências e hospitais) exibidos sobre o mapa.
    var markers: [ThreatMarker] = []

    /// Nível de risco da região, mostrado no card flutuante.
    var riskLevel: String = "ALTO"
    
    /// Estado de carregamento da API
    var isLoading: Bool = false
    
    /// Mensagem de erro caso a conexão falhe
    var errorMessage: String? = nil

    /// Busca as ocorrências reais salvas no backend IBM Node-RED.
    @MainActor
    func carregarMarcadoresDoNodeRed(around center: CLLocationCoordinate2D) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let path = "/ocorrencias?lat=\(center.latitude)&lon=\(center.longitude)"
            let marcadoresRemotos: [ThreatMarker] = try await NetworkService.shared.get(path)
            
            if marcadoresRemotos.isEmpty {
                generateMarkers(around: center)
            } else {
                self.markers = marcadoresRemotos
            }
        } catch {
            self.errorMessage = "Node-RED offline. Usando dados locais."
            print("Erro de conexão ao Node-RED: \(error.localizedDescription)")
            generateMarkers(around: center)
        }
        
        isLoading = false
    }

    /// Gera pontos mockados caso a API falhe ou esteja indisponível.
    func generateMarkers(around center: CLLocationCoordinate2D) {
        markers = [
            ThreatMarker(title: "Escorpião Amarelo",
                         coordinate: offset(center, dLat:  0.0045, dLon: -0.0032),
                         kind: .highRisk),
            ThreatMarker(title: "Jararaca Identificada",
                         coordinate: offset(center, dLat: -0.0050, dLon:  0.0048),
                         kind: .mediumRisk),
            ThreatMarker(title: "Aranha-Armadeira",
                         coordinate: offset(center, dLat:  0.0028, dLon:  0.0060),
                         kind: .highRisk),
            ThreatMarker(title: "Pronto Socorro Central",
                         coordinate: offset(center, dLat: -0.0030, dLon: -0.0055),
                         kind: .hospital)
        ]
    }

    private func offset(_ c: CLLocationCoordinate2D, dLat: Double, dLon: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: c.latitude + dLat, longitude: c.longitude + dLon)
    }
}
