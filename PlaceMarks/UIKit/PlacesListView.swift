import SwiftUI

struct PlacesListView: UIViewControllerRepresentable {
    let locations: [MapLocation]
    let onSelect: (MapLocation) -> Void
    let onDelete: (MapLocation) -> Void

    func makeUIViewController(context: Context) -> PlacesListViewController {
        let controller = PlacesListViewController(locations: locations)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: PlacesListViewController, context: Context) {
        controller.update(locations: locations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onDelete: onDelete)
    }

    final class Coordinator: PlacesListDelegate {
        let onSelect: (MapLocation) -> Void
        let onDelete: (MapLocation) -> Void  

        init(onSelect: @escaping (MapLocation) -> Void, onDelete: @escaping (MapLocation) -> Void) {
            self.onSelect = onSelect
            self.onDelete = onDelete
        }

        func placesList(_ controller: PlacesListViewController, didSelect location: MapLocation) {
            onSelect(location)
        }

        func placesList(_ controller: PlacesListViewController, didDelete location: MapLocation) {
            onDelete(location)
        }
    }
}
