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
//  acknowledgements:
//  - transport controls follow standard daw conventions
//  - uiactivityviewcontroller pattern from apple uikit documentation
//

import SwiftUI

// MARK: - Timeline View

//primary view for displaying analysis results and controlling playback
//shown after chord analysis completes, provides full playback interface
struct TimelineView: View {
    //observed audio manager providing playback state and controls
    @ObservedObject var audioManager: AudioManager

    //state for tracking playhead drag interactions
    @State private var isDraggingPlayhead = false
    @State private var draggedTime: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                //header displaying current chord and key information
                HeaderSection(audioManager: audioManager)

                //waveform visualisation with tap-to-seek and piano view
                WaveformSection(audioManager: audioManager)
                    .frame(height: 200)

                //transport controls: play, pause, stop, skip
                PlaybackSection(audioManager: audioManager)

                //adjustable sliders for speed and pitch modification
                ControlsSection(audioManager: audioManager)

                //export and sharing action buttons
                ActionsSection(audioManager: audioManager)
            }
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            //close button to exit analysis view
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    //stop any active playback
                    audioManager.stop()

                    //reset analysis state flags
                    audioManager.showAnalysisLoading = false
                    audioManager.showAnalysisComplete = false
                    audioManager.analysisManager.reset()

                    //clear the loaded file to return to initial state
                    audioManager.isFileLoaded = false
                }
            }

            //share button in navigation bar
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareButton(audioManager: audioManager)
            }
        }
    }
}

// MARK: - Header Section

//displays the currently playing chord and detected key information
//updates in real-time as playback progresses through the analysis
struct HeaderSection: View {
    //observed audio manager for current chord and key data
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            //large current chord display - the main visual focus
            VStack(spacing: 8) {
                //chord name in large prominent text with shadow effect
                Text(audioManager.currentChord)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.amadeusBlue)
                    .shadow(color: .amadeusBlue.opacity(0.3), radius: 4, y: 2)

                //label beneath chord name
                Text("Current Chord")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
            }

            //key information card showing original and transposed keys
            HStack(spacing: 20) {
                //original detected key from analysis
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

                //transposed key shown only when pitch shift is active
                if audioManager.pitchShift != 0 {
                    Divider()
                        .frame(height: 30)

                    //transposed key with semitone offset indicator
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

//contains the waveform visualisation and piano keyboard display
//provides visual feedback of playback position and current chord voicing
struct WaveformSection: View {
    //observed audio manager for playback state
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 12) {
            //interactive waveform with tap-to-seek functionality
            WaveformVisualization(audioManager: audioManager)
                .frame(height: 85)
                .background(Color.black.opacity(0.05))
                .cornerRadius(12)

            //piano keyboard showing currently playing chord notes
            CurrentChordPianoView(audioManager: audioManager)
        }
        .padding(.horizontal)
    }
}

// MARK: - Waveform Visualisation

//visual representation of audio with playback progress overlay
//supports tap gesture for seeking to specific positions
struct WaveformVisualization: View {
    //observed audio manager for time and duration values
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //stylised waveform bars (decorative representation)
                HStack(spacing: 2) {
                    ForEach(0..<50) { i in
                        //individual bar with gradient fill
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                //width calculated to fill available space evenly
                                width: (geometry.size.width / 50) - 2,
                                //random height for visual variation
                                height: CGFloat.random(in: 20...80)
                            )
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)

                //progress overlay showing current playback position
                if audioManager.duration > 0 {
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        //width proportional to playback progress
                        .frame(width: (audioManager.currentTime / audioManager.duration) * geometry.size.width)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .animation(.linear(duration: 0.5), value: audioManager.currentTime)
                }
            }
            //make entire area tappable for seeking
            .contentShape(Rectangle())
            .onTapGesture { location in
                //calculate seek position from tap location
                guard audioManager.duration > 0 else { return }

                //convert x position to time ratio (clamped 0-1)
                let ratio = max(0, min(1, location.x / geometry.size.width))
                let seekTime = ratio * audioManager.duration

                print("🎯 Tap to seek: x=\(location.x), width=\(geometry.size.width), ratio=\(ratio), time=\(seekTime)")

                //perform the seek operation
                audioManager.seek(to: seekTime)
            }
        }
    }
}

// MARK: - Playback Section

//transport controls section with time display and playback buttons
//provides standard daw-style controls for audio navigation
struct PlaybackSection: View {
    //observed audio manager for playback state and controls
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            //time display with progress bar
            HStack {
                //current playback time in mm:ss format
                Text(formatTime(audioManager.currentTime))
                    .font(.system(.body, design: .monospaced))

                //linear progress indicator
                ProgressView(value: audioManager.currentTime, total: max(audioManager.duration, 1))
                    .progressViewStyle(LinearProgressViewStyle())

                //total duration in mm:ss format
                Text(formatTime(audioManager.duration))
                    .font(.system(.body, design: .monospaced))
            }
            .padding(.horizontal)

