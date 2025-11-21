import SwiftUI

struct AnalyseView: View {
    @ObservedObject var audioManager: AudioManager
    @State private var showFilePicker = false
    @State private var showRecordingView = false
    @State private var navigateToResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if !audioManager.isFileLoaded {
                    // import screen
                    VStack(spacing: 40) {
                        Spacer()
                        
                        // Logo/Title
                        VStack(spacing: 8) {
                            Image("amadeuslogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                            
                            Text("Amadeus")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Harmonic Analysis & Learning")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Main Actions
                        VStack(spacing: 16) {
                            // Import Audio Button
                            Button(action: { showFilePicker = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.title2)
                                    Text("Import Audio File")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            
                            // Record Audio Button  
                            Button(action: { showRecordingView = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "mic.circle")
                                        .font(.title2)
                                    Text("Record New")
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                        
                        // Status
                        Text(audioManager.statusMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    }
                } else {
                    // Navigate to Timeline View
                    TimelineView(audioManager: audioManager)
                }
            }
            .navigationBarHidden(!audioManager.isFileLoaded)
            .sheet(isPresented: $showFilePicker) {
                DocumentPicker { url in
                    audioManager.loadFile(url)
                }
            }
            .sheet(isPresented: $showRecordingView) {
                RecordingView(audioManager: audioManager)
            }
            .overlay(
                // Analysis overlay
                Group {
                    if audioManager.analysisManager.isAnalyzing {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        AnalysisProgressView(
                            status: audioManager.analysisManager.analysisStatus,
                            progress: audioManager.analysisManager.analysisProgress
                        )
                    }
                }
            )
        }
    }
}
