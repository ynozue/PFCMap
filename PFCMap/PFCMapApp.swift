//
//  PFCMapApp.swift
//  PFCMap
//
//  Created by ynozue on 2026/03/30.
//

import SwiftUI

@main
struct PFCMapApp: App {
    @State private var store: PFCMapStore
    
    init() {
        #if DEBUG
        let env: PFCMapEnv = .dev
        #else
        let env: PFCMapEnv = .prod
        #endif
        
        let factory = Factory.create(env: env)
        _store = State(wrappedValue: PFCMapStore(factory: factory))
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if store.isInitialized {
                    MapPage()
                } else {
                    SplashPage()
                }
            }
            .environment(store)
        }
    }
}