            //transport control buttons
            HStack(spacing: 40) {
                //skip backward 5 seconds button
                Button(action: {
                    let targetTime = audioManager.currentTime - 5.0
                    audioManager.seek(to: targetTime)
                }) {
                    Image(systemName: "gobackward.5")
                        .font(.title2)
                }

                //stop button returns to beginning
                Button(action: { audioManager.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }

                //play/pause toggle button (large central button)
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pause()
                    } else {
                        audioManager.play()
                    }
                }) {
                    //icon changes based on playback state
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }

                //skip forward 5 seconds button
                Button(action: {
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

    //converts seconds to mm:ss display format
    func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Controls Section

//adjustable playback parameters for speed and pitch modification
//allows users to slow down playback or transpose to different keys
struct ControlsSection: View {
    //observed audio manager for speed and pitch values
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(spacing: 16) {
            //playback speed control card
            VStack(alignment: .leading, spacing: 10) {
                //header with icon and current value
                HStack {
                    Image(systemName: "speedometer")
                        .foregroundColor(.amadeusBlue)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Playback Speed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        //displays current speed multiplier
                        Text("\(String(format: "%.1fx", audioManager.playbackSpeed)) speed")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                //speed adjustment slider (0.5x to 1.5x)
                Slider(value: $audioManager.playbackSpeed, in: 0.5...1.5, step: 0.1)
                    .accentColor(.amadeusBlue)

                //scale labels showing range
                HStack {
                    Text("0.5x").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("1.0x").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("1.5x").font(.caption).foregroundColor(.secondary)
                }
            }
            .cardStyle()

            //pitch transposition control card
            VStack(alignment: .leading, spacing: 10) {
                //header with icon and current value
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.amadeusPurple)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Transpose")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        //displays current semitone offset with sign
                        Text("\(audioManager.pitchShift > 0 ? "+" : "")\(audioManager.pitchShift) semitones")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                //pitch shift slider (-12 to +12 semitones, one octave each way)
                //uses binding to convert between double slider and int value
                Slider(value: Binding(
                    get: { Double(audioManager.pitchShift) },
                    set: { audioManager.pitchShift = Int($0) }
                ), in: -12...12, step: 1)
                    .accentColor(.amadeusPurple)

                //scale labels showing semitone range
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

//navigation bar button for sharing analysis results as text
//presents system share sheet with formatted chord progression
struct ShareButton: View {
    //observed audio manager for analysis data access
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        Button(action: shareAnalysis) {
            Image(systemName: "square.and.arrow.up")
        }
    }

    //generates analysis summary and presents share sheet
    private func shareAnalysis() {
        //build text summary of the analysis results
        var analysisText = "Amadeus - Chord Analysis\n\n"
        analysisText += "Key: \(audioManager.originalKey)\n"

        //include transposed key if pitch shift is active
        if audioManager.pitchShift != 0 {
            analysisText += "Transposed to: \(audioManager.currentKey)\n"
        }
        analysisText += "Duration: \(formatTime(audioManager.duration))\n\n"

        //add timestamped chord progression
        analysisText += "Chord Progression:\n"
        for detection in audioManager.analysisManager.chordDetections {
            //format time range for this chord
            let timeStamp = "\(formatTime(detection.startTime))-\(formatTime(detection.endTime))"

            //apply transposition if pitch shift is active
            let chordName = audioManager.pitchShift != 0 ?
                transposeChord(detection.chordName, semitones: audioManager.pitchShift) :
                detection.chordName
            analysisText += "\(timeStamp): \(chordName)\n"
        }

        //add footer attribution
        analysisText += "\n---\nGenerated by Amadeus"

        //present share sheet via uikit for better stability
        //swiftui sheet presentation has known issues with uiactivityviewcontroller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        //traverse view controller hierarchy to find topmost presented controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        //create activity view controller with text content
        let activityVC = UIActivityViewController(activityItems: [analysisText], applicationActivities: nil)

        //configure popover presentation for ipad compatibility
        //without this, the app crashes on ipad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        //present the share sheet
        topVC.present(activityVC, animated: true)
    }

    //converts seconds to mm:ss display format
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    //transposes a chord name by the specified number of semitones
    //handles both sharp and flat notation
    private func transposeChord(_ chord: String, semitones: Int) -> String {
        //no transposition needed if shift is zero
        guard semitones != 0 else { return chord }

        //chromatic note names (sharps)
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        //chromatic note names (flats) for input matching
        let altNotes = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

        var rootNote = ""
        var suffix = ""

        //parse root note (may be 1 or 2 characters if accidental present)
        if chord.count >= 2 && (chord.dropFirst().first == "#" || chord.dropFirst().first == "b") {
            rootNote = String(chord.prefix(2))
            suffix = String(chord.dropFirst(2))
        } else if chord.count >= 1 {
            rootNote = String(chord.prefix(1))
            suffix = String(chord.dropFirst(1))
        } else {
            return chord
        }

        //find current note index in chromatic scale
        let currentIndex = notes.firstIndex(of: rootNote) ?? altNotes.firstIndex(of: rootNote) ?? 0

        //calculate new index with wraparound (add 12 to handle negative shifts)
        let newIndex = (currentIndex + semitones + 12) % 12
        let newRoot = notes[newIndex]

        //return transposed chord with original suffix
        return "\(newRoot)\(suffix)"
    }
}

// MARK: - Actions Section

//container for export and action buttons at bottom of timeline
struct ActionsSection: View {
    //observed audio manager (passed to child buttons)
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        HStack(spacing: 16) {
            //midi export button (feature not yet implemented)
            MIDIExportButton(audioManager: audioManager)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

// MARK: - MIDI Export Button

//button for exporting analysis as midi file
//currently shows coming soon alert as feature is not yet implemented
struct MIDIExportButton: View {
    //observed audio manager (for future midi generation)
    @ObservedObject var audioManager: AudioManager

    //controls visibility of the coming soon alert
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
        //alert shown when button tapped
        .alert("Coming Soon", isPresented: $showComingSoonAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("MIDI export will be available in a future update.")
        }
    }
}
