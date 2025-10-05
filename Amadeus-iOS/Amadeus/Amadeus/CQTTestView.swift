//
//  CQTTestView.swift
//  Amadeus - Test view for CQT implementation
//
//  This view allows real-time testing and visualisation of the CQT processor
//  Shows chromagram, detected chords, and performance metrics
//

import SwiftUI
import AudioKit
import Charts

// MARK: - Test View Model

/// View model for testing the CQT implementation
class CQTTestViewModel: ObservableObject {
    
    // MARK: - Audio Components
    
    /// Audio engine for managing audio flow
    private let engine = AudioEngine()
    
    /// Microphone input node
    private var mic: AudioEngine.InputNode?
    
    /// Mixer for routing audio
    private var mixer: Mixer?
    
    /// FFT tap for getting frequency data
    private var fftTap: FFTTap?
    
    // MARK: - CQT Components
    
    /// Our new CQT processor
    private let cqtProcessor = CQTProcessor()
    
    /// Timer for regular CQT updates
    private var updateTimer: Timer?
    
    // MARK: - Published State
    
    /// Current chromagram values for display
    @Published var chromagram: [Float] = Array(repeating: 0.0, count: 12)
    
    /// Detected chord name
    @Published var detectedChord: String = "—"
    
    /// Detection confidence
    @Published var confidence: Float = 0.0
    
    /// Processing time in milliseconds
    @Published var processingTime: Double = 0.0
    
    /// Whether we're currently listening
    @Published var isListening = false
    
    /// Error messages
    @Published var errorMessage: String?
    
    /// Frequency data buffer
    private var frequencyBuffer: [Float] = []
    
    // MARK: - Note names for display
    
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // MARK: - Initialisation
    
    init() {
        // Set up audio session for recording
        do {
            try Settings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        } catch {
            errorMessage = "Failed to set up audio: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Public Methods
    
    /// Start listening and processing
    func startListening() {
        do {
            // Get microphone input
            guard let input = engine.input else {
                errorMessage = "No microphone available"
                return
            }
            mic = input
            
            // Set up audio routing
            mixer = Mixer(input)
            mixer?.volume = 0.0  // Mute output to prevent feedback
            engine.output = mixer
            
            // Start the audio engine
            try engine.start()
            
            // Set up FFT tap to get frequency data
            fftTap = FFTTap(input, bufferSize: 2048, callbackQueue: .main) { [weak self] fftData in
                guard let self = self else { return }
                
                // Store frequency data for CQT processing
                self.frequencyBuffer = Array(fftData)
            }
            fftTap?.start()
            
            // Start update timer for CQT processing
            // Run 30 times per second for smooth visualisation
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] _ in
                self?.processCQT()
            }
            
            isListening = true
            errorMessage = nil
            
        } catch {
            errorMessage = "Failed to start: \(error.localizedDescription)"
        }
    }
    
    /// Stop listening and processing
    func stopListening() {
        // Stop timers and taps
        updateTimer?.invalidate()
        updateTimer = nil
        fftTap?.stop()
        
        // Stop audio engine
        engine.stop()
        
        // Reset state
        isListening = false
        chromagram = Array(repeating: 0.0, count: 12)
        detectedChord = "—"
        confidence = 0.0
        processingTime = 0.0
    }
    
    // MARK: - Private Methods
    
    /// Process audio through CQT and update display
    private func processCQT() {
        guard !frequencyBuffer.isEmpty else { return }
        
        // Measure processing time
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Process through CQT to get chromagram
        let result = cqtProcessor.detectChord(from: frequencyBuffer, sampleRate: 44100.0)
        
        // Calculate processing time in milliseconds
        let endTime = CFAbsoluteTimeGetCurrent()
        let timeMs = (endTime - startTime) * 1000.0
        
        // Update published properties on main queue
        DispatchQueue.main.async {
            self.chromagram = self.cqtProcessor.getChromagram()
            self.detectedChord = result.chordName
            self.confidence = result.confidence
            self.processingTime = timeMs
        }
    }
}

// MARK: - Main Test View

/// Test view for CQT implementation
struct CQTTestView: View {
    @StateObject private var viewModel = CQTTestViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Header
                Text("🧪 CQT Test Interface")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // MARK: - Detected Chord Display
                VStack(spacing: 10) {
                    Text("Detected Chord")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.detectedChord)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    // Confidence meter
                    HStack {
                        Text("Confidence:")
                        ProgressView(value: viewModel.confidence)
                            .progressViewStyle(LinearProgressViewStyle())
                        Text("\(Int(viewModel.confidence * 100))%")
                            .monospacedDigit()
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // MARK: - Chromagram Visualisation
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chromagram")
                        .font(.headline)
                    
                    // Bar chart showing energy for each pitch class
                    ForEach(0..<12) { index in
                        HStack {
                            // Note name
                            Text(viewModel.noteNames[index])
                                .font(.system(.body, design: .monospaced))
                                .frame(width: 30, alignment: .trailing)
                            
                            // Energy bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                    
                                    // Energy level
                                    Rectangle()
                                        .fill(colorForNote(index))
                                        .frame(width: geometry.size.width * CGFloat(viewModel.chromagram[index]))
                                        .animation(.easeOut(duration: 0.1), value: viewModel.chromagram[index])
                                }
                            }
                            .frame(height: 20)
                            
                            // Numeric value
                            Text(String(format: "%.2f", viewModel.chromagram[index]))
                                .font(.caption)
                                .monospacedDigit()
                                .frame(width: 40)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // MARK: - Performance Metrics
                VStack(alignment: .leading, spacing: 10) {
                    Text("Performance")
                        .font(.headline)
                    
                    HStack {
                        Label("Processing Time:", systemImage: "timer")
                        Spacer()
                        Text(String(format: "%.2f ms", viewModel.processingTime))
                            .monospacedDigit()
                            .foregroundColor(performanceColor)
                    }
                    
                    HStack {
                        Label("Frame Rate:", systemImage: "speedometer")
                        Spacer()
                        Text("\(Int(1000.0 / max(viewModel.processingTime, 0.001))) FPS")
                            .monospacedDigit()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
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
                        Text(viewModel.isListening ? "Stop Testing" : "Start Testing")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(viewModel.isListening ? Color.red : Color.green)
                    .cornerRadius(15)
                }
                .padding()
                
                // MARK: - Error Display
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // MARK: - Info Box
                VStack(alignment: .leading, spacing: 10) {
                    Text("ℹ️ About CQT")
                        .font(.headline)
                    
                    Text("""
                    The Constant-Q Transform provides frequency analysis with:
                    • Logarithmic frequency spacing (matches musical intervals)
                    • Better frequency resolution for low notes
                    • Better time resolution for high notes
                    • Perfect for musical analysis and chord detection
                    
                    This implementation uses the efficient FFT-based kernel method from Schörkhuber & Klapuri (2010).
                    """)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    
    /// Get colour for a note based on its position in the chromatic scale
    private func colorForNote(_ index: Int) -> Color {
        // Use different colours for natural notes vs sharps/flats
        let naturalNotes = [0, 2, 4, 5, 7, 9, 11]  // C, D, E, F, G, A, B
        
        if naturalNotes.contains(index) {
            return .blue
        } else {
            return .purple
        }
    }
    
    /// Get performance colour based on processing time
    private var performanceColor: Color {
        if viewModel.processingTime < 10 {
            return .green  // Excellent
        } else if viewModel.processingTime < 20 {
            return .orange  // Good
        } else {
            return .red  // Needs optimisation
        }
    }
}

// MARK: - Preview

#Preview {
    CQTTestView()
}