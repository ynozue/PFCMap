import SwiftUI
import MapKit

@MainActor
struct HomePage: View {
    @Environment(\.factory) private var factory
    @State private var model = HomePageModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    mapView(height: geometry.size.height)
                    
                    ShopCatalogListView(
                        homeModel: model,
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
                model.onAppear(factory: factory)
            }
            .alert("エラー", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: Binding(get: { model.isMenuShowing }, set: { model.isMenuShowing = $0 }), onDismiss: {
                model.onDismissMenu(factory: factory)
            }) {
                MenuPage()
            }
            .onChange(of: model.mapDistance) { _, newValue in
                model.updateCameraPosition(distance: newValue.rawValue)
            }
        }
    }
    
    private func mapView(height: CGFloat) -> some View {
        Map(position: $model.cameraPosition, selection: $model.selectedResultID) {
            // User location mark
            UserAnnotation()
            
            // 検索範囲の円を描画
            if let currentLocation = model.currentLocation {
                let radius = Double(model.mapDistance.rawValue)
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
                            get: { model.mapDistance },
                            set: { model.updateMapDistance(distance: $0, factory: factory) }
                        )) {
                            ForEach(MapDistance.allCases, id: \.self) { distance in
                                Text(distance.label).tag(distance)
                            }
                        }
                    } label: {
                        Text("\(model.mapDistance.label)")
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
            ForEach(model.searchResults.filter { result in
                guard let currentLocation = model.currentLocation else { return true }
                let radius = Double(model.mapDistance.rawValue)
                return result.location.distance(to: currentLocation) <= radius + 100
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
            presenting: model.searchResults.first(where: { $0.id == model.selectedResultID })
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
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                if !model.loadingMessage.isEmpty {
                    Text(model.loadingMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .background(.thinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    HomePage()
        .environment(\.factory, Factory.create(env: .preview))
}
