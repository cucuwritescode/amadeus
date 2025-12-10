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
            // Waveform with tap-to-seek
            WaveformVisualization(audioManager: audioManager)
                .frame(height: 85)
                .background(Color.black.opacity(0.05))
                .cornerRadius(12)
            
            // Current Chord Piano View
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
                // Waveform bars
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
                
                // Progress overlay
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
                // Tap to seek - calculate position relative to waveform
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
                Button(action: { 
                    // Skip backward exactly 5 seconds
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
                    // Skip forward exactly 5 seconds
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
            // Speed Control
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
            
            // Pitch Control
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
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        Button(action: shareAnalysis) {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $showShareSheet) {
            if #available(iOS 16.0, *) {
                ShareSheet(items: shareItems)
                    .presentationDetents([.medium, .large])
            } else {
                ShareSheet(items: shareItems)
            }
        }
    }
    
    private func shareAnalysis() {
        // Create a summary of the analysis
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
        
        shareItems = [analysisText]
        showShareSheet = true
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

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
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
    @State private var showMIDISheet = false
    @State private var midiData: Data?
    
    var body: some View {
        Button(action: exportMIDI) {
            Label("Export MIDI", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.1))
                .foregroundColor(.purple)
                .cornerRadius(10)
        }
        .sheet(isPresented: $showMIDISheet) {
            if let data = midiData {
                if #available(iOS 16.0, *) {
                    ShareSheet(items: [data])
                        .presentationDetents([.medium])
                } else {
                    ShareSheet(items: [data])
                }
            }
        }
    }
    
    private func exportMIDI() {
        // Create a simple MIDI file from the chord detections
        guard !audioManager.analysisManager.chordDetections.isEmpty else {
            print("No chord detections to export")
            return
        }
        
        // For now, create a placeholder MIDI data
        // In a real implementation, this would generate actual MIDI from the note events
        let midiHeader = "MIDI Export from Amadeus\n\nChords:\n"
        var midiContent = midiHeader
        
        for detection in audioManager.analysisManager.chordDetections {
            let chordName = audioManager.pitchShift != 0 ?
                transposeChord(detection.chordName, semitones: audioManager.pitchShift) :
                detection.chordName
            midiContent += "\(formatTime(detection.startTime)): \(chordName)\n"
        }
        
        midiData = midiContent.data(using: .utf8)
        showMIDISheet = true
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