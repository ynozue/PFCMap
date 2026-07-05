import SwiftUI
import MapKit

@MainActor
struct HomePage: View {
    @Environment(\.factory) private var factory
    @State private var model: HomePageModel

    init(model: HomePageModel) {
        self._model = State(wrappedValue: model)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    mapView(height: geometry.size.height)
                    
                    if model.selectedResultID != nil {
                        routeDetailCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        ShopCatalogListView(
                            homeModel: model,
                            maxHeight: geometry.size.height,
                            onSelect: { shop in
                                if let result = model.searchResults.first(where: { $0.query == shop.name }) {
                                    withAnimation {
                                        model.selectedResultID = result.id
                                    }
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
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
                model.onAppear()
            }
            .alert("エラー", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("位置情報の利用", isPresented: $model.showLocationPermissionAlert) {
                Button("設定を開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("現在地情報が取得できないため東京駅周辺を表示します。現在地を利用するには設定から位置情報の利用を許可してください。")
            }
            .sheet(isPresented: Binding(get: { model.isMenuShowing }, set: { model.isMenuShowing = $0 }), onDismiss: {
                model.onDismissMenu()
            }) {
                MenuPage(model: factory.makeMenuPageModel())
            }
            .onChange(of: model.mapDistance) { _, newValue in
                model.updateCameraPosition(distance: newValue.rawValue)
            }
            .onChange(of: model.selectedResultID) { _, newValue in
                if let newValue, let result = model.searchResults.first(where: { $0.id == newValue }) {
                    model.logViewShopDetail(shopName: result.name)
                    model.calculateRouteToSelectedResult()
                } else {
                    withAnimation {
                        model.selectedRoute = nil
                        model.selectedRouteDuration = nil
                        model.selectedRouteDistance = nil
                    }
                }
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
                            set: { model.updateMapDistance(distance: $0) }
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
            
            // アプリ内経路の描画
            if let route = model.selectedRoute {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
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
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if model.isLoading {
            ZStack {
                // 背景を薄く暗くしてインジケーターを際立たせる
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ZStack {
                        // 索敵しているような波紋エフェクト
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                            .frame(width: 40, height: 40)
                            .phaseAnimator([1.0, 2.5]) { content, phase in
                                content
                                    .scaleEffect(phase)
                                    .opacity(phase == 1.0 ? 0.4 : 0)
                            } animation: { phase in
                                .linear(duration: 1.2).repeatForever(autoreverses: false)
                            }

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.blue)
                            // 覗き込んで探しているようなアニメーション
                            .phaseAnimator([0, 1, 2, 3]) { content, phase in
                                content
                                    .offset(
                                        x: phase == 1 ? 12 : (phase == 3 ? -12 : 0),
                                        y: phase == 0 ? -6 : (phase == 2 ? 6 : 0)
                                    )
                                    .rotationEffect(.degrees(phase == 1 ? 20 : (phase == 3 ? -10 : 5)))
                            } animation: { phase in
                                .easeInOut(duration: 0.8)
                            }
                    }
                    .frame(width: 80, height: 80)
                    
                    if !model.loadingMessage.isEmpty {
                        Text(model.loadingMessage)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.blue.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(28)
                .background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.white.opacity(0.5), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .zIndex(100)
        }
    }
    
    @ViewBuilder
    private var routeDetailCard: some View {
        if let selectedResultID = model.selectedResultID,
           let result = model.searchResults.first(where: { $0.id == selectedResultID }),
           let duration = model.selectedRouteDuration,
           let distance = model.selectedRouteDistance {
            
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            Label("徒歩 \(Int(ceil(duration / 60)))分", systemImage: "figure.walk")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.blue)
                            
                            Text("•")
                                .foregroundStyle(.secondary)
                            
                            Text(model.distanceString(distance))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            model.selectedResultID = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                
                HStack(spacing: 12) {
                    if model.canOpenAppleMaps() {
                        Button {
                            model.openInMaps(result: result)
                        } label: {
                            HStack {
                                Image(systemName: "map")
                                Text("Apple マップ")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundStyle(.primary)
                        }
                    }
                    
                    if model.canOpenGoogleMaps() {
                        Button {
                            model.openInGoogleMaps(result: result)
                        } label: {
                            HStack {
                                Image(systemName: "location.circle")
                                Text("Google マップ")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.4), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

#Preview("通常時") {
    let factory = Factory.create(env: .preview)
    return HomePage(model: factory.makeHomePageModel())
        .environment(\.factory, factory)
}

#Preview("ローディング中") {
    let factory = Factory.create(env: .preview)
    let model = factory.makeHomePageModel()
    model.isLoading = true
    model.loadingMessage = "周辺の店舗を探索しています..."
    return HomePage(model: model)
        .environment(\.factory, factory)
}

