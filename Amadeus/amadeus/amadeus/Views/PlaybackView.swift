//
//  PlaybackView.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  transport controls for audio playback (play, pause, stop)
//  provides standard media player control interface
//
//  acknowledgements:
//  - transport control icons follow ios media player conventions
//  - slider styling based on custom premium slider component
//

import SwiftUI

// MARK: - Playback View

//playback transport controls with play/pause toggle and stop button
//provides standard media player interface for audio playback
struct PlaybackView: View {
    //audio manager for controlling playback state
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        HStack(spacing: 30) {
            //stop button returns to beginning
            Button(action: audioManager.stop) {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }

            //play/pause toggle button with large icon
            Button(action: {
                if audioManager.isPlaying {
                    audioManager.pause()
                } else {
                    audioManager.play()
                }
            }) {
                //icon changes based on playback state
                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

// MARK: - Chord Display View

//displays the currently playing chord in large text
//used as a prominent visual indicator during playback
struct ChordDisplayView: View {
    //chord name to display
    let currentChord: String

    var body: some View {
        VStack {
            //label above the chord
            Text("Current Chord")
                .font(.caption)
                .foregroundColor(.secondary)

            //large chord name display
            Text(currentChord)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Controls View

//playback controls panel with speed and transpose adjustments
//provides sliders for tempo and pitch shift with animated feedback
struct ControlsView: View {
    //audio manager for controlling playback parameters
    @ObservedObject var audioManager: AudioManager

    //animation scale for speed label bounce effect
    @State private var speedScale: CGFloat = 1.0

    //animation scale for transpose label bounce effect
    @State private var transposeScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 20) {
            //speed control section
            VStack {
                //speed label with current value
                HStack {
                    Image(systemName: "speedometer")
                    Text("Speed: \(String(format: "%.1fx", audioManager.playbackSpeed))")
                    Spacer()
                }
                .font(.headline)
                .scaleEffect(speedScale)
                .animation(.bouncy(duration: 0.3), value: speedScale)

                //speed slider from 0.5x to 1.5x
                PremiumSlider(
                    value: Binding(
                        get: { Double(audioManager.playbackSpeed) },
                        set: { newValue in
                            audioManager.playbackSpeed = Float(newValue)
                            //trigger bounce animation on change
                            speedScale = 1.1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                speedScale = 1.0
                            }
                        }
                    ),
                    range: 0.5...1.5,
                    step: 0.1,
                    trackColor: .blue,
                    thumbColor: .blue
                )

                //speed scale labels
                HStack {
                    Text("0.5x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.0x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.5x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)

            //transpose control section
            VStack {
                //transpose label showing semitone offset
                HStack {
                    Image(systemName: "music.note")
                    Text("Transpose: \(audioManager.pitchShift > 0 ? "+" : "")\(audioManager.pitchShift)")
                    Spacer()
                }
                .font(.headline)
                .scaleEffect(transposeScale)
                .animation(.bouncy(duration: 0.3), value: transposeScale)

                //transpose slider from -12 to +12 semitones
                PremiumSlider(
                    value: Binding(
                        get: { Double(audioManager.pitchShift) },
                        set: { newValue in
                            audioManager.pitchShift = Int(newValue)
                            //trigger bounce animation on change
                            transposeScale = 1.1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                transposeScale = 1.0
                            }
                        }
                    ),
                    range: -12...12,
                    step: 1,
                    trackColor: .purple,
                    thumbColor: .purple
                )

                //transpose range labels
                HStack {
                    Text("-12")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("+12")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)

            //current key display (accounts for transposition)
            Text("Key: \(audioManager.currentKey)")
                .font(.headline)
                .padding()
        }
        .padding(.horizontal)
    }
}