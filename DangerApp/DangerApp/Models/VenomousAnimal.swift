//
//  VenomousAnimal.swift
//  DangerApp / Scanimal
//
//  Animal peçonhento e seu grau de periculosidade.
//

import Foundation

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
