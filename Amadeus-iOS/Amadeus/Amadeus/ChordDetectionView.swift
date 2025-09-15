//
//  ChordDetectionView.swift
//  Amadeus - main chord detection interface
//
//  this view combines microphone input with chord detection
//  uses the fake detector for now, will swap to real detection later
//

import SwiftUI
import AudioKit

// MARK: - View Model
// handles the business logic and state management

/// manages chord detection state and audio processing
class ChordDetectionViewModel: ObservableObject {
    
    // MARK: - Audio Components
    private let engine = AudioEngine()
    private var mic: AudioEngine.InputNode?
    private var mixer: Mixer?
    private var fftTap: FFTTap?  // Changed from AmplitudeTap
    
    // MARK: - Detection Components
    private let detector: ChordDetectorService
    
    // MARK: - Published State (UI updates when these change)
    @Published var currentChord: ChordResult = .noChord
    @Published var isListening = false
    @Published var amplitude: Float = 0.0
    @Published var errorMessage: String?
    
    // MARK: - FFT Data
    private var frequencyData: [Float] = []
    private let sampleRate: Float = 44100.0
    
    // MARK: - Detection Settings
    private var detectionTimer: Timer?
    private let detectionInterval: TimeInterval = 0.1  // detect 10 times per second
    
    // MARK: - Initialisation
    
    init(useRealDetector: Bool = true) {  // Default to real detector now
        // choose which detector to use
        self.detector = useRealDetector ? RealChordDetector() : FakeChordDetector()
        
        // set up audio session
        do {
            try Settings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        } catch {
            errorMessage = "Failed to set up audio: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Public Methods
    
    /// dtarts listening and detecting chords
    func startListening() {
        do {
            // Set up audio input
            guard let input = engine.input else {
                errorMessage = "No microphone available"
                return
            }
            mic = input
            
            // set up mixer (silent output to prevent feedback)
            mixer = Mixer(input)
            mixer?.volume = 0.0
            engine.output = mixer
            
            // start engine
            try engine.start()
            
            // Set up FFT monitoring (NEW)
            fftTap = FFTTap(input, bufferSize: 2048, callbackQueue: .main) { [weak self] fftData in
                guard let self = self else { return }
                
                // Store frequency data
                self.frequencyData = Array(fftData)
                
                // Calculate amplitude from FFT data
                let amp = fftData.reduce(0, +) / Float(fftData.count)
                
                DispatchQueue.main.async {
                    self.amplitude = amp
                }
            }
            fftTap?.start()
            
            // start chord detection timer
            startDetectionTimer()
            
            // update state
            isListening = true
            errorMessage = nil
            
        } catch {
            errorMessage = "Failed to start: \(error.localizedDescription)"
        }
    }
    
    /// stops listening and detecting
    func stopListening() {
        // Stop detection
        detectionTimer?.invalidate()
        detectionTimer = nil
        
        // stop audio
        fftTap?.stop()
        engine.stop()
        
        // update state
        isListening = false
        currentChord = .noChord
        amplitude = 0.0
        frequencyData = []
    }
    
    // MARK: - Private Methods
    
    /// starts the timer that triggers chord detection
    private func startDetectionTimer() {
        detectionTimer = Timer.scheduledTimer(withTimeInterval: detectionInterval, repeats: true) { [weak self] _ in
            self?.performDetection()
        }
    }
    
    /// performs chord detection based on frequency data
    private func performDetection() {
        // Skip if no frequency data
        guard !frequencyData.isEmpty else { return }
        
        // Use frequency-based detection
        let result = detector.detectChord(from: frequencyData, sampleRate: sampleRate)
        
        // only update if chord changed or confidence significantly different
        if result.chordName != currentChord.chordName ||
           abs(result.confidence - currentChord.confidence) > 0.1 {
            DispatchQueue.main.async {
                self.currentChord = result
            }
        }
    }
}

// MARK: - Main View

/// the main chord detection interface
struct ChordDetectionView: View {
    @StateObject private var viewModel = ChordDetectionViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            
            // MARK: - Header
            Text("🎹 Chord Detector")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // MARK: - Chord Display
            VStack(spacing: 10) {
                // main chord name
                Text(viewModel.currentChord.chordName)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(chordColor)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentChord.chordName)
                
                // chord quality (major/minor/etc)
                if let quality = viewModel.currentChord.quality {
                    Text(quality)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 150)
            
            // MARK: - Confidence Meter
            VStack(alignment: .leading, spacing: 8) {
                Text("Confidence: \(Int(viewModel.currentChord.confidence * 100))%")
                    .font(.headline)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // background
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                        
                        // confidence bar
                        RoundedRectangle(cornerRadius: 10)
                            .fill(confidenceGradient)
                            .frame(width: geometry.size.width * CGFloat(viewModel.currentChord.confidence))
                            .animation(.easeOut(duration: 0.2), value: viewModel.currentChord.confidence)
                    }
                }
                .frame(height: 30)
            }
            .padding(.horizontal)
            
            // MARK: - Audio Level Meter
            VStack(alignment: .leading, spacing: 8) {
                Text("Audio Level")
                    .font(.headline)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(levelColor)
                            .frame(width: geometry.size.width * CGFloat(min(viewModel.amplitude, 1.0)))
                    }
                }
                .frame(height: 20)
            }
            .padding(.horizontal)
            
            // MARK: - Control Button
            Button(action: {
                if viewModel.isListening {
                    viewModel.stopListening()
                } else {
                    viewModel.startListening()
                }
            }) {
                HStack {
                    Image(systemName: viewModel.isListening ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title)
                    Text(viewModel.isListening ? "Stop Listening" : "Start Listening")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(viewModel.isListening ? Color.red : Color.green)
                .cornerRadius(15)
            }
            
            // MARK: - Status/Error Display
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.isListening {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .scaleEffect(2)
                                .opacity(0)
                                .animation(
                                    .easeOut(duration: 1)
                                    .repeatForever(autoreverses: false),
                                    value: viewModel.isListening
                                )
                        )
                    Text("Listening...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Computed Properties for Colors
    
    /// color based on chord type
    private var chordColor: Color {
        guard let quality = viewModel.currentChord.quality else { return .primary }
        
        switch quality {
        case "major", "major 7th":
            return .blue
        case "minor", "minor 7th":
            return .purple
        case "dominant 7th":
            return .orange
        default:
            return .primary
        }
    }
    
    /// gradient for confidence meter
    private var confidenceGradient: LinearGradient {
        LinearGradient(
            colors: [.red, .orange, .green],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// color for audio level
    private var levelColor: Color {
        if viewModel.amplitude > 0.7 {
            return .red
        } else if viewModel.amplitude > 0.4 {
            return .yellow
        } else {
            return .green
        }
    }
}

// MARK: - Preview

#Preview {
    ChordDetectionView()
}
