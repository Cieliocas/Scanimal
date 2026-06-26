//
//  UserLocation.swift
//  DangerApp / Scanimal
//
//  Wrapper de localização do usuário e coordenadas de referência.
//

import Foundation
import CoreLocation

/// Wrapper Equatable para a coordenada do usuário.
struct UserLocation: Equatable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    static let saoPaulo = CLLocationCoordinate2D(latitude: -23.5558, longitude: -46.6396)
}
