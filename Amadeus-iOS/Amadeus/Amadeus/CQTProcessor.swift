//
//  CQTProcessor.swift
//  Amadeus - Constant-Q Transform implementation
//
//  Based on Schörkhuber & Klapuri (2010) "Constant-Q Transform Toolbox for Music Processing"
//  Optimised for real-time chord detection on iOS devices
//
//  The Constant-Q Transform (CQT) is a time-frequency representation where:
//  - Frequency bins are geometrically spaced (musical intervals)
//  - Q-factor (frequency/bandwidth ratio) is constant across all bins
//  - Perfect for musical analysis as it mirrors how we perceive pitch
//
//  This implementation uses the efficient FFT-based kernel method from the paper,
//  with optimisations for sparse matrix multiplication and real-time processing.
//

import Foundation
import Accelerate
import AudioKit

// MARK: - CQT Configuration

/// Configuration parameters for the Constant-Q Transform
/// These values determine the time-frequency resolution trade-off
struct CQTConfig {
    /// Sample rate of the audio input in Hz
    /// Standard CD quality - matches our AudioKit configuration
    let sampleRate: Float = 44100.0
    
    /// Number of frequency bins per octave
    /// 12 = chromatic scale (each semitone)
    /// 24 = quarter-tones (more resolution)
    /// 36 = even finer resolution
    /// We use 12 for standard Western music chord detection
    let binsPerOctave: Int = 12
    
    /// Lowest frequency to analyse in Hz
    /// E2 (82.41 Hz) is the lowest note on a standard guitar
    /// This captures the fundamental frequencies of most chords
    let minFrequency: Float = 82.41
    
    /// Highest frequency to analyse in Hz
    /// C8 (4186 Hz) covers all harmonic content needed for chord detection
    /// Higher frequencies are less important for identifying chords
    let maxFrequency: Float = 4186.0
    
    /// Number of samples between successive CQT frames
    /// 512 samples = ~12ms at 44.1kHz
    /// This gives us ~85 updates per second - smooth for real-time display
    let hopSize: Int = 512
    
    /// Size of the FFT used for kernel convolution
    /// Must be power of 2 for efficient FFT
    /// 2048 gives good frequency resolution while maintaining speed
    let fftSize: Int = 2048
    
    /// Q-factor determines the frequency/bandwidth ratio
    /// Higher Q = narrower bandwidth = better frequency resolution
    /// Formula from Equation 5 in the Klapuri paper
    var qFactor: Float {
        // This ensures minimal frequency smearing while allowing reconstruction
        // The formula comes from the constraint that adjacent bins should overlap properly
        return 1.0 / (pow(2.0, 1.0 / Float(binsPerOctave)) - 1.0)
    }
    
    /// Number of octaves spanned by our frequency range
    /// Calculated as log2(maxFreq/minFreq)
    var octaveCount: Int {
        return Int(log2(maxFrequency / minFrequency))
    }
    
    /// Total number of frequency bins in the CQT
    /// Each octave has 'binsPerOctave' bins
    var totalBins: Int {
        return binsPerOctave * octaveCount
    }
}

// MARK: - CQT Kernel

/// Spectral kernel for efficient CQT computation
/// This class generates and stores the FFT-domain kernels used to compute the CQT
/// The approach is based on Section 3 of the Klapuri paper
class CQTKernel {
    private let config: CQTConfig
    
    /// Spectral kernels for each frequency bin
    /// These are the FFT of the time-domain analysis windows
    private var kernels: [[DSPComplex]] = []
    
    /// Sparse representation - indices of non-zero kernel values
    /// This dramatically speeds up the convolution by only computing necessary multiplications
    private var kernelSupport: [[Int]] = []
    
    /// Window function used for all kernels
    /// Hamming window provides good frequency selectivity with moderate side-lobes
    private let windowFunction: [Float]
    
    init(config: CQTConfig) {
        self.config = config
        
        // Generate Hamming window
        // The Hamming window is a good compromise between main lobe width and side lobe suppression
        // Formula: w(n) = 0.54 - 0.46 * cos(2πn/(N-1))
        self.windowFunction = CQTKernel.hammingWindow(size: config.fftSize)
        
        // Generate all kernels at initialisation for efficiency
        generateKernels()
    }
    
