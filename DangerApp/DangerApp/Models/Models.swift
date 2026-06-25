//
//  Models.swift
//  DangerApp / Scanimal
//

import Foundation
import CoreLocation

// MARK: - Modelo de Hospital
struct Hospital: Identifiable, Decodable {
    var id: String { name + address }
    
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let isOpen: Bool
    
    /// Corrigido: Não opcional para evitar erros na SearchView
    var distanceKm: Double = 0.0
    
    /// Estoque de antídotos enviados pelo Node-RED
    var availableAntivenoms: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, isOpen, availableAntivenoms
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.isOpen = try container.decode(Bool.self, forKey: .isOpen)
        self.availableAntivenoms = try container.decode([String].self, forKey: .availableAntivenoms)
        self.distanceKm = 0.0
    }
    
    init(name: String, address: String, latitude: Double, longitude: Double, isOpen: Bool, availableAntivenoms: [String], distanceKm: Double = 0.0) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isOpen = isOpen
        self.availableAntivenoms = availableAntivenoms
        self.distanceKm = distanceKm
    }
}

// MARK: - Modelo de Animais Peçonhentos
struct VenomousAnimal: Identifiable {
    var id: String { name }
    let name: String
    let scientificName: String
    let level: DangerLevel
    let symbol: String
    let tintHex: String
<<<<<<< HEAD
}

enum DangerLevel: String {
    case venomous = "Peçonhento"
    case veryHigh = "Muito Alto"
    case extreme = "Extremo"
    case fatal = "Fatal"
}

// MARK: - Modelo de Marcadores do Mapa
struct ThreatMarker: Identifiable, Decodable {
    var id: String { title + "\(coordinate.latitude)-\(coordinate.longitude)" }
    let title: String
    let coordinate: CLLocationCoordinate2D
    let kind: MarkerKind
    
    enum CodingKeys: String, CodingKey {
        case title, latitude, longitude, kind
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D, kind: MarkerKind) {
        self.title = title
        self.coordinate = coordinate
        self.kind = kind
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.kind = try container.decode(MarkerKind.self, forKey: .kind)
        
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
=======
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
>>>>>>> 186f9bd006926be493cdb3e8eca0ddd338bda514
    }
}

enum MarkerKind: String, Decodable {
    case highRisk
    case mediumRisk
    case hospital
}

// MARK: - Modelo do Chat (ChatMessage)
enum MessageRole: String, Codable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Equatable {
    var id: UUID = UUID()
    let text: String
    let isUser: Bool
    var timestamp: Date = Date()
    var imageData: Data? = nil
<<<<<<< HEAD
    
    var role: MessageRole {
        return isUser ? .user : .assistant
    }
    
    init(id: UUID = UUID(), text: String, isUser: Bool, timestamp: Date = Date(), imageData: Data? = nil) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.imageData = imageData
    }
    
    init(text: String, role: MessageRole = .user, imageData: Data? = nil) {
        self.id = UUID()
        self.text = text
        self.isUser = (role == .user)
        self.timestamp = Date()
        self.imageData = imageData
=======

    enum Role {
        case user
        case assistant
        /// Aviso interno do app (ex.: "contexto limpo"). Exibido na tela,
        /// mas nunca enviado como contexto para a IA.
        case system
>>>>>>> 186f9bd006926be493cdb3e8eca0ddd338bda514
    }
}

// MARK: - Extensão Global da String
extension String {
    func whitespacesRemovedAndLowercased() -> String {
        self.replacingOccurrences(of: " ", with: "").lowercased()
    }
}
