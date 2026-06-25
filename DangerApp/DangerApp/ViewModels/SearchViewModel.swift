//
//  SearchViewModel.swift
//  DangerApp / Scanimal
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

    // 🐍 Lista de animais peçonhentos mais envolvidos em acidentes domésticos no Brasil.
    // Mock local (24 espécies). A API integrada futuramente traz ~9 deles (inclusive no mapa).
    // `imageName` referencia os imagesets em Assets.xcassets/Animals — arraste as fotos lá.
    private let allAnimals: [VenomousAnimal] = [
        // Serpentes
        VenomousAnimal(name: "Jararaca", scientificName: "Bothrops jararaca", level: .veryHigh, symbol: "lizard.fill", tintHex: "4a3b2a", imageName: "jararaca"),
        VenomousAnimal(name: "Jararacuçu", scientificName: "Bothrops jararacussu", level: .veryHigh, symbol: "lizard.fill", tintHex: "3a4a2a", imageName: "jararacucu"),
        VenomousAnimal(name: "Cascavel", scientificName: "Crotalus durissus", level: .fatal, symbol: "lizard.fill", tintHex: "6b5a2a", imageName: "cascavel"),
        VenomousAnimal(name: "Surucucu", scientificName: "Lachesis muta", level: .fatal, symbol: "lizard.fill", tintHex: "5a4030", imageName: "surucucu"),
        VenomousAnimal(name: "Coral Verdadeira", scientificName: "Micrurus corallinus", level: .fatal, symbol: "lizard.fill", tintHex: "7a1f1f", imageName: "coralVerdadeira"),
        // Aranhas
        VenomousAnimal(name: "Aranha-Armadeira", scientificName: "Phoneutria nigriventer", level: .extreme, symbol: "ant.fill", tintHex: "2c2c30", imageName: "aranhaArmadeira"),
        VenomousAnimal(name: "Aranha-Marrom", scientificName: "Loxosceles gaucho", level: .extreme, symbol: "ant.fill", tintHex: "4a2c1a", imageName: "aranhaMarrom"),
        VenomousAnimal(name: "Viúva-Negra", scientificName: "Latrodectus curacaviensis", level: .veryHigh, symbol: "ant.fill", tintHex: "1a1a1a", imageName: "viuvaNegra"),
        VenomousAnimal(name: "Caranguejeira", scientificName: "Grammostola rosea", level: .venomous, symbol: "ant.fill", tintHex: "3a2a2a", imageName: "caranguejeira"),
        VenomousAnimal(name: "Aranha-de-Jardim", scientificName: "Lycosa erythrognatha", level: .venomous, symbol: "ant.fill", tintHex: "2a3a2a", imageName: "aranhaDeJardim"),
        // Escorpiões
        VenomousAnimal(name: "Escorpião Amarelo", scientificName: "Tityus serrulatus", level: .veryHigh, symbol: "ant.fill", tintHex: "8c5000", imageName: "escorpiaoAmarelo"),
        VenomousAnimal(name: "Escorpião Preto", scientificName: "Tityus bahiensis", level: .venomous, symbol: "ant.fill", tintHex: "2a2a2a", imageName: "escorpiaoPreto"),
        VenomousAnimal(name: "Escorpião-do-Nordeste", scientificName: "Tityus stigmurus", level: .venomous, symbol: "ant.fill", tintHex: "7a4a10", imageName: "escorpiaoNordeste"),
        // Insetos e lagartas
        VenomousAnimal(name: "Taturana", scientificName: "Lonomia obliqua", level: .veryHigh, symbol: "ant.fill", tintHex: "5a6a2a", imageName: "taturana"),
        VenomousAnimal(name: "Abelha Africanizada", scientificName: "Apis mellifera", level: .venomous, symbol: "ant.fill", tintHex: "8a6a10", imageName: "abelhaAfricanizada"),
        VenomousAnimal(name: "Marimbondo", scientificName: "Polybia paulista", level: .venomous, symbol: "ant.fill", tintHex: "6a4a10", imageName: "marimbondo"),
        VenomousAnimal(name: "Vespa", scientificName: "Polistes versicolor", level: .venomous, symbol: "ant.fill", tintHex: "7a5a15", imageName: "vespa"),
        VenomousAnimal(name: "Formiga Lava-Pés", scientificName: "Solenopsis invicta", level: .venomous, symbol: "ant.fill", tintHex: "7a2a1a", imageName: "formigaLavaPes"),
        VenomousAnimal(name: "Potó", scientificName: "Paederus sp.", level: .venomous, symbol: "ant.fill", tintHex: "2a3a3a", imageName: "poto"),
        // Outros
        VenomousAnimal(name: "Lacraia", scientificName: "Scolopendra viridicornis", level: .venomous, symbol: "ant.fill", tintHex: "6a3a2a", imageName: "lacraia"),
        VenomousAnimal(name: "Sapo-Cururu", scientificName: "Rhinella diptycha", level: .venomous, symbol: "lizard.fill", tintHex: "4a5a3a", imageName: "sapoCururu"),
        VenomousAnimal(name: "Caramujo-Africano", scientificName: "Achatina fulica", level: .venomous, symbol: "ant.fill", tintHex: "5a4a3a", imageName: "caramujoAfricano"),
        VenomousAnimal(name: "Arraia-de-Água-Doce", scientificName: "Potamotrygon motoro", level: .veryHigh, symbol: "fish.fill", tintHex: "3a4a5a", imageName: "arraiaDeAguaDoce"),
        VenomousAnimal(name: "Carrapato-Estrela", scientificName: "Amblyomma sculptum", level: .venomous, symbol: "ant.fill", tintHex: "5a3a2a", imageName: "carrapatoEstrela")
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
