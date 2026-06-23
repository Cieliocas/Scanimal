//
//  SearchViewModel.swift
//  DangerApp / Vitalis
//
//  Lógica da Tela 2 (Pesquisa): calcula a distância real dos hospitais via GPS,
//  permite filtragem textual, ordena pelos mais próximos e consome dados do Node-RED.
//

import Foundation
import Observation
import CoreLocation

@Observable
final class SearchViewModel: NSObject, CLLocationManagerDelegate {

    /// Texto da barra de pesquisa.
    var query: String = ""
    
    /// Localização atual do usuário obtida pelo GPS.
    var userLocation: CLLocation?
    
    /// Estado de carregamento da API.
    var isLoading: Bool = false

    /// Lista dinâmica carregada a partir do Node-RED.
    var dynamicHospitals: [Hospital] = []

    private let locationManager = CLLocationManager()

    // 🏥 BACKUP/MOCK: Usado se o Node-RED estiver offline ou antes da API responder.
    private let mockHospitals: [Hospital] = [
        Hospital(name: "Hospital Municipal Miguel Couto", address: "Gávea, Rio de Janeiro", latitude: -22.9790, longitude: -43.2245, isOpen: true),
        Hospital(name: "UPA 24h Copacabana", address: "Copacabana, Rio de Janeiro", latitude: -22.9719, longitude: -43.1843, isOpen: true),
        Hospital(name: "Hospital Federal de Bonsucesso", address: "Bonsucesso, Rio de Janeiro", latitude: -22.8625, longitude: -43.2541, isOpen: true)
    ]

    // 🐍 Lista de animais peçonhentos
    private let allAnimals: [VenomousAnimal] = [
        VenomousAnimal(name: "Jararaca", scientificName: "Bothrops jararaca", level: .veryHigh, symbol: "lizard.fill", tintHex: "4a3b2a"),
        VenomousAnimal(name: "Aranha-Armadeira", scientificName: "Phoneutria nigriventer", level: .extreme, symbol: "ant.fill", tintHex: "2c2c30"),
        VenomousAnimal(name: "Escorpião Amarelo", scientificName: "Tityus serrulatus", level: .venomous, symbol: "ant.fill", tintHex: "8c5000"),
        VenomousAnimal(name: "Coral Verdadeira", scientificName: "Micrurus corallinus", level: .fatal, symbol: "lizard.fill", tintHex: "7a1f1f")
    ]

    override init() {
        super.init()
        self.dynamicHospitals = mockHospitals
        setupLocation()
    }

    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    /// Baixa a lista de hospitais atualizada direto do seu fluxo IBM Node-RED.
    @MainActor
    func carregarHospitaisDoNodeRed() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let list: [Hospital] = try await NetworkService.shared.get("/hospitais")
            if !list.isEmpty {
                self.dynamicHospitals = list
            }
        } catch {
            print("Erro ao buscar hospitais do Node-RED: \(error.localizedDescription). Mantendo locais.")
        }
        
        isLoading = false
    }

    /// Hospitais filtrados pelo campo de busca E ordenados por proximidade do GPS.
    var hospitals: [Hospital] {
        let filtered = trimmedQuery.isEmpty ? dynamicHospitals : dynamicHospitals.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery) ||
            $0.address.localizedCaseInsensitiveContains(trimmedQuery)
        }
        
        if let userLocation = userLocation {
            return filtered.map { hospital in
                var updatedHospital = hospital
                let hospitalLoc = CLLocation(latitude: hospital.latitude, longitude: hospital.longitude)
                updatedHospital.distanceKm = userLocation.distance(from: hospitalLoc) / 1000.0
                return updatedHospital
            }.sorted { $0.distanceKm < $1.distanceKm }
        }
        
        return filtered
    }

    /// Animais filtrados pela pesquisa. Fix para evitar conflito com Predicate no iOS 17+.
    var animals: [VenomousAnimal] {
        let busca = trimmedQuery.whitespacesRemovedAndLowercased()
        guard !busca.isEmpty else { return allAnimals }
        
        return allAnimals.filter { animal in
            let nomeNormalizado = animal.name.whitespacesRemovedAndLowercased()
            let cientificoNormalizado = animal.scientificName.whitespacesRemovedAndLowercased()
            return nomeNormalizado.contains(busca) || cientificoNormalizado.contains(busca)
        }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao obter localização: \(error.localizedDescription)")
    }
}

// Auxiliar para ajudar na busca de texto tirando espaços
extension String {
    func whitespacesRemovedAndLowercased() -> String {
        self.replacingOccurrences(of: " ", with: "").lowercased()
    }
}
