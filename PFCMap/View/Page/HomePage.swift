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
                    ShopListView(shops: store.shopCatalogStore.shops) { shop in
                        // ショップ選択時のアクション（詳細画面への遷移など）をここに記述
                    }
                    .frame(height: geometry.size.height / 4)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
            .sheet(isPresented: Binding(get: { model.isMenuShowing }, set: { model.isMenuShowing = $0 })) {
                MenuPage()
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
