import SwiftUI

struct MainTabView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Analyse Tab
            AnalyseView(audioManager: audioManager)
                .tabItem {
                    Label("Analyse", systemImage: "waveform")
                }
                .tag(0)
            
            // Library Tab
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(1)
            
            // Live Tab
            LiveView()
                .tabItem {
                    Label("Live", systemImage: "mic.circle")
                }
                .tag(2)
            
            // Profile Tab
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