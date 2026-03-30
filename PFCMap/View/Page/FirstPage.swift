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
                }
                .mapStyle(.standard(emphasis: .automatic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                
                if model.isLoading {
                    ProgressView()
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("PFC Map")
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
