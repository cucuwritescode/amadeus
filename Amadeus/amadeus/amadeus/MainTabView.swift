import SwiftUI

// main navigation structure with tab-based interface
struct MainTabView: View {
    // shared audio manager instance for all tabs
    @StateObject private var audioManager = AudioManager()
    // currently selected tab index
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // analyse tab
            AnalyseView(audioManager: audioManager)
                .tabItem {
                    Label("Analyse", systemImage: "waveform")
                }
                .tag(0)
            
            // library tab
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(1)
            
            // live tab
            LiveView()
                .tabItem {
                    Label("Live", systemImage: "mic.circle")
                }
                .tag(2)
            
            // profile tab
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