    /// Generate spectral kernels for all frequency bins
    /// This follows the algorithm in Section 3.1 of the Klapuri paper
    private func generateKernels() {
        let fftSize = config.fftSize
        let fs = config.sampleRate
        let Q = config.qFactor
        
        // For each frequency bin in our CQT
        for k in 0..<config.totalBins {
            // Calculate the centre frequency for this bin
            // Frequencies are geometrically spaced: fk = fmin * 2^(k/binsPerOctave)
            // This gives us equal spacing on a log scale (musical intervals)
            let fk = config.minFrequency * pow(2.0, Float(k) / Float(config.binsPerOctave))
            
            // Calculate optimal window length for this frequency
            // From Equation 6 in the paper: Nk = Q * fs / fk
            // Higher frequencies get shorter windows (better time resolution)
            // Lower frequencies get longer windows (better frequency resolution)
            let Nk = Int(Q * fs / fk)
            
            // Create time-domain kernel (analysis window)
            var temporalKernel = [Float](repeating: 0.0, count: fftSize)
            
            // Ensure window fits within FFT frame
            let windowLength = min(Nk, fftSize)
            
            // Centre the window in the FFT frame for zero-phase response
            let startIdx = (fftSize - windowLength) / 2
            
            // Generate windowed complex exponential
            // This is our frequency-shifted analysis window
            for n in 0..<windowLength {
                let t = Float(n) / fs  // Time in seconds
                
                // Apply window function to reduce spectral leakage
                let windowValue = hammingValue(n, windowLength)
                
                // Complex exponential shifts the window to frequency fk
                // We only store the real part here; imaginary part handled in FFT
                let angle = -2.0 * Float.pi * fk * t
                temporalKernel[startIdx + n] = windowValue * cos(angle)
            }
            
            // Transform to frequency domain for efficient convolution
            // This is the key to the fast CQT algorithm
            var spectralKernel = computeFFT(temporalKernel)
            
            // Find significant values for sparse representation
            // Most of the spectral kernel is near zero, so we can skip those multiplications
            var support: [Int] = []
            let threshold: Float = 0.0001  // Values below this are considered zero
            
            for i in 0..<spectralKernel.count {
                // Calculate magnitude of complex number
                let magnitude = sqrt(spectralKernel[i].real * spectralKernel[i].real + 
                                   spectralKernel[i].imag * spectralKernel[i].imag)
                
                // Only keep indices where kernel is significant
                if magnitude > threshold {
                    support.append(i)
                }
            }
            
            // Store kernel and its support for later use
            kernels.append(spectralKernel)
            kernelSupport.append(support)
        }
    }
    
    /// Calculate Hamming window value at position n of N samples
    /// The Hamming window reduces spectral leakage in the FFT
    private func hammingValue(_ n: Int, _ N: Int) -> Float {
        // Classic Hamming window formula
        // Provides -43dB side lobe suppression
        return 0.54 - 0.46 * cos(2.0 * Float.pi * Float(n) / Float(N - 1))
    }
    
    /// Generate a complete Hamming window of given size
    static func hammingWindow(size: Int) -> [Float] {
        var window = [Float](repeating: 0.0, count: size)
        for i in 0..<size {
            // Hamming window formula: w(n) = 0.54 - 0.46 * cos(2πn/(N-1))
            window[i] = 0.54 - 0.46 * cos(2.0 * Float.pi * Float(i) / Float(size - 1))
        }
        return window
    }
    
    /// Compute FFT of real-valued input using Accelerate framework
    /// Returns complex-valued frequency domain representation
    private func computeFFT(_ input: [Float]) -> [DSPComplex] {
        // Calculate FFT size as power of 2
        let log2n = vDSP_Length(log2(Float(input.count)))
        
        // Create FFT setup - this contains precomputed twiddle factors
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            print("Failed to create FFT setup")
            return []
        }
        // Ensure we clean up the FFT setup when done
        defer { vDSP_destroy_fftsetup(fftSetup) }
        
        // Prepare input buffers (real and imaginary parts)
        var realIn = input
        var imagIn = [Float](repeating: 0.0, count: input.count)  // Zero imaginary part for real input
        var realOut = [Float](repeating: 0.0, count: input.count)
        var imagOut = [Float](repeating: 0.0, count: input.count)
        
