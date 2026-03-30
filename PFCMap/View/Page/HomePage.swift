import SwiftUI
import MapKit

@MainActor
struct HomePage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = HomePageModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    mapView
                    loadingOverlay
                    
                    Button {
                        model.isMenuShowing.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 24))
                            .foregroundStyle(.primary)
                            .padding(14)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)
                }
                .safeAreaInset(edge: .bottom) {
                    ShopCatalogListView(
                        shops: store.shopCatalogStore.shops,
                        onSelect: { shop in
                            store.selectedCatalog = shop
                        },
                        onSelectionChange: { shopIds in
                            Task {
                                await model.onShopSelectionChange(
                                    shopIds: shopIds,
                                    shopCatalogStore: store.shopCatalogStore,
                                    shopSearchStore: store.shopSearchStore
                                )
                            }
                        }
                    )
                    .frame(height: 180)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                model.onAppear(locationStore: store.locationStore)
            }
            .alert("エラー", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: Binding(get: { model.isMenuShowing }, set: { model.isMenuShowing = $0 })) {
                MenuPage()
            }
            .sheet(item: Binding<ShopCatalog?>(
                get: { store.selectedCatalog },
                set: { store.selectedCatalog = $0 }
            )) { shop in
                ShopItemListPage(shop: shop)
            }
        }
    }
    
    private var mapView: some View {
        Map(position: $model.cameraPosition) {
            // User location mark
            UserAnnotation()
            
            // Search Results
            ForEach(store.shopSearchStore.results) { result in
                Marker(result.name, coordinate: CLLocationCoordinate2D(
                    latitude: result.location.latitude,
                    longitude: result.location.longitude
                ))
            }
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
