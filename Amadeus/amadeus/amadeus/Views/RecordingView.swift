import SwiftUI
import AVFoundation

struct RecordingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var audioManager: AudioManager
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // Recording Visualization
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 4)
                        .frame(width: 200, height: 200)
                        .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                        .opacity(audioRecorder.isRecording ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: audioRecorder.isRecording)
                    
                    // Main circle
                    Circle()
                        .fill(audioRecorder.isRecording ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                    
                    // Microphone icon
                    Image(systemName: audioRecorder.isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    toggleRecording()
                }
                
                // Recording time
                Text(formatTime(audioRecorder.recordingTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(audioRecorder.isRecording ? .red : .secondary)
                
                // Instructions
                Text(audioRecorder.isRecording ? "Recording... Tap to stop" : "Tap to start recording")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Recording limit notice
                if audioRecorder.isRecording {
                    Text("Max duration: 30 seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 40) {
                    // Cancel/Delete
                    Button(audioRecorder.hasRecording ? "Delete" : "Cancel") {
                        if audioRecorder.hasRecording {
                            audioRecorder.deleteRecording()
                        }
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    
                    // Save (only if there's a recording)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
            .onAppear {
                //reset recording state when view appears
                audioRecorder.resetForNewRecording()
            }
        }
    }
    
    func toggleRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
        } else {
            // Check microphone permission before starting
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        if granted {
                            audioRecorder.startRecording()
                        } else {
                            permissionMessage = "Please allow microphone access to record audio. You can change this in Settings."
                            showPermissionAlert = true
                        }
                    }
                }
            } else {
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
    
    func saveRecording() {
        guard let recordingURL = audioRecorder.getRecordingURL() else {
            print("no recording url available")
            return
        }
        
        //stop current audio and reset engine state
        audioManager.stopEngine()
        
        //reset audio session for playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            print("audio session reset to playback mode")
        } catch {
            print("failed to reset audio session: \(error)")
        }
        
        //copy recording to permanent location with unique name
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = Int(Date().timeIntervalSince1970)
        let finalURL = documentsPath.appendingPathComponent("recording_\(timestamp).wav")
        
        do {
            //remove any existing file at destination
            try? FileManager.default.removeItem(at: finalURL)
            
            //copy recording to final location
            try FileManager.default.copyItem(at: recordingURL, to: finalURL)
            
            //ensure file is readable before loading
            guard FileManager.default.fileExists(atPath: finalURL.path) else {
                print("recorded file doesn't exist at final location")
                return
            }
            
            print("recording saved to: \(finalURL.lastPathComponent)")
            print("loading recording for analysis...")
            
            //give small delay to ensure audio session is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.audioManager.loadFile(finalURL)
                self.dismiss()
            }
            
        } catch {
            print("failed to save recording: \(error)")
            //fallback: try using original recording url directly
            print("trying fallback with original url...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.audioManager.loadFile(recordingURL)
                self.dismiss()
            }
        }
    }
    
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