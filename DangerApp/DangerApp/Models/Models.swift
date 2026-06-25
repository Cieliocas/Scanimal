//
//  Models.swift
//  DangerApp / Scanimal
//
//  Modelos de dados integrados de forma nativa usados pelas telas.
//

import Foundation
import CoreLocation

// MARK: - Mapa

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

// MARK: - Pesquisa

/// Hospital / unidade de saúde com soro antiofídico integrado ao GPS.
struct Hospital: Identifiable, Decodable {
    var id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    var distanceKm: Double = 0.0
    let isOpen: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, isOpen
    }
    
    // Inicializador manual para os Mocks locais do SearchViewModel
    init(name: String, address: String = "", latitude: Double, longitude: Double, isOpen: Bool) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isOpen = isOpen
        self.distanceKm = 0.0
        self.id = UUID()
    }
    
    // Inicializador para decodificar o JSON vindo do Node-RED
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.isOpen = try container.decode(Bool.self, forKey: .isOpen)
        self.distanceKm = 0.0
        self.id = UUID()
    }
}

/// Grau de periculosidade exibido no card do animal.
enum VenomLevel: String, Decodable {
    case fatal     = "RISCO FATAL"
    case extreme   = "EXTREMO PERIGO"
    case veryHigh  = "ALTAMENTE VENENOSA"
    case venomous  = "VENENOSO"
}

/// Animal peçonhento comum na região.
struct VenomousAnimal: Identifiable, Decodable {
    var id = UUID()
    let name: String
    let scientificName: String
    let level: VenomLevel
    let symbol: String
    let tintHex: String
    /// Nome do imageset nos Assets (ex.: "jararaca"). Opcional: enquanto a foto
    /// não é adicionada, o card usa o `symbol` (SF Symbol) como fallback visual.
    let imageName: String?

    enum CodingKeys: String, CodingKey {
        case name, scientificName, level, symbol, tintHex, imageName
    }

    init(name: String, scientificName: String, level: VenomLevel, symbol: String, tintHex: String, imageName: String? = nil) {
        self.name = name
        self.scientificName = scientificName
        self.level = level
        self.symbol = symbol
        self.tintHex = tintHex
        self.imageName = imageName
        self.id = UUID()
    }

    // Inicializador para decodificar o JSON vindo da API (imageName é opcional).
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.scientificName = try container.decode(String.self, forKey: .scientificName)
        self.level = try container.decode(VenomLevel.self, forKey: .level)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.tintHex = try container.decode(String.self, forKey: .tintHex)
        self.imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
        self.id = UUID()
    }
}

// MARK: - Payloads da Rede (Chat)

struct ChatRequest: Encodable {
    let message: String
    let imageBase64: String?
}

struct ChatResponse: Decodable {
    let reply: String
}

// MARK: - Interface do Chat

/// Mensagem da conversa com a IA.
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let text: String
    var imageData: Data? = nil

    enum Role {
        case user
        case assistant
        /// Aviso interno do app (ex.: "contexto limpo"). Exibido na tela,
        /// mas nunca enviado como contexto para a IA.
        case system
    }
}

// MARK: - Localização

/// Wrapper Equatable para a coordenada do usuário.
struct UserLocation: Equatable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    static let saoPaulo = CLLocationCoordinate2D(latitude: -23.5558, longitude: -46.6396)
}
