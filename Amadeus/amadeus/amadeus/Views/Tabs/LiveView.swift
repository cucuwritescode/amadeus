import SwiftUI

struct LiveView: View {
    @State private var isListening = false
    @State private var currentChord = "—"
    @State private var confidence: Float = 0.0
    @State private var audioLevel: Float = 0.0
    @State private var chordHistory: [String] = []
    @State private var noiseReduction = true
    
    // Chord simulation timer
    @State private var chordTimer: Timer?
    private let chords = ["C", "Am", "F", "G", "Em", "Dm"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                Spacer()
                
                // Microphone Visualization
                VStack {
                    ZStack {
                        // Outer ring - audio level
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                            .frame(width: 200, height: 200)
                        
                        // Active level ring
                        Circle()
                            .trim(from: 0, to: CGFloat(audioLevel))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.1), value: audioLevel)
                        
                        // Inner circle
                        Circle()
                            .fill(isListening ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .animation(.easeInOut(duration: 0.2), value: isListening)
                        
                        // Microphone icon
                        Image(systemName: isListening ? "mic.fill" : "mic.slash.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    // Status text
                    Text(isListening ? "Listening..." : "Tap to start listening")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .onTapGesture {
                    toggleListening()
                }
                
                // Current Chord Display
                VStack(spacing: 8) {
                    Text("Current Chord")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(currentChord)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    // Confidence indicator
                    if confidence > 0 {
                        HStack {
                            Text("Confidence:")
                                .font(.caption)
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
                
                // Chord History
                if !chordHistory.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Recent Chords")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(chordHistory.enumerated()), id: \.offset) { index, chord in
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
                
                // Controls
                VStack(spacing: 16) {
                    // Noise Reduction Toggle
                    HStack {
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
        .onDisappear {
            stopListening()
        }
    }
    
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }
    
    func startListening() {
        isListening = true
        
        // Simulate audio level fluctuations
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isListening {
                timer.invalidate()
                return
            }
            audioLevel = Float.random(in: 0.2...0.8)
        }
        
        // Simulate chord detection
        chordTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if isListening {
                let newChord = chords.randomElement() ?? "C"
                currentChord = newChord
                confidence = Float.random(in: 0.6...0.95)
                
                // Add to history
                chordHistory.insert(newChord, at: 0)
                if chordHistory.count > 5 {
                    chordHistory.removeLast()
                }
            }
        }
    }
    
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