import SwiftUI
import MapKit

@MainActor
struct FirstPage: View {
    @Environment(PFCMapStore.self) private var store
    @State private var model = FirstPageModel()
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("PFC Map")
        }
    }
}

#Preview {
    FirstPage()
        .environment(PFCMapStore(factory: .create(env: .preview)))
}
