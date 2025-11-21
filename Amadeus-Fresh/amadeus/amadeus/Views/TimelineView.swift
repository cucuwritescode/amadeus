import SwiftUI

struct TimelineView: View {
    @ObservedObject var audioManager: AudioManager
    @State private var isDraggingPlayhead = false
    @State private var draggedTime: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with Key and Current Chord
                HeaderSection(audioManager: audioManager)
                
                // Waveform and Chord Timeline
                WaveformSection(audioManager: audioManager)
                    .frame(height: 200)
                
                // Playback Controls
                PlaybackSection(audioManager: audioManager)
                
                // Speed and Pitch Controls
                ControlsSection(audioManager: audioManager)
                
                // Export/Share Options
                ActionsSection()
            }
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    audioManager.stop()
                    audioManager.isFileLoaded = false
                    audioManager.analysisManager.reset()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Current Chord Display (Large)
            Text(audioManager.currentChord)
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            
            // Key Information
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Original Key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(audioManager.analysisManager.estimatedKey)
                        .font(.headline)
                }
                
                if audioManager.pitchShift != 0 {
                    VStack(alignment: .leading) {
                        Text("Transposed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(audioManager.currentKey)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
    }
}

// MARK: - Waveform Section
struct WaveformSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        ZStack {
            // Waveform background
            WaveformVisualization()
            
            // Chord Timeline Overlay
            ChordTimelineView(
                detections: audioManager.analysisManager.chordDetections,
                currentTime: audioManager.currentTime,
                duration: audioManager.duration
            )
        }
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Waveform Visualization
struct WaveformVisualization: View {
    var body: some View {
        GeometryReader { geometry in
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
                            height: CGFloat.random(in: 20...100)
                        )
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

// MARK: - Playback Section
struct PlaybackSection: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Time Display
            HStack {
                Text(formatTime(audioManager.currentTime))
                    .font(.system(.body, design: .monospaced))
                
                ProgressView(value: audioManager.currentTime, total: max(audioManager.duration, 1))
                    .progressViewStyle(LinearProgressViewStyle())
                
                Text(formatTime(audioManager.duration))
                    .font(.system(.body, design: .monospaced))
            }
            .padding(.horizontal)
            
            // Playback Controls
            HStack(spacing: 40) {
                Button(action: { audioManager.seek(to: max(0, audioManager.currentTime - 5)) }) {
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
                
                Button(action: { audioManager.seek(to: min(audioManager.duration, audioManager.currentTime + 5)) }) {
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
        VStack(spacing: 20) {
            // Speed Control
            VStack(alignment: .leading) {
                Label("Speed: \(String(format: "%.1fx", audioManager.playbackSpeed))", systemImage: "speedometer")
                    .font(.headline)
                
                Slider(value: $audioManager.playbackSpeed, in: 0.5...1.5, step: 0.1)
                    .accentColor(.blue)
                
                HStack {
                    Text("0.5x").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("1.0x").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("1.5x").font(.caption2).foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // Pitch Control
            VStack(alignment: .leading) {
                Label("Transpose: \(audioManager.pitchShift > 0 ? "+" : "")\(audioManager.pitchShift) semitones", systemImage: "music.note")
                    .font(.headline)
                
                Slider(value: Binding(
                    get: { Double(audioManager.pitchShift) },
                    set: { audioManager.pitchShift = Int($0) }
                ), in: -12...12, step: 1)
                    .accentColor(.purple)
                
                HStack {
                    Text("-12").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("0").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("+12").font(.caption2).foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// MARK: - Actions Section
struct ActionsSection: View {
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Label("Export MIDI", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {}) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}