//
//  Models.swift
//  DangerApp / Vitalis
//
//  Modelos de dados simples usados pelas telas. Dados reais virão do Node-RED;
//  por enquanto usamos estruturas estáticas (mock) para o teste visual.
//

import Foundation
import CoreLocation

// MARK: - Mapa

/// Nível/Tipo de um ponto exibido no mapa.
enum ThreatKind {
    case highRisk   // Ocorrência de animal de alto risco (ex.: escorpião)
    case mediumRisk // Ocorrência de risco médio (ex.: serpente avistada)
    case hospital   // Unidade de saúde com soro

    var symbol: String {
        switch self {
        case .highRisk:   return "ant.fill"
        case .mediumRisk: return "lizard.fill"
        case .hospital:   return "cross.case.fill"
        }
    }
}

/// Marcador renderizado no mapa (zona de ameaça, ocorrência ou hospital).
struct ThreatMarker: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let kind: ThreatKind
}

// MARK: - Pesquisa

/// Hospital / unidade de saúde com soro antiofídico.
struct Hospital: Identifiable {
    let id = UUID()
    let name: String
    let distanceKm: Double
    let isOpen: Bool
}

/// Grau de periculosidade exibido no card do animal.
enum VenomLevel: String {
    case fatal     = "RISCO FATAL"
    case extreme   = "EXTREMO PERIGO"
    case veryHigh  = "ALTAMENTE VENENOSA"
    case venomous  = "VENENOSO"
}

/// Animal peçonhento comum na região.
struct VenomousAnimal: Identifiable {
    let id = UUID()
    let name: String
    let scientificName: String
    let level: VenomLevel
    let symbol: String   // SF Symbol representativo
    let tintHex: String  // tom de fundo do card
}

// MARK: - Chat

/// Mensagem da conversa com a IA (via Node-RED).
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let text: String
    var imageData: Data? = nil

    enum Role {
        case user
        case assistant
    }
}

// MARK: - Localização

/// Wrapper Equatable para a coordenada do usuário (facilita `onChange`).
struct UserLocation: Equatable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    /// Coordenada padrão (São Paulo) usada quando ainda não temos a localização real.
    static let saoPaulo = CLLocationCoordinate2D(latitude: -23.5558, longitude: -46.6396)
}