        // Perform FFT using Accelerate framework
        // This is highly optimised for Apple hardware
        realIn.withUnsafeMutableBufferPointer { realInPtr in
            imagIn.withUnsafeMutableBufferPointer { imagInPtr in
                realOut.withUnsafeMutableBufferPointer { realOutPtr in
                    imagOut.withUnsafeMutableBufferPointer { imagOutPtr in
                        // Create split complex format required by vDSP
                        var splitComplex = DSPSplitComplex(
                            realp: realInPtr.baseAddress!,
                            imagp: imagInPtr.baseAddress!
                        )
                        var splitComplexOut = DSPSplitComplex(
                            realp: realOutPtr.baseAddress!,
                            imagp: imagOutPtr.baseAddress!
                        )
                        
                        // Perform out-of-place FFT
                        vDSP_fft_zrop(fftSetup, &splitComplex, 1, &splitComplexOut, 1, log2n, FFTDirection(kFFTDirection_Forward))
                    }
                }
            }
        }
        
        // Convert from split complex to array of complex numbers
        var result: [DSPComplex] = []
        for i in 0..<input.count {
            result.append(DSPComplex(real: realOut[i], imag: imagOut[i]))
        }
        
        return result
    }
    
    /// Get kernel and support for a specific frequency bin
    /// Returns both the complex kernel and indices of non-zero values
    func getKernel(for bin: Int) -> ([DSPComplex], [Int]) {
        guard bin >= 0 && bin < kernels.count else {
            print("Invalid bin index: \(bin)")
            return ([], [])
        }
        return (kernels[bin], kernelSupport[bin])
    }
}

// MARK: - Main CQT Processor

/// Real-time Constant-Q Transform processor for chord detection
/// This is the main class that processes audio and produces chromagrams
class CQTProcessor: ChordDetectorService {
    
    // MARK: - Properties
    
    /// Configuration parameters for the CQT
    private let config: CQTConfig
    
    /// Pre-computed spectral kernels for efficient processing
    private let kernel: CQTKernel
    
    /// FFT setup for processing input audio
    private var fftSetup: FFTSetup?
    
    /// Log2 of FFT size for vDSP functions
    private let fftLog2n: vDSP_Length
    
    // MARK: - Buffers
    
    /// Circular buffer for input audio
    private var inputBuffer: [Float]
    
    /// Split complex buffer for FFT operations
    private var fftBuffer: DSPSplitComplex
    
    /// Temporary buffers for FFT computation
    private var realBuffer: [Float]
    private var imagBuffer: [Float]
    
    // MARK: - Output Data
    
    /// Magnitude of CQT coefficients for each frequency bin
    private(set) var cqtMagnitudes: [Float]
    
    /// 12-element chromagram (pitch class profile)
    /// Each element represents the energy of a pitch class (C, C#, D, etc.)
    private(set) var chromagram: [Float]
    
    /// Ready state for the protocol
    var isReady: Bool = true
    
    // MARK: - Initialisation
    
    init(config: CQTConfig = CQTConfig()) {
        self.config = config
        self.kernel = CQTKernel(config: config)
        
        // Initialise FFT for input processing
        self.fftLog2n = vDSP_Length(log2(Float(config.fftSize)))
        self.fftSetup = vDSP_create_fftsetup(fftLog2n, FFTRadix(kFFTRadix2))
        
        // Allocate buffers for processing
        self.inputBuffer = [Float](repeating: 0.0, count: config.fftSize)
        self.realBuffer = [Float](repeating: 0.0, count: config.fftSize)
        self.imagBuffer = [Float](repeating: 0.0, count: config.fftSize)
        
        // Allocate split complex buffer for vDSP
        self.fftBuffer = DSPSplitComplex(
            realp: UnsafeMutablePointer<Float>.allocate(capacity: config.fftSize),
            imagp: UnsafeMutablePointer<Float>.allocate(capacity: config.fftSize)
        )
        
        // Initialise output arrays
        self.cqtMagnitudes = [Float](repeating: 0.0, count: config.totalBins)
        self.chromagram = [Float](repeating: 0.0, count: 12)
        
        print("CQTProcessor: Initialised with \(config.totalBins) bins, Q=\(config.qFactor)")
    }
    
    deinit {
        // Clean up allocated memory
        fftBuffer.realp.deallocate()
        fftBuffer.imagp.deallocate()
        if let setup = fftSetup {
            vDSP_destroy_fftsetup(setup)
        }
    }
    
    // MARK: - ChordDetectorService Protocol Implementation
    
    /// Detect chord from amplitude (backward compatibility)
    func detectChord(from amplitude: Float) -> ChordResult {
        // CQT doesn't use simple amplitude - return no chord
        return ChordResult.noChord
    }
    
