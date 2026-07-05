//
//  PFCMapApp.swift
//  PFCMap
//
//  Created by ynozue on 2026/03/30.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics

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

        // SwiftData の先行初期化 (ウォームアップ) を非同期に開始
        factory.warmupContainer()

        // Firebase の初期化
        FirebaseApp.configure()
        Analytics.logEvent(AnalyticsEventScreenView, parameters: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isInitialized {
                    if isTutorialCompleted {
                        HomePage(model: factory.makeHomePageModel())
                    } else {
                        TutorialPage(model: factory.makeTutorialPageModel(), isTutorialCompleted: $isTutorialCompleted)
                    }
                } else {
                    SplashPage(model: factory.makeSplashPageModel(), isInitialized: $isInitialized, isTutorialCompleted: $isTutorialCompleted)
                }
            }
            .environment(\.factory, factory)
        }
    }
}
