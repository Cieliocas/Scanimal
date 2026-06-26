//
//  ThreatMarker.swift
//  DangerApp / Scanimal
//
//  Modelos do Mapa: tipo de ameaça e marcador renderizado.
//

import Foundation
import CoreLocation

/// Nível/Tipo de um ponto exibido no mapa.
enum ThreatKind: String, Decodable {
    case highRisk   = "highRisk"   // Ocorrência de animal de alto risco (ex.: escorpião)
    case mediumRisk = "mediumRisk" // Ocorrência de risco médio (ex.: serpente avistada)
    case hospital   = "hospital"   // Unidade de saúde com soro

    var symbol: String {
        switch self {
        case .highRisk:   return "ant.fill"
        case .mediumRisk: return "lizard.fill"
        case .hospital:   return "cross.case.fill"
        }
    }
}

/// Marcador renderizado no mapa (zona de ameaça, ocorrência ou hospital).
struct ThreatMarker: Identifiable, Decodable {
    var id = UUID()
    let title: String
    let latitude: Double
    let longitude: Double
    let kind: ThreatKind

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case title, latitude, longitude, kind
    }

    // Inicializador manual para os Mocks locais do MapViewModel
    init(title: String, coordinate: CLLocationCoordinate2D, kind: ThreatKind) {
        self.title = title
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.kind = kind
        self.id = UUID()
    }

    // Inicializador para decodificar o JSON vindo do Node-RED
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.kind = try container.decode(ThreatKind.self, forKey: .kind)
        self.id = UUID()
    }
}
