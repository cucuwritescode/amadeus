//
//  MainTabView.swift
//  amadeus
//
//  created by facundo franchino on 08/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  main navigation structure providing tab-based interface
//  implements four core modules: analysis, library, live mode, and user profile
//

import SwiftUI

//main navigation structure with tab-based interface
struct MainTabView: View {
    //shared audio manager instance for all tabs
    //handles audio playback and processing across the app
    @StateObject private var audioManager = AudioManager()
    //currently selected tab index for navigation tracking
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            //analyse tab, primary feature for audio file analysis
            //processes audio through basic pitch neural network
            AnalyseView(audioManager: audioManager)
                .tabItem {
                    Label("Analyse", systemImage: "waveform")
                }
                .tag(0)
            
            //library tab, chord dictionary and music theory reference
            //includes chord voicings, progressions, and scale information
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(1)
            
            //live tab, real-time chord detection from microphone
            //records 30-second chunks for immediate analysis
            LiveView()
                .tabItem {
                    Label("Live", systemImage: "mic.circle")
                }
                .tag(2)
            
            //profile tab, user settings and app configuration
            //manages analysis engine selection and help resources
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
