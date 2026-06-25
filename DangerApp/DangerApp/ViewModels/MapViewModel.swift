//  MapViewModel.swift
//  DangerApp / Vitalis
//

import Foundation
import CoreLocation
import Observation

@Observable
final class MapViewModel {

    /// Marcadores filtrados que serão REALMENTE exibidos no mapa ao redor do usuário
    var markers: [ThreatMarker] = []
    
    /// Guarda a lista bruta de TODOS os animais vindos do Node-RED (sem filtro)
    private var allRemoteMarkers: [ThreatMarker] = []

    var riskLevel: String = "ALTO"
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var currentLocation: CLLocationCoordinate2D? = nil
    let defaultLocation = CLLocationCoordinate2D(latitude: -5.0616, longitude: -42.7948)

    var activeLocation: CLLocationCoordinate2D {
        return currentLocation ?? defaultLocation
    }

    /// Busca a lista completa do Node-RED (só roda uma vez ou quando necessário)
    @MainActor
    func carregarMarcadoresDoNodeRed(around center: CLLocationCoordinate2D) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // A rota bate no Node-RED e traz TUDO do banco
            let path = "/getameacas"
            let marcadoresRemotos: [ThreatMarker] = try await NetworkService.shared.get(path)
            
            if marcadoresRemotos.isEmpty {
                generateMarkers(around: center)
            } else {
                // Guarda a lista completa na memória
                self.allRemoteMarkers = marcadoresRemotos
                // Aplica o filtro de proximidade baseado onde o usuário está agora
                filtrarMarcadoresPorProximidade(around: center)
            }
        } catch {
            self.errorMessage = "Node-RED offline. Usando dados locais."
            print("Erro de conexão ao Node-RED: \(error.localizedDescription)")
            generateMarkers(around: center)
        }
        
        isLoading = false
    }
    
    /// Atualiza a localização e filtra os animais dinamicamente sem fazer uma nova requisição de internet
    @MainActor
    func atualizarLocalizacaoAtual(_ location: CLLocationCoordinate2D) async {
        self.currentLocation = location
        
        if !allRemoteMarkers.isEmpty {
            // Se já baixamos os dados do Node-RED, só recalculamos a distância localmente (instantâneo!)
            filtrarMarcadoresPorProximidade(around: location)
        } else {
            // Se for a primeira vez, busca da API
            await carregarMarcadoresDoNodeRed(around: location)
        }
    }

    /// Filtra a lista local para exibir apenas animais em um raio de até 10km do usuário
    private func filtrarMarcadoresPorProximidade(around center: CLLocationCoordinate2D) {
        let userLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let raioMaximoMetros: Double = 10000 // 10 Quilômetros
        
        self.markers = allRemoteMarkers.filter { marker in
            let markerLocation = CLLocation(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
            // Calcula a distância real em metros levando em conta a curvatura da Terra
            let distancia = userLocation.distance(from: markerLocation)
            return distancia <= raioMaximoMetros
        }
        
        // Ajusta o RiskLevel baseado em quantos perigos tem por perto
        if markers.count > 3 {
            self.riskLevel = "ALTO"
        } else if markers.isEmpty {
            self.riskLevel = "BAIXO"
        } else {
            self.riskLevel = "MÉDIO"
        }
    }

    func generateMarkers(around center: CLLocationCoordinate2D) {
        markers = [
            ThreatMarker(title: "Escorpião Amarelo", coordinate: offset(center, dLat:  0.0045, dLon: -0.0032), kind: .highRisk),
            ThreatMarker(title: "Jararaca Identificada", coordinate: offset(center, dLat: -0.0050, dLon:  0.0048), kind: .mediumRisk),
            ThreatMarker(title: "Aranha-Armadeira", coordinate: offset(center, dLat:  0.0028, dLon:  0.0060), kind: .highRisk),
            ThreatMarker(title: "Pronto Socorro Central", coordinate: offset(center, dLat: -0.0030, dLon: -0.0055), kind: .hospital)
        ]
    }

    private func offset(_ c: CLLocationCoordinate2D, dLat: Double, dLon: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: c.latitude + dLat, longitude: c.longitude + dLon)
    }
}
