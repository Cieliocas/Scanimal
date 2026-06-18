//
//  MapViewModel.swift
//  DangerApp / Vitalis
//
//  Lógica da Tela 1 (Home / Mapa): nível de risco e marcadores mockados.
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

    /// Gera pontos mockados ao redor de uma coordenada (ex.: o usuário) para
    /// que o mapa já renderize ocorrências na inicialização.
    /// 🔧 Em produção, substituir por um GET no Node-RED (ex.: "/ocorrencias?lat=..&lon=..").
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
