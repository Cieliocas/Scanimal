//
//  SearchViewModel.swift
//  DangerApp / Vitalis
//
//  Lógica da Tela 2 (Pesquisa): dados mockados de hospitais e animais,
//  filtrados pelo texto digitado no campo `.searchable`.
//

import Foundation
import Observation

@Observable
final class SearchViewModel {

    /// Texto da barra de pesquisa.
    var query: String = ""

    // 🔧 Dados estáticos para o teste visual. Em produção, carregar via Node-RED.
    private let allHospitals: [Hospital] = [
        Hospital(name: "Hospital Municipal Miguel Couto", distanceKm: 1.2, isOpen: true),
        Hospital(name: "UPA 24h Copacabana", distanceKm: 3.5, isOpen: true),
        Hospital(name: "Hospital Federal de Bonsucesso", distanceKm: 8.1, isOpen: true)
    ]

    private let allAnimals: [VenomousAnimal] = [
        VenomousAnimal(name: "Jararaca", scientificName: "Bothrops jararaca",
                       level: .veryHigh, symbol: "lizard.fill", tintHex: "4a3b2a"),
        VenomousAnimal(name: "Aranha-Armadeira", scientificName: "Phoneutria nigriventer",
                       level: .extreme, symbol: "ant.fill", tintHex: "2c2c30"),
        VenomousAnimal(name: "Escorpião Amarelo", scientificName: "Tityus serrulatus",
                       level: .venomous, symbol: "ant.fill", tintHex: "8c5000"),
        VenomousAnimal(name: "Coral Verdadeira", scientificName: "Micrurus corallinus",
                       level: .fatal, symbol: "lizard.fill", tintHex: "7a1f1f")
    ]

    /// Hospitais filtrados pela pesquisa.
    var hospitals: [Hospital] {
        guard !trimmedQuery.isEmpty else { return allHospitals }
        return allHospitals.filter { $0.name.localizedCaseInsensitiveContains(trimmedQuery) }
    }

    /// Animais filtrados pela pesquisa (nome comum ou científico).
    var animals: [VenomousAnimal] {
        guard !trimmedQuery.isEmpty else { return allAnimals }
        return allAnimals.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery) ||
            $0.scientificName.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }
}
