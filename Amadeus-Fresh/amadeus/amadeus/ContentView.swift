//
//  ContentView.swift
//  amadeus
//
//  Created by Cucu on 08/11/2025.
//

import SwiftUI
import AudioKit

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var showFilePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Amadeus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Status
                    Text(audioManager.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                
                // Load Audio Button
                Button(action: { showFilePicker = true }) {
                    Label("Load Audio File", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Test with bundled files - shows all audio files in bundle
                VStack {
                    ForEach(TestHelper.listBundledAudioFiles(), id: \.self) { fileName in
                        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: ".m4a", with: "").replacingOccurrences(of: ".wav", with: ""), 
                                                     withExtension: URL(fileURLWithPath: fileName).pathExtension) {
                            Button(action: { audioManager.loadFile(url) }) {
                                Label("Play: \(fileName)", systemImage: "music.note")
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                if audioManager.isFileLoaded {
                    // Chord Timeline
                    VStack(alignment: .leading) {
                        Text("Chord Timeline")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ChordTimelineView(
                            detections: audioManager.analysisManager.chordDetections,
                            currentTime: audioManager.currentTime,
                            duration: audioManager.duration
                        )
                        .padding(.horizontal)
                    }
                    
                    // Playback Controls
                    PlaybackView(audioManager: audioManager)
                    
                    // Current Chord Display
                    ChordDisplayView(currentChord: audioManager.currentChord)
                    
                    // Speed and Pitch Controls
                    ControlsView(audioManager: audioManager)
                }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker { url in
                audioManager.loadFile(url)
            }
        }
        .overlay(
            // Analysis progress overlay
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

#Preview {
    ContentView()
}
