import Combine
import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var latestLocation: CLLocation?
    @Published private(set) var locationName: String = MockDailyData.location
    @Published private(set) var authorizationMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        authorizationStatus = manager.authorizationStatus

        if isAuthorized {
            manager.requestLocation()
        }
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var isDeniedOrRestricted: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    var usesSampleLocation: Bool {
        latestLocation == nil || !isAuthorized
    }

    func requestAuthorization() {
        authorizationMessage = nil

        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied:
            authorizationMessage = "Location access was denied. You can continue with the sample location or enable access later in Settings."
        case .restricted:
            authorizationMessage = "Location access is restricted on this device. You can continue with the sample location."
        @unknown default:
            authorizationMessage = "Location is unavailable right now. You can continue with the sample location."
        }
    }

    func useSampleLocation() {
        latestLocation = nil
        locationName = MockDailyData.location
        authorizationMessage = nil
    }

    private func updateLocationName(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            Task { @MainActor in
                guard let self else { return }

                if let placemark = placemarks?.first {
                    let city = placemark.locality ?? placemark.subLocality
                    let region = placemark.administrativeArea

                    if let city, let region {
                        self.locationName = "\(city), \(region)"
                    } else if let city {
                        self.locationName = city
                    } else {
                        self.locationName = MockDailyData.location
                    }
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus

            switch authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                authorizationMessage = nil
                manager.requestLocation()
            case .denied:
                authorizationMessage = "Location access was denied. You can continue with the sample location."
                useSampleLocation()
            case .restricted:
                authorizationMessage = "Location access is restricted on this device. You can continue with the sample location."
                useSampleLocation()
            case .notDetermined:
                break
            @unknown default:
                authorizationMessage = "Location is unavailable right now. You can continue with the sample location."
                useSampleLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            latestLocation = location
            updateLocationName(for: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            authorizationMessage = "Location could not be updated. Sample location is still available."
        }
    }
}
