import MapKit
import Foundation
import SwiftUI
import LocalAuthentication

@Observable
final class ContentViewModel {
    let context = LAContext()
    var isUnlocked = false
    let position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    var locations: [MapLocation]
    var selectedLocation: MapLocation?

    var styleOption: MapStyleOption = .standard
    var authError: String?
    func getMapStyle() -> MapStyle {
        styleOption == .hybrid ? MapStyle.hybrid : styleOption == .imagery ? MapStyle.imagery : MapStyle.standard
    }

    func cycleMapStyle() {
        switch styleOption {
        case .standard: styleOption = .hybrid
        case .hybrid:   styleOption = .imagery
        case .imagery:  styleOption = .standard
        }
        print(styleOption)
    }

    let savedPath = URL.documentsDirectory.appending(path: "SavedPlaces")

    init() {
        do {
            let data = try Data(contentsOf: savedPath)
            locations = try JSONDecoder().decode([MapLocation].self, from: data)
        } catch {
            locations = []
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(locations)
            try data.write(to: savedPath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }

    func lock() {
        selectedLocation = nil
        isUnlocked = false
    }

    func authenticate() {
        var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Please authenticate yourself to unlock your places"

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    Task { @MainActor in
                        if success {
                            self.isUnlocked = true
                            self.authError = nil
                        } else {
                            self.authError = self.message(for: authenticationError)
                        }
                    }
                }
            } else {
                authError = "Set a device passcode in Settings to unlock places."
            }

    }

    private func message(for error: Error?) -> String? {
        guard let laError = error as? LAError else { return nil }
        switch laError.code {
        case .userCancel, .userFallback, .systemCancel: return nil
        case .biometryLockout: return "Too many failed attempts. Use your passcode instead."
        default: return "Authentication failed. Please try again."
        }
    }

#if DEBUG
    static let example = MapLocation(id: UUID(), name: "Buckingham Palace", description: "Lit by over 40,000 lightbulbs.", latitude: 51.501, longitude: -0.141)
#endif
}
