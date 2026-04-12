//
//  PFCMapApp.swift
//  PFCMap
//
//  Created by ynozue on 2026/03/30.
//

import SwiftUI

@main
struct PFCMapApp: App {
    @State private var isInitialized = false
    let factory: Factory
    
    init() {
        #if DEBUG
        let env: PFCMapEnv = .dev
        #else
        let env: PFCMapEnv = .prod
        #endif
        
        self.factory = Factory.create(env: env)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isInitialized {
                    HomePage()
                } else {
                    SplashPage(isInitialized: $isInitialized)
                }
            }
            .environment(\.factory, factory)
        }
    }
}