    /// Detect chord from frequency data (main detection method)
    func detectChord(from frequencyData: [Float], sampleRate: Float) -> ChordResult {
        // Process the frequency data through CQT
        let chromagram = process(audioBuffer: frequencyData)
        
        // Find the strongest pitch classes for chord detection
        let chordName = detectChordFromChroma(chromagram)
        
        // Calculate confidence based on chromagram clarity
        let confidence = calculateConfidence(chromagram)
        
        return ChordResult(
            chord: nil,
            chordName: chordName,
            confidence: confidence,
            timestamp: Date(),
            rootNote: extractRoot(from: chordName),
            quality: extractQuality(from: chordName)
        )
    }
    
    /// Reset the processor state
    func reset() {
        // Clear all buffers
        inputBuffer = [Float](repeating: 0.0, count: config.fftSize)
        cqtMagnitudes = [Float](repeating: 0.0, count: config.totalBins)
        chromagram = [Float](repeating: 0.0, count: 12)
        
        // Clear FFT buffers
        realBuffer = [Float](repeating: 0.0, count: config.fftSize)
        imagBuffer = [Float](repeating: 0.0, count: config.fftSize)
    }
    
    // MARK: - CQT Processing
    
    /// Process audio buffer and compute CQT
    /// This is the main processing function that converts audio to chromagram
    func process(audioBuffer: [Float]) -> [Float] {
        // Ensure we have enough samples for processing
        guard audioBuffer.count >= config.fftSize else {
            print("Buffer too small for CQT processing: \(audioBuffer.count) < \(config.fftSize)")
            return chromagram
        }
        
        // Copy audio to input buffer (take most recent samples if buffer is larger)
        let startIdx = max(0, audioBuffer.count - config.fftSize)
        for i in 0..<config.fftSize {
            inputBuffer[i] = audioBuffer[startIdx + i]
        }
        
        // Apply window function to reduce spectral leakage
        // This is crucial for getting clean frequency analysis
        var windowedInput = inputBuffer
        vDSP_vmul(inputBuffer, 1, kernel.hammingWindow(size: config.fftSize), 1, &windowedInput, 1, vDSP_Length(config.fftSize))
        
        // Compute FFT of windowed input
        performFFT(windowedInput)
        
        // Compute CQT by convolving with kernels
        // This is where the magic happens - FFT multiplication = time domain convolution
        computeCQT()
        
        // Convert CQT to chromagram for chord detection
        computeChromagram()
        
        return chromagram
    }
    
    /// Perform FFT on input signal
    /// Converts time-domain audio to frequency-domain representation
    private func performFFT(_ input: [Float]) {
        // Copy input to real buffer, zero imaginary part
        for i in 0..<input.count {
            realBuffer[i] = input[i]
            imagBuffer[i] = 0.0
        }
        
        // Transfer to split complex format for vDSP
        realBuffer.withUnsafeMutableBufferPointer { realPtr in
            imagBuffer.withUnsafeMutableBufferPointer { imagPtr in
                fftBuffer.realp.assign(from: realPtr.baseAddress!, count: config.fftSize)
                fftBuffer.imagp.assign(from: imagPtr.baseAddress!, count: config.fftSize)
            }
        }
        
        // Perform in-place FFT using Accelerate framework
        // This is highly optimised for Apple Silicon and Intel processors
        vDSP_fft_zrip(fftSetup!, &fftBuffer, 1, fftLog2n, FFTDirection(kFFTDirection_Forward))
    }
    
    /// Compute CQT coefficients using kernel convolution
    /// This implements Equation 8 from the Klapuri paper
    private func computeCQT() {
        // Process each frequency bin
        for k in 0..<config.totalBins {
            // Get kernel and its support (non-zero indices)
            let (kernelData, support) = kernel.getKernel(for: k)
            
            // Accumulate complex multiplication result
            var real: Float = 0.0
            var imag: Float = 0.0
            
            // Sparse multiplication - only compute where kernel is non-zero
            // This is the key optimisation that makes real-time processing possible
            for idx in support {
                // Only use positive frequencies (negative frequencies are redundant for real signals)
                if idx < config.fftSize/2 {
                    // Get FFT values at this frequency
                    let fftReal = fftBuffer.realp[idx]
                    let fftImag = fftBuffer.imagp[idx]
                    
                    // Get kernel values at this frequency
                    let kernelReal = kernelData[idx].real
                    let kernelImag = kernelData[idx].imag
                    
                    // Complex multiplication: (a+bi)(c+di) = (ac-bd) + (ad+bc)i
                    real += fftReal * kernelReal - fftImag * kernelImag
                    imag += fftReal * kernelImag + fftImag * kernelReal
                }
            }
            
            // Compute magnitude of complex result
            // This gives us the energy at this frequency
            cqtMagnitudes[k] = sqrt(real * real + imag * imag)
        }
    }
    
