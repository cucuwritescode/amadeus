//
//  TimelineView.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  main analysis results view with waveform, playback controls, and chord display
//  provides transport controls, speed/pitch adjustment, and export options
//
//

import SwiftUI

//primary view for displaying analysis results and controlling playback
struct TimelineView: View {
    @ObservedObject var audioManager: AudioManager
    @State private var isDraggingPlayhead = false
    @State private var draggedTime: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                //header with key and current chord
                HeaderSection(audioManager: audioManager)
                
                //waveform and chord timeline
                WaveformSection(audioManager: audioManager)
                    .frame(height: 200)
                
                //playback controls
                PlaybackSection(audioManager: audioManager)
                
                //speed and pitch controls
                ControlsSection(audioManager: audioManager)
                
                //export/share options
                ActionsSection(audioManager: audioManager)
            }
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    //stop playback and analysis
                    audioManager.stop()
                    audioManager.showAnalysisLoading = false
                    audioManager.showAnalysisComplete = false
                    audioManager.analysisManager.reset()
                    
                    //reset file state
                    audioManager.isFileLoaded = false
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareButton(audioManager: audioManager)
            }
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            //current chord disp(large)
            VStack(spacing: 8) {
                Text(audioManager.currentChord)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.amadeusBlue)
                    .shadow(color: .amadeusBlue.opacity(0.3), radius: 4, y: 2)
                
                Text("Current Chord")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            
            //key info
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original Key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Text(audioManager.originalKey)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                if audioManager.pitchShift != 0 {
                    Divider()
                        .frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Transposed (\(audioManager.pitchShift > 0 ? "+" : "")\(audioManager.pitchShift))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        Text(audioManager.currentKey)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.amadeusBlue)
                    }
                }
            }
            .cardStyle()
        }
        .padding()
    }
}

// MARK: - Waveform Section
struct WaveformSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 12) {
            //waveform with tap-to-seek
            WaveformVisualization(audioManager: audioManager)
                .frame(height: 85)
                .background(Color.black.opacity(0.05))
                .cornerRadius(12)
            
            //current chord piano view
            CurrentChordPianoView(audioManager: audioManager)
        }
        .padding(.horizontal)
    }
}

// MARK: - Waveform Visualization
struct WaveformVisualization: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //waveform bars
                HStack(spacing: 2) {
                    ForEach(0..<50) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: (geometry.size.width / 50) - 2,
                                height: CGFloat.random(in: 20...80)
                            )
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
                // progress overlay
                if audioManager.duration > 0 {
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: (audioManager.currentTime / audioManager.duration) * geometry.size.width)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .animation(.linear(duration: 0.5), value: audioManager.currentTime)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                //tap to seek, calculate position relative to waveform
                guard audioManager.duration > 0 else { return }
                let ratio = max(0, min(1, location.x / geometry.size.width))
                let seekTime = ratio * audioManager.duration
                print("🎯 Tap to seek: x=\(location.x), width=\(geometry.size.width), ratio=\(ratio), time=\(seekTime)")
                audioManager.seek(to: seekTime)
            }
        }
    }
}

// MARK: - Playback Section
struct PlaybackSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            //time display
            HStack {
                Text(formatTime(audioManager.currentTime))
                    .font(.system(.body, design: .monospaced))
                
                ProgressView(value: audioManager.currentTime, total: max(audioManager.duration, 1))
                    .progressViewStyle(LinearProgressViewStyle())
                
                Text(formatTime(audioManager.duration))
                    .font(.system(.body, design: .monospaced))
            }
            .padding(.horizontal)
            
            // playback controls
            HStack(spacing: 40) {
                Button(action: { 
                    // skip backward exactly 5 seconds
                    let targetTime = audioManager.currentTime - 5.0
                    audioManager.seek(to: targetTime)
                }) {
                    Image(systemName: "gobackward.5")
                        .font(.title2)
                }
                
                Button(action: { audioManager.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
                
                Button(action: { 
                    //skip forward exactly 5 seconds
                    let targetTime = audioManager.currentTime + 5.0
                    audioManager.seek(to: targetTime)
                }) {
                    Image(systemName: "goforward.5")
                        .font(.title2)
                }
            }
        }
        .padding()
    }
    
    func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Controls Section
