//
//  LocationManager.swift
//  DangerApp / Vitalis
//
//  Encapsula o CLLocationManager para solicitar permissão e fornecer a
//  localização do usuário de forma reativa (macro @Observable).
//

import Foundation
import CoreLocation
import Observation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {

    /// Última localização conhecida do usuário (Equatable, ideal para `onChange`).
    var lastLocation: UserLocation?

    /// Status atual da autorização de localização.
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // O status inicial será atualizado imediatamente pelo delegado 'locationManagerDidChangeAuthorization'
    }

    /// Solicita permissão "Quando em uso" de forma assíncrona e segura para a Main Thread.
    @MainActor
    func requestPermission() {
        // Dispara diretamente o pedido nativo da Apple.
        // Se o usuário já respondeu no passado, o iOS gerencia e apenas ignora visualmente.
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate
    // Os callbacks chegam na thread principal (manager criado na main),
    // por isso usamos `MainActor.assumeIsolated` para atualizar o estado observável.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            self.authorizationStatus = manager.authorizationStatus
            
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        MainActor.assumeIsolated {
            self.lastLocation = UserLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro no CoreLocation: \(error.localizedDescription)")
    }
}
