import SwiftUI
import MapKit

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var showingPlacesList = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if viewModel.isUnlocked {
                NavigationStack {
                    MapReader { proxy in
                        Map(initialPosition: viewModel.position) {
                            ForEach(viewModel.locations) { location in
                                Annotation(location.name, coordinate: location.coordinate) {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .foregroundStyle(.red)
                                        .frame(width: 44, height: 44)
                                        .backgroundStyle(.white)
                                        .clipShape(.circle)
                                        .onLongPressGesture {
                                            viewModel.selectedLocation = location
                                        }
                                }
                            }
                        }
                        .mapStyle(viewModel.getMapStyle())
                        .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .local) {
                                let newLocation = MapLocation(id: UUID(), name: "New Location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                                viewModel.locations.append(newLocation)
                                viewModel.save()
                            }
                        }
                        .sheet(item: $viewModel.selectedLocation) { location in
                            DetailView(location: location) { newLocation in
                                if let index = viewModel.locations.firstIndex(of: location) {
                                    viewModel.locations[index] = newLocation
                                    viewModel.save()
                                }
                            }
                        }
                        .toolbar {
                            Button("Change layout", systemImage: "map") {
                                viewModel.cycleMapStyle()
                            }
                            Button("List", systemImage: "list.bullet") {
                                showingPlacesList = true
                            }

                        }
                    }
                    .sheet(isPresented: $showingPlacesList) {
                        NavigationStack {
                            PlacesListView(
                                locations: viewModel.locations,
                                onSelect: { selected in
                                    showingPlacesList = false
                                    viewModel.selectedLocation = selected
                                },
                                onDelete: { deleted in
                                    viewModel.locations.removeAll { $0.id == deleted.id }
                                    viewModel.save()
                                }
                            )
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Close") { showingPlacesList = false }
                                }
                            }
                        }
                    }
                }
            } else {
                Button("Unlock places", action: viewModel.authenticate)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                showingPlacesList = false
                viewModel.lock()
            }
        }
        .alert("Authentication failed", isPresented: Binding(
            get: { viewModel.authError != nil },
            set: { if !$0 { viewModel.authError = nil } }
        )) {
            Button("OK") { }
        } message: {
            Text(viewModel.authError ?? "")
        }
    }
}

#Preview {
    ContentView()
}
