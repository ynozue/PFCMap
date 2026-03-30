import SwiftUI
import MapKit

@MainActor
struct HomePage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = HomePageModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    mapView
                    loadingOverlay
                }
                .safeAreaInset(edge: .bottom) {
                    ShopListView(shops: store.shopCatalogStore.shops) { shop in
                        // ショップ選択時のアクション（詳細画面への遷移など）をここに記述
                    }
                    .frame(height: geometry.size.height / 4)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
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
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if model.isLoading {
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
