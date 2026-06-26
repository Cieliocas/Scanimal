//
//  Hospital.swift
//  DangerApp / Scanimal
//
//  Unidade de saúde com soro antiofídico, integrada ao GPS e ao Node-RED.
//

import Foundation
import CoreLocation

/// Hospital / unidade de saúde com soro antiofídico integrado ao GPS.
struct Hospital: Identifiable, Decodable {
    var id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    var distanceKm: Double = 0.0
    let isOpen: Bool
    /// Estoque de antídotos/soros disponíveis (enviado pelo Node-RED). Usado para
    /// filtrar hospitais por animal em uma emergência.
    var availableAntivenoms: [String] = []

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, isOpen, availableAntivenoms
    }

    // Inicializador manual para os Mocks locais do SearchViewModel
    init(name: String, address: String = "", latitude: Double, longitude: Double, isOpen: Bool, availableAntivenoms: [String] = []) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isOpen = isOpen
        self.availableAntivenoms = availableAntivenoms
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
        self.availableAntivenoms = try container.decodeIfPresent([String].self, forKey: .availableAntivenoms) ?? []
        self.distanceKm = 0.0
        self.id = UUID()
    }
}
