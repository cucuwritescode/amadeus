//
//  amadeusApp.swift
//  amadeus
//
//  created by facundo franchino on 08/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  main entry point for the amadeus chord recognition app
//  integrates basic pitch neural network for automatic music transcription
//  
//  acknowledgements:
//  - basic pitch model by rachel bittner et al. (icassp 2022)
//  - audiokit framework for audio processing (audiokit.io)
//  - tonic library for music theory representations
//

import SwiftUI

@main
struct amadeusApp: App {
    //main entry point for the amadeus application
    
    init() {
        //initialise basic pitch configuration with default server settings
        //this resets any cached server urls to ensure proper connection
        BasicPitchConfig.resetToDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            //launch the main tab-based navigation view
            //contains analyse, library, live, and profile tabs
            MainTabView()
        }
    }
}
