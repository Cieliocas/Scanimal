//
//  SearchViewModel.swift
//  DangerApp / Vitalis
//

import Foundation
import Observation
import CoreLocation

@Observable
final class SearchViewModel: NSObject, CLLocationManagerDelegate {

    var query: String = ""
    var userLocation: CLLocation?
    var isLoading: Bool = false
    var dynamicHospitals: [Hospital] = []
    var selectedAnimalForEmergency: VenomousAnimal? = nil

    private let locationManager = CLLocationManager()

    private let mockHospitals: [Hospital] = [
        Hospital(name: "Hospital Municipal Miguel Couto", address: "Gávea, Rio de Janeiro", latitude: -22.9790, longitude: -43.2245, isOpen: true, availableAntivenoms: ["Jararaca", "Escorpião Amarelo"]),
        Hospital(name: "UPA 24h Copacabana", address: "Copacabana, Rio de Janeiro", latitude: -22.9719, longitude: -43.1843, isOpen: true, availableAntivenoms: ["Aranha-Armadeira"]),
        Hospital(name: "Hospital Federal de Bonsucesso", address: "Bonsucesso, Rio de Janeiro", latitude: -22.8625, longitude: -43.2541, isOpen: true, availableAntivenoms: ["Jararaca", "Coral Verdadeira", "Escorpião Amarelo"])
    ]

    let allAnimals: [VenomousAnimal] = [
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
    }
    
    @MainActor
    func iniciarGPS() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

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

    var hospitals: [Hospital] {
        var filtered = trimmedQuery.isEmpty ? dynamicHospitals : dynamicHospitals.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery) ||
            $0.address.localizedCaseInsensitiveContains(trimmedQuery)
        }
        
        if let emergencyAnimal = selectedAnimalForEmergency {
            filtered = filtered.filter { hospital in
                hospital.availableAntivenoms.contains { antivenom in
                    antivenom.localizedCaseInsensitiveContains(emergencyAnimal.name)
                }
            }
        }
        
        if let userLocation = userLocation {
            return filtered.map { hospital in
                var updatedHospital = hospital
                let hospitalLoc = CLLocation(latitude: hospital.latitude, longitude: hospital.longitude)
                updatedHospital.distanceKm = userLocation.distance(from: hospitalLoc) / 1000.0
                return updatedHospital
            }.sorted {
                $0.distanceKm < $1.distanceKm
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }

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
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        MainActor.assumeIsolated {
            self.userLocation = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao obter localização no SearchViewModel: \(error.localizedDescription)")
    }
}
