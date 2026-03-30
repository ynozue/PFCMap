import SwiftUI
import MapKit

@MainActor
struct FirstPage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = FirstPageModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $model.cameraPosition) {
                    // User location mark
                    UserAnnotation()
                    
                    // 検索結果の表示
                    ForEach(store.shopSearchStore.shops) { shop in
                        Marker(shop.name, coordinate: CLLocationCoordinate2D(
                            latitude: shop.location.latitude,
                            longitude: shop.location.longitude
                        ))
                    }
                }
                .mapStyle(.standard(emphasis: .automatic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                
                if model.isLoading || model.isLoadingSearch {
                    ProgressView()
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("PFC Map")
            .searchable(text: $model.searchText, prompt: "お店を検索")
            .onSubmit(of: .search) {
                Task {
                    await model.searchShops(shopSearchStore: store.shopSearchStore)
                }
            }
            .onChange(of: model.searchText) { oldValue, newValue in
                if newValue.isEmpty {
                    model.clearSearch(shopSearchStore: store.shopSearchStore)
                }
            }
            .task {
                await model.onAppear(locationStore: store.locationStore)
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
}

#Preview {
    FirstPage()
        .environment(PFCMapStore(factory: .create(env: .preview)))
}
