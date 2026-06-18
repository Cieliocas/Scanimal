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
        authorizationStatus = manager.authorizationStatus
    }

    /// Solicita permissão "Quando em uso" e começa a obter a localização.
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // MARK: CLLocationManagerDelegate
    // Os callbacks chegam na thread principal (manager criado na main),
    // por isso usamos `MainActor.assumeIsolated` para atualizar o estado observável.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        MainActor.assumeIsolated {
            lastLocation = UserLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Em produção: tratar/registrar o erro. Para o protótipo, ignoramos.
    }
}
