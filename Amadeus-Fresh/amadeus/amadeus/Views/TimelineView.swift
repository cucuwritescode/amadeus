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
            
            // Key Information
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original Key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Text(audioManager.analysisManager.estimatedKey)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                if audioManager.pitchShift != 0 {
                    Divider()
                        .frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Transposed")
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "speedometer")
                        .foregroundColor(.amadeusBlue)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Playback Speed")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("\(String(format: "%.1fx", audioManager.playbackSpeed)) speed")
                            .font(.caption)
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
            
            // Pitch Control
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.amadeusPurple)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Transpose")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("\(audioManager.pitchShift > 0 ? "+" : "")\(audioManager.pitchShift) semitones")
                            .font(.caption)
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