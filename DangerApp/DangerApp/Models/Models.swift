//
//  Models.swift
//  DangerApp / Vitalis
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
    }
}

// MARK: - Extensão Global da String
extension String {
    func whitespacesRemovedAndLowercased() -> String {
        self.replacingOccurrences(of: " ", with: "").lowercased()
    }
}
