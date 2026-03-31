import SwiftUI
import MapKit

@MainActor
struct HomePage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = HomePageModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    mapView(height: geometry.size.height)
                    
                    ShopCatalogListView(
                        shops: store.shopCatalogStore.shops,
                        maxHeight: geometry.size.height,
                        onSelect: { shop in
                            // 必要に応じて地図への移動処理などをここに追加可能
                        }
                    )
                    
                    loadingOverlay
                    
                    // Location Button Overlay
                    VStack {
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
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                model.onAppear(store: store)
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
            .onChange(of: store.settingsStore.mapDistance) { _, newValue in
                model.updateCameraPosition(distance: newValue.rawValue, store: store)
            }
        }
    }
    
    private func mapView(height: CGFloat) -> some View {
        Map(position: $model.cameraPosition, selection: $model.selectedResultID) {
            // User location mark
            UserAnnotation()
            
            // 検索範囲の円を描画
            if let currentLocation = store.locationStore.currentLocation {
                let radius = Double(store.settingsStore.mapDistance.rawValue)
                MapCircle(center: currentLocation.coordinate, radius: CLLocationDistance(radius))
                    .foregroundStyle(.blue.opacity(0.15))
                    .stroke(.blue, lineWidth: 1)
                
                // 半径のラベルを円の右斜め上に表示（60度方向）
                let radian = 60.0 * Double.pi / 180.0
                let latOffset = (radius * sin(radian)) / 111320.0
                let lonOffset = (radius * cos(radian)) / (111320.0 * cos(currentLocation.coordinate.latitude * Double.pi / 180.0))
                
                let upperRight = CLLocationCoordinate2D(
                    latitude: currentLocation.coordinate.latitude + latOffset,
                    longitude: currentLocation.coordinate.longitude + lonOffset
                )
                
                Annotation("", coordinate: upperRight, anchor: .bottomLeading) {
                    Menu {
                        Picker("距離を選択", selection: Binding(
                            get: { store.settingsStore.mapDistance },
                            set: { model.updateMapDistance(distance: $0, store: store) }
                        )) {
                            ForEach(MapDistance.allCases, id: \.self) { distance in
                                Text(distance.label).tag(distance)
                            }
                        }
                    } label: {
                        Text("\(store.settingsStore.mapDistance.label)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.85))
                            .clipShape(Capsule())
                            .overlay {
                                Capsule().stroke(.blue.opacity(0.4), lineWidth: 0.5)
                            }
                    }
                }
            }
            
            // Search Results
            ForEach(store.shopSearchStore.results.filter { result in
                guard let currentLocation = store.locationStore.currentLocation else { return true }
                return result.location.distance(to: currentLocation) <= 2000
            }) { result in
                Marker(result.name, coordinate: CLLocationCoordinate2D(
                    latitude: result.location.latitude,
                    longitude: result.location.longitude
                ))
                .tag(result.id)
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
        .contentMargins(.bottom, height / 5)
        .alert(
            model.canOpenAppleMaps() || model.canOpenGoogleMaps() ? "経路案内" : "マップアプリが見つかりません",
            isPresented: Binding(
                get: { model.selectedResultID != nil },
                set: { if !$0 { model.selectedResultID = nil } }
            ),
            presenting: store.shopSearchStore.results.first(where: { $0.id == model.selectedResultID })
        ) { result in
            if model.canOpenAppleMaps() {
                Button("Apple マップで表示") {
                    model.openInMaps(result: result)
                    model.selectedResultID = nil
                }
            }
            if model.canOpenGoogleMaps() {
                Button("Google マップで表示") {
                    model.openInGoogleMaps(result: result)
                    model.selectedResultID = nil
                }
            }
            if !model.canOpenAppleMaps() && !model.canOpenGoogleMaps() {
                Button("Google マップをインストール") {
                    model.openAppStoreForGoogleMaps()
                    model.selectedResultID = nil
                }
            }
            Button("キャンセル", role: .cancel) {
                model.selectedResultID = nil
            }
        } message: { result in
            if model.canOpenAppleMaps() || model.canOpenGoogleMaps() {
                Text("\(result.name) までの経路をマップアプリで表示しますか？")
            } else {
                Text("経路案内を利用するには、マップアプリをインストールしてください。")
            }
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