struct ControlsSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            //speed control
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "speedometer")
                        .foregroundColor(.amadeusBlue)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Playback Speed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(String(format: "%.1fx", audioManager.playbackSpeed)) speed")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                Slider(value: $audioManager.playbackSpeed, in: 0.5...1.5, step: 0.1)
                    .accentColor(.amadeusBlue)
                
                HStack {
                    Text("0.5x").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("1.0x").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("1.5x").font(.caption).foregroundColor(.secondary)
                }
            }
            .cardStyle()
            
            //pitch control
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.amadeusPurple)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Transpose")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(audioManager.pitchShift > 0 ? "+" : "")\(audioManager.pitchShift) semitones")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                Slider(value: Binding(
                    get: { Double(audioManager.pitchShift) },
                    set: { audioManager.pitchShift = Int($0) }
                ), in: -12...12, step: 1)
                    .accentColor(.amadeusPurple)
                
                HStack {
                    Text("-12").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("0").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("+12").font(.caption).foregroundColor(.secondary)
                }
            }
            .cardStyle()
        }
        .padding(.horizontal)
    }
}

// MARK: - Share Button
struct ShareButton: View {
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        Button(action: shareAnalysis) {
            Image(systemName: "square.and.arrow.up")
        }
    }

    private func shareAnalysis() {
        //create a summary of the analysis
        var analysisText = "Amadeus - Chord Analysis\n\n"
        analysisText += "Key: \(audioManager.originalKey)\n"
        if audioManager.pitchShift != 0 {
            analysisText += "Transposed to: \(audioManager.currentKey)\n"
        }
        analysisText += "Duration: \(formatTime(audioManager.duration))\n\n"

        analysisText += "Chord Progression:\n"
        for detection in audioManager.analysisManager.chordDetections {
            let timeStamp = "\(formatTime(detection.startTime))-\(formatTime(detection.endTime))"
            let chordName = audioManager.pitchShift != 0 ?
                transposeChord(detection.chordName, semitones: audioManager.pitchShift) :
                detection.chordName
            analysisText += "\(timeStamp): \(chordName)\n"
        }

        analysisText += "\n---\nGenerated by Amadeus"

        //present share sheet via UIKit (more stable than SwiftUI sheet)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        //find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let activityVC = UIActivityViewController(activityItems: [analysisText], applicationActivities: nil)

        //required for iPad to prevent crash
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func transposeChord(_ chord: String, semitones: Int) -> String {
        guard semitones != 0 else { return chord }

        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let altNotes = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

        var rootNote = ""
        var suffix = ""

        if chord.count >= 2 && (chord.dropFirst().first == "#" || chord.dropFirst().first == "b") {
            rootNote = String(chord.prefix(2))
            suffix = String(chord.dropFirst(2))
        } else if chord.count >= 1 {
            rootNote = String(chord.prefix(1))
            suffix = String(chord.dropFirst(1))
        } else {
            return chord
        }

        let currentIndex = notes.firstIndex(of: rootNote) ?? altNotes.firstIndex(of: rootNote) ?? 0
        let newIndex = (currentIndex + semitones + 12) % 12
        let newRoot = notes[newIndex]

        return "\(newRoot)\(suffix)"
    }
}

// MARK: - Actions Section
struct ActionsSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        HStack(spacing: 16) {
            MIDIExportButton(audioManager: audioManager)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

// MARK: - MIDI Export Button
struct MIDIExportButton: View {
    @ObservedObject var audioManager: AudioManager
    @State private var showComingSoonAlert = false

    var body: some View {
        Button(action: { showComingSoonAlert = true }) {
            Label("Export MIDI", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.1))
                .foregroundColor(.purple)
                .cornerRadius(10)
        }
        .alert("Coming Soon", isPresented: $showComingSoonAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("MIDI export will be available in a future update.")
        }
    }
}
