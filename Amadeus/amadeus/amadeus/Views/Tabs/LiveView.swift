//
//  LiveView.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  real-time chord detection view with microphone input visualisation
//  displays live audio levels and detected chords during recording
//
//  acknowledgements:
//  - microphone visualisation inspired by voice memos app design
//  - audio level metering follows ios audio session patterns
//

import SwiftUI

// MARK: - Live View

//live recording tab with real-time chord detection and audio visualisation
//provides interactive microphone interface for live chord detection
struct LiveView: View {
    //indicates whether the microphone is actively listening
    @State private var isListening = false

    //currently detected chord name, defaults to em dash when inactive
    @State private var currentChord = "—"

    //confidence level of the current chord detection (0.0 to 1.0)
    @State private var confidence: Float = 0.0

    //current audio input level for visualisation (0.0 to 1.0)
    @State private var audioLevel: Float = 0.0

    //history of recently detected chords for display
    @State private var chordHistory: [String] = []

    //toggle for noise reduction processing
    @State private var noiseReduction = true

    //timer for simulated chord detection (demo mode)
    @State private var chordTimer: Timer?

    //sample chord names used for simulation
    private let chords = ["C", "Am", "F", "G", "Em", "Dm"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {

                Spacer()

                //microphone visualisation section with animated rings
                VStack {
                    ZStack {
                        //outer ring showing maximum audio level range (background)
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                            .frame(width: 200, height: 200)

                        //active level ring that fills based on current audio input
                        Circle()
                            .trim(from: 0, to: CGFloat(audioLevel))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.1), value: audioLevel)

                        //inner circle that changes colour when listening
                        Circle()
                            .fill(isListening ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .animation(.easeInOut(duration: 0.2), value: isListening)

                        //microphone icon changes based on listening state
                        Image(systemName: isListening ? "mic.fill" : "mic.slash.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }

                    //instructional status text below the visualisation
                    Text(isListening ? "Listening..." : "Tap to start listening")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .onTapGesture {
                    toggleListening()
                }

                //current chord display card showing detected chord
                VStack(spacing: 8) {
                    Text("Current Chord")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    //large chord name display
                    Text(currentChord)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)

                    //confidence indicator shown only when detection is active
                    if confidence > 0 {
                        HStack {
                            Text("Confidence:")
                                .font(.caption)
                            //progress bar showing detection confidence
                            ProgressView(value: confidence, total: 1.0)
                                .frame(width: 100)
                            Text("\(Int(confidence * 100))%")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                //chord history section showing recent detections
                if !chordHistory.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Recent Chords")
                            .font(.headline)
                            .padding(.horizontal)

                        //horizontal scroll of chord pills with fading opacity
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(chordHistory.enumerated()), id: \.offset) { index, chord in
                                    //individual chord pill with fading opacity for older chords
                                    Text(chord)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                        .opacity(1.0 - Double(index) * 0.2)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()

                //controls section at bottom of view
                VStack(spacing: 16) {
                    //noise reduction toggle for audio processing
                    HStack {
                        //icon changes based on toggle state
                        Image(systemName: noiseReduction ? "waveform" : "waveform.slash")
                        Text("Noise Reduction")
                        Spacer()
                        Toggle("", isOn: $noiseReduction)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Live Detection")
        }
        //clean up when view disappears
        .onDisappear {
            stopListening()
        }
    }

    // MARK: - Listening Control Methods

    //toggles between listening and stopped states
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    //starts the microphone listening session
    //activates audio level simulation and chord detection timer
    func startListening() {
        isListening = true

        //simulate audio level fluctuations for visualisation
        //in production this would read actual microphone input levels
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isListening {
                timer.invalidate()
                return
            }
            audioLevel = Float.random(in: 0.2...0.8)
        }

        //simulate chord detection every 3 seconds
        //in production this would process audio through the analysis pipeline
        chordTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if isListening {
                //pick a random chord from the sample set
                let newChord = chords.randomElement() ?? "C"
                currentChord = newChord
                confidence = Float.random(in: 0.6...0.95)

                //add detected chord to history, maintaining max 5 items
                chordHistory.insert(newChord, at: 0)
                if chordHistory.count > 5 {
                    chordHistory.removeLast()
                }
            }
        }
    }

    //stops the listening session and resets all state
    func stopListening() {
        isListening = false
        chordTimer?.invalidate()
        audioLevel = 0
        currentChord = "—"
        confidence = 0
    }
}

#Preview {
    LiveView()
}