    /// Convert CQT to chromagram (pitch class profile)
    /// This folds all octaves into 12 pitch classes
    private func computeChromagram() {
        // Reset chromagram to zero
        chromagram = [Float](repeating: 0.0, count: 12)
        
        // Sum energy across all octaves for each pitch class
        // This is called "pitch class folding" or "chroma wrapping"
        for k in 0..<config.totalBins {
            // Determine which of the 12 pitch classes this bin belongs to
            let pitchClass = k % 12
            
            // Add this bin's energy to the appropriate pitch class
            chromagram[pitchClass] += cqtMagnitudes[k]
        }
        
        // Normalise chromagram to [0, 1] range
        // This makes chord detection independent of volume
        let maxValue = chromagram.max() ?? 1.0
        if maxValue > 0 {
            for i in 0..<12 {
                chromagram[i] /= maxValue
            }
        }
    }
    
    // MARK: - Chord Detection Helpers
    
    /// Detect chord from chromagram using template matching
    private func detectChordFromChroma(_ chroma: [Float]) -> String {
        // Simple template matching for major and minor triads
        // This is a basic implementation - will be enhanced later
        
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Find the strongest pitch class as potential root
        var maxEnergy: Float = 0.0
        var rootIndex = 0
        
        for i in 0..<12 {
            if chroma[i] > maxEnergy {
                maxEnergy = chroma[i]
                rootIndex = i
            }
        }
        
        // Check for major third (4 semitones) and fifth (7 semitones)
        let majorThird = (rootIndex + 4) % 12
        let minorThird = (rootIndex + 3) % 12
        let fifth = (rootIndex + 7) % 12
        
        // Simple heuristic: if major third is stronger than minor third, it's major
        if chroma[majorThird] > chroma[minorThird] && chroma[fifth] > 0.3 {
            return noteNames[rootIndex]  // Major chord
        } else if chroma[minorThird] > chroma[majorThird] && chroma[fifth] > 0.3 {
            return noteNames[rootIndex] + "m"  // Minor chord
        }
        
        // Default to just the root note if no clear chord
        return noteNames[rootIndex]
    }
    
    /// Calculate confidence score from chromagram
    private func calculateConfidence(_ chroma: [Float]) -> Float {
        // Calculate how "peaky" the chromagram is
        // Clear chords have strong peaks, ambiguous ones are flatter
        
        let mean = chroma.reduce(0, +) / Float(chroma.count)
        let variance = chroma.map { pow($0 - mean, 2) }.reduce(0, +) / Float(chroma.count)
        
        // Higher variance = clearer chord = higher confidence
        // Normalise to [0, 1] range
        return min(sqrt(variance) * 2.0, 1.0)
    }
    
    /// Extract root note from chord name
    private func extractRoot(from chordName: String) -> String {
        // Remove quality indicators to get root
        return chordName.replacingOccurrences(of: "m", with: "")
                       .replacingOccurrences(of: "7", with: "")
                       .replacingOccurrences(of: "maj", with: "")
    }
    
    /// Extract chord quality from chord name
    private func extractQuality(from chordName: String) -> String {
        if chordName.contains("m") {
            return "minor"
        } else if chordName.contains("7") {
            return "dominant 7th"
        } else if chordName.contains("maj7") {
            return "major 7th"
        }
        return "major"
    }
    
    // MARK: - Public Accessors
    
    /// Get the current CQT magnitudes for visualisation
    func getCQTMagnitudes() -> [Float] {
        return cqtMagnitudes
    }
    
    /// Get the current chromagram (12-bin pitch class profile)
    func getChromagram() -> [Float] {
        return chromagram
    }
    
    /// Get the frequency in Hz for a given bin number
    func getFrequencyForBin(_ bin: Int) -> Float {
        guard bin >= 0 && bin < config.totalBins else { return 0.0 }
        // Geometric spacing: fk = fmin * 2^(k/binsPerOctave)
        return config.minFrequency * pow(2.0, Float(bin) / Float(config.binsPerOctave))
    }
}

// MARK: - DSPComplex Helper

/// Simple complex number structure for FFT operations
/// Used instead of importing complex math libraries
struct DSPComplex {
    var real: Float
    var imag: Float
    
    /// Magnitude of the complex number
    var magnitude: Float {
        return sqrt(real * real + imag * imag)
    }
    
    /// Phase angle of the complex number in radians
    var phase: Float {
        return atan2(imag, real)
    }
}