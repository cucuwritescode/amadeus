//
//  amadeusApp.swift
//  amadeus
//
//  Created by Cucu on 08/11/2025.
//

import SwiftUI

@main
struct amadeusApp: App {
    // main entry point for the amadeus application
    
    init() {
        // initialise basic pitch configuration with default server settings
        BasicPitchConfig.resetToDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            // launch the main tab-based navigation view
            MainTabView()
        }
    }
}
