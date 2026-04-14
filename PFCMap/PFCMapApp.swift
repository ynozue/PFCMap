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
    @State private var isTutorialCompleted = false
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
                    if isTutorialCompleted {
                        HomePage()
                    } else {
                        TutorialPage(isTutorialCompleted: $isTutorialCompleted)
                    }
                } else {
                    SplashPage(isInitialized: $isInitialized, isTutorialCompleted: $isTutorialCompleted)
                }
            }
            .environment(\.factory, factory)
        }
    }
}
