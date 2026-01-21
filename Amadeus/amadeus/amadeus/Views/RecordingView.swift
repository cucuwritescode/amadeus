//
//  RecordingView.swift
//  amadeus
//
//  created by facundo franchino on 11/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  recording interface with visual feedback
//  displays waveform animation and recording controls
//
//  acknowledgements:
//  - waveform animation inspired by voice memos app
//  - recording ui patterns from ios human interface guidelines
//

import SwiftUI
import AVFoundation

// MARK: - Recording View

//recording interface with visual microphone feedback and controls
//handles permission requests, recording state, and file management
struct RecordingView: View {
    //environment dismiss action for closing the modal
    @Environment(\.dismiss) var dismiss

    //audio manager for loading recorded files for analysis
    @ObservedObject var audioManager: AudioManager

    //audio recorder state object managing recording session
    @StateObject private var audioRecorder = AudioRecorder()

    //controls visibility of microphone permission alert
    @State private var showPermissionAlert = false

    //message to display in permission alert
    @State private var permissionMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()

                //recording visualisation with animated pulse ring
                ZStack {
                    //outer pulse ring that animates when recording
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 4)
                        .frame(width: 200, height: 200)
                        .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                        .opacity(audioRecorder.isRecording ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: audioRecorder.isRecording)

                    //main circular button background
                    Circle()
                        .fill(audioRecorder.isRecording ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)

                    //microphone icon changes fill when recording
                    Image(systemName: audioRecorder.isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    toggleRecording()
                }

                //recording time display in monospaced font
                Text(formatTime(audioRecorder.recordingTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(audioRecorder.isRecording ? .red : .secondary)

                //instruction text changes based on recording state
                Text(audioRecorder.isRecording ? "Recording... Tap to stop" : "Tap to start recording")
                    .font(.headline)
                    .foregroundColor(.secondary)

                //recording limit notice shown during active recording
                if audioRecorder.isRecording {
                    Text("Max duration: 30 seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                //bottom control buttons
                HStack(spacing: 40) {
                    //cancel or delete button depending on recording state
                    Button(audioRecorder.hasRecording ? "Delete" : "Cancel") {
                        if audioRecorder.hasRecording {
                            audioRecorder.deleteRecording()
                        }
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.red)

                    //save button only shown when recording is complete
                    if audioRecorder.hasRecording && !audioRecorder.isRecording {
                        Button("Save & Analyse") {
                            saveRecording()
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .navigationTitle("Record Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //done button to close modal
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            //microphone permission alert with settings link
            .alert("Microphone Permission Required", isPresented: $showPermissionAlert) {
                Button("Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(permissionMessage)
            }
            //reset recording state when view appears
            .onAppear {
                audioRecorder.resetForNewRecording()
            }
        }
    }

    // MARK: - Recording Control Methods

    //toggles recording on/off, checking permissions when starting
    func toggleRecording() {
        if audioRecorder.isRecording {
            //stop active recording
            audioRecorder.stopRecording()
        } else {
            //request microphone permission before starting
            //uses ios 17+ api if available, falls back to older api
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        if granted {
                            audioRecorder.startRecording()
                        } else {
                            //show permission alert if denied
                            permissionMessage = "Please allow microphone access to record audio. You can change this in Settings."
                            showPermissionAlert = true
                        }
                    }
                }
            } else {
                //fallback for ios 16 and earlier
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        if granted {
                            audioRecorder.startRecording()
                        } else {
                            permissionMessage = "Please allow microphone access to record audio. You can change this in Settings."
                            showPermissionAlert = true
                        }
                    }
                }
            }
        }
    }

    //saves recorded audio to documents directory and loads for analysis
    func saveRecording() {
        //verify recording url is available
        guard let recordingURL = audioRecorder.getRecordingURL() else {
            print("no recording url available")
            return
        }

        //stop current audio playback and reset engine state
        audioManager.stopEngine()

        //configure audio session for playback mode
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            print("audio session reset to playback mode")
        } catch {
            print("failed to reset audio session: \(error)")
        }

        //create permanent file path with timestamp-based unique name
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = Int(Date().timeIntervalSince1970)
        let finalURL = documentsPath.appendingPathComponent("recording_\(timestamp).wav")

        do {
            //remove existing file at destination if present
            try? FileManager.default.removeItem(at: finalURL)

            //copy recording from temporary to permanent location
            try FileManager.default.copyItem(at: recordingURL, to: finalURL)

            //verify file exists before loading
            guard FileManager.default.fileExists(atPath: finalURL.path) else {
                print("recorded file doesn't exist at final location")
                return
            }

            print("recording saved to: \(finalURL.lastPathComponent)")
            print("loading recording for analysis...")

            //small delay to ensure audio session is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.audioManager.loadFile(finalURL)
                self.dismiss()
            }

        } catch {
            print("failed to save recording: \(error)")
            //fallback: try loading directly from original temporary url
            print("trying fallback with original url...")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.audioManager.loadFile(recordingURL)
                self.dismiss()
            }
        }
    }

    //formats time interval as mm:ss.t (minutes, seconds, tenths)
    func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let centiseconds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, secs, centiseconds)
    }
}

#Preview {
    RecordingView(audioManager: AudioManager())
}
