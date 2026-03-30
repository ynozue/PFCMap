import SwiftUI
import MapKit

@MainActor
struct HomePage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = HomePageModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                mapView
                loadingOverlay
            }
            .navigationTitle("PFC Map")
            .task {
                await model.onAppear(locationStore: store.locationStore, shopCatalogStore: store.shopCatalogStore)
            }
            .alert("エラー", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var mapView: some View {
        Map(position: $model.cameraPosition) {
            // User location mark
            UserAnnotation()
            
            searchResultMarkers
        }
        .onMapCameraChange { context in
            model.visibleRegion = context.region
        }
        .mapStyle(.standard(emphasis: .automatic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
    
    @MapContentBuilder
    private var searchResultMarkers: some MapContent {
        ForEach(store.shopSearchStore.results) { result in
            Marker(result.name, coordinate: CLLocationCoordinate2D(
                latitude: result.location.latitude,
                longitude: result.location.longitude
            ))
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if model.isLoading || model.isLoadingSearch {
            ProgressView()
                .padding()
                .background(.thinMaterial)
                .cornerRadius(8)
        }
    }
}

#Preview {
    HomePage()
        .environment(PFCMapStore(factory: .create(env: .preview)))
}
