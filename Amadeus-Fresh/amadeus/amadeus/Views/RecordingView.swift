import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var audioManager: AudioManager
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?
    
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
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .opacity(isRecording ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
                    
                    // Main circle
                    Circle()
                        .fill(isRecording ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                    
                    // Microphone icon
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    toggleRecording()
                }
                
                // Recording time
                Text(formatTime(recordingTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(isRecording ? .red : .secondary)
                
                // Instructions
                Text(isRecording ? "Recording... Tap to stop" : "Tap to start recording")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 40) {
                    // Cancel
                    Button("Cancel") {
                        stopRecording()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    
                    // Save (only if there's a recording)
                    if recordingTime > 0 && !isRecording {
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
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        isRecording = true
        recordingTime = 0
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    func saveRecording() {
        // Create a simulated URL for the recording
        // In real implementation, this would be the actual recorded file
        if let simulatedURL = Bundle.main.url(forResource: "test", withExtension: "mp3") {
            audioManager.loadFile(simulatedURL)
        }
        dismiss()
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