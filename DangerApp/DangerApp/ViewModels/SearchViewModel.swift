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

    /// Animal selecionado em uma emergência: filtra os hospitais que têm o antídoto.
    var selectedAnimalForEmergency: VenomousAnimal? = nil

    private let locationManager = CLLocationManager()

    // 🏥 BACKUP/MOCK: Usado se o Node-RED estiver offline ou antes da API responder.
    private let mockHospitals: [Hospital] = [
        Hospital(name: "Hospital Municipal Miguel Couto", address: "Gávea, Rio de Janeiro", latitude: -22.9790, longitude: -43.2245, isOpen: true, availableAntivenoms: ["Jararaca", "Escorpião-Amarelo"]),
        Hospital(name: "UPA 24h Copacabana", address: "Copacabana, Rio de Janeiro", latitude: -22.9719, longitude: -43.1843, isOpen: true, availableAntivenoms: ["Aranha-Armadeira"]),
        Hospital(name: "Hospital Federal de Bonsucesso", address: "Bonsucesso, Rio de Janeiro", latitude: -22.8625, longitude: -43.2541, isOpen: true, availableAntivenoms: ["Jararaca", "Coral-Verdadeira", "Escorpião-Amarelo"])
    ]

    // 🐍 Os 30 animais peçonhentos mais comuns em acidentes no Brasil.
    // Mock local. A API (Node-RED) integrada futuramente traz ~9 deles (inclusive no mapa).
    // `imageName` referencia os imagesets em Assets.xcassets/Animals (convenção "imageNomeAnimal").
    private let allAnimals: [VenomousAnimal] = [
        // Serpentes
        VenomousAnimal(name: "Jararaca", scientificName: "Bothrops jararaca", level: .veryHigh, symbol: "lizard.fill", tintHex: "4a3b2a", imageName: "imageJararacaComum"),
        VenomousAnimal(name: "Jararaca-do-Norte", scientificName: "Bothrops atrox", level: .veryHigh, symbol: "lizard.fill", tintHex: "3f3a2a", imageName: "imageJararacaDoNorte"),
        VenomousAnimal(name: "Jararacuçu", scientificName: "Bothrops jararacussu", level: .veryHigh, symbol: "lizard.fill", tintHex: "3a4a2a", imageName: "imageJararacucu"),
        VenomousAnimal(name: "Jararaca-Pintada", scientificName: "Bothrops neuwiedi", level: .veryHigh, symbol: "lizard.fill", tintHex: "4a4530", imageName: "imageJararacaPintada"),
        VenomousAnimal(name: "Caiçaca", scientificName: "Bothrops moojeni", level: .veryHigh, symbol: "lizard.fill", tintHex: "44402a", imageName: "imageCaicaca"),
        VenomousAnimal(name: "Urutu-Cruzeiro", scientificName: "Bothrops alternatus", level: .veryHigh, symbol: "lizard.fill", tintHex: "4a3a30", imageName: "imageUrutuCruzeiro"),
        VenomousAnimal(name: "Cascavel", scientificName: "Crotalus durissus", level: .fatal, symbol: "lizard.fill", tintHex: "6b5a2a", imageName: "imageCascavel"),
        VenomousAnimal(name: "Surucucu-Pico-de-Jaca", scientificName: "Lachesis muta", level: .fatal, symbol: "lizard.fill", tintHex: "5a4030", imageName: "imageSurucucuPicoDeJaca"),
        VenomousAnimal(name: "Coral-Verdadeira", scientificName: "Micrurus corallinus", level: .fatal, symbol: "lizard.fill", tintHex: "7a1f1f", imageName: "imageCoralVerdadeira"),
        VenomousAnimal(name: "Coral-Verdadeira-da-Amazônia", scientificName: "Micrurus spixii", level: .fatal, symbol: "lizard.fill", tintHex: "6e1f23", imageName: "imageCoralAmazonia"),
        // Aranhas
        VenomousAnimal(name: "Aranha-Armadeira", scientificName: "Phoneutria nigriventer", level: .extreme, symbol: "ant.fill", tintHex: "2c2c30", imageName: "imageAranhaArmadeira"),
        VenomousAnimal(name: "Aranha-Armadeira-Amazônica", scientificName: "Phoneutria fera", level: .extreme, symbol: "ant.fill", tintHex: "26262b", imageName: "imageAranhaArmadeiraDaAmazonia"),
        VenomousAnimal(name: "Aranha-Marrom-Paulista", scientificName: "Loxosceles laeta", level: .extreme, symbol: "ant.fill", tintHex: "4a2c1a", imageName: "imageAranhaMarromPaulista"),
        VenomousAnimal(name: "Aranha-Marrom-Comum", scientificName: "Loxosceles intermedia", level: .extreme, symbol: "ant.fill", tintHex: "402616", imageName: "imageAranhaMarromComum"),
        VenomousAnimal(name: "Viúva-Negra", scientificName: "Latrodectus curacaviensis", level: .veryHigh, symbol: "ant.fill", tintHex: "1a1a1a", imageName: "imageViuvaNegra"),
        VenomousAnimal(name: "Viúva-Marrom", scientificName: "Latrodectus geometricus", level: .venomous, symbol: "ant.fill", tintHex: "3a2c20", imageName: "imageViuvaMarrom"),
        VenomousAnimal(name: "Aranha-de-Grama", scientificName: "Lycosa erythrognatha", level: .venomous, symbol: "ant.fill", tintHex: "2a3a2a", imageName: "imageAranhaDaGrama"),
        VenomousAnimal(name: "Caranguejeira", scientificName: "Família Theraphosidae", level: .venomous, symbol: "ant.fill", tintHex: "3a2a2a", imageName: "imageCaranguejeira"),
        // Escorpiões
        VenomousAnimal(name: "Escorpião-Amarelo", scientificName: "Tityus serrulatus", level: .veryHigh, symbol: "ant.fill", tintHex: "8c5000", imageName: "imageEscorpiaoAmarelo"),
        VenomousAnimal(name: "Escorpião-Amarelo-do-Nordeste", scientificName: "Tityus stigmurus", level: .veryHigh, symbol: "ant.fill", tintHex: "7a4a10", imageName: "imageEscorpiaoAmareloDoNordeste"),
        VenomousAnimal(name: "Escorpião-Marrom", scientificName: "Tityus bahiensis", level: .venomous, symbol: "ant.fill", tintHex: "4a3320", imageName: "imageEscorpiaoMarrom"),
        VenomousAnimal(name: "Escorpião-Preto-da-Amazônia", scientificName: "Tityus obscurus", level: .veryHigh, symbol: "ant.fill", tintHex: "222226", imageName: "imageEscorpiaoPretoDaAmazonia"),
        // Insetos e lagartas
        VenomousAnimal(name: "Taturana-Assassina", scientificName: "Lonomia obliqua", level: .fatal, symbol: "ant.fill", tintHex: "5a6a2a", imageName: "imageTaturanaAssassina"),
        VenomousAnimal(name: "Abelha-Africanizada", scientificName: "Apis mellifera", level: .venomous, symbol: "ant.fill", tintHex: "8a6a10", imageName: "imageAbelhaAfricanizada"),
        VenomousAnimal(name: "Marimbondo-Tatu", scientificName: "Synoeca cyanea", level: .venomous, symbol: "ant.fill", tintHex: "243038", imageName: "imageMarimbondoTatu"),
        VenomousAnimal(name: "Marimbondo-Cavalo", scientificName: "Polistes spp.", level: .venomous, symbol: "ant.fill", tintHex: "7a5a15", imageName: "imageMarimbondoCavalo"),
        VenomousAnimal(name: "Formiga-Tocandira", scientificName: "Paraponera clavata", level: .venomous, symbol: "ant.fill", tintHex: "2e2622", imageName: "imageFormigaCaboVerde"),
        VenomousAnimal(name: "Formiga-Lava-Pés", scientificName: "Solenopsis invicta", level: .venomous, symbol: "ant.fill", tintHex: "7a2a1a", imageName: "imageFormigaLavaPes"),
        // Outros
        VenomousAnimal(name: "Lacraia", scientificName: "Scolopendra spp.", level: .venomous, symbol: "ant.fill", tintHex: "6a3a2a", imageName: "imageLacraia"),
        VenomousAnimal(name: "Arraia-de-Água-Doce", scientificName: "Potamotrygon spp.", level: .veryHigh, symbol: "fish.fill", tintHex: "3a4a5a", imageName: "imageArraiaDeAguaDoce")
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

    /// Solicita a permissão e começa a rastrear a localização. Chamado pela tela
    /// ao aparecer, para pedir o acesso ao GPS no momento certo.
    @MainActor
    func iniciarGPS() {
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
    /// Quando há um animal selecionado para emergência, restringe aos que têm o antídoto.
    var hospitals: [Hospital] {
        var filtered = trimmedQuery.isEmpty ? dynamicHospitals : dynamicHospitals.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery) ||
            $0.address.localizedCaseInsensitiveContains(trimmedQuery)
        }

        // Emergência: mostra só os hospitais com soro/antídoto para o animal escolhido.
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
