import Foundation
import AVFoundation
import Accelerate
import CoreML

/// Raw audio preprocessing for Basic Pitch CoreML model:
/// AVAudioPCMBuffer → mono 22.05 kHz → 43,844-sample chunks → MLMultiArray[1, 43844, 1]
struct BasicPitchPreprocessor {

    // Basic Pitch CoreML model parameters
    static let targetSampleRate: Double = 22_050.0
    static let chunkSampleCount: Int = 43_844  // Exactly what the model expects
    
    // MARK: - Public entry point

    /// Main function: turn any AVAudioPCMBuffer into raw audio chunks for the CoreML model
    /// - Returns: Array of MLMultiArray with shape [1, 43844, 1] ready for model inference
    static func audioBufferToModelInputs(_ buffer: AVAudioPCMBuffer) throws -> [MLMultiArray] {
        // 1) Convert to mono float array
        let mono = try makeMonoFloatSignal(from: buffer)

        // 2) Resample to 22.05 kHz if needed
        let resampled = try resampleIfNeeded(signal: mono,
                                             fromSampleRate: buffer.format.sampleRate,
                                             toSampleRate: targetSampleRate)

        // 3) Create 43,844-sample chunks
        let chunks = createAudioChunks(signal: resampled, chunkSize: chunkSampleCount)
        
        // 4) Convert each chunk to MLMultiArray[1, 43844, 1]
        return try chunks.map { chunk in
            try createModelInput(from: chunk)
        }
    }
    
    /// Creates MLMultiArray from raw audio samples with shape [1, 43844, 1]
    private static func createModelInput(from samples: [Float]) throws -> MLMultiArray {
        guard samples.count == chunkSampleCount else {
            throw PreprocessError.invalidChunkSize
        }
        
        let inputShape = [1, chunkSampleCount, 1]
        guard let inputArray = try? MLMultiArray(shape: inputShape.map(NSNumber.init), dataType: .float32) else {
            throw PreprocessError.mlArrayCreationFailed
        }
        
        let dataPointer = inputArray.dataPointer.bindMemory(to: Float.self, capacity: chunkSampleCount)
        
        // Copy normalized samples [-1, 1] into MLMultiArray
        for i in 0..<chunkSampleCount {
            dataPointer[i] = samples[i]
        }
        
        return inputArray
    }
    
    /// Creates fixed-size audio chunks from continuous signal
    private static func createAudioChunks(signal: [Float], chunkSize: Int) -> [[Float]] {
        guard !signal.isEmpty else { return [] }
        
        var chunks: [[Float]] = []
        let totalSamples = signal.count
        
        if totalSamples <= chunkSize {
            // Single chunk - pad with zeros if needed
            var chunk = signal
            if chunk.count < chunkSize {
                chunk.append(contentsOf: Array(repeating: 0.0, count: chunkSize - chunk.count))
            }
            chunks.append(chunk)
        } else {
            // Multiple chunks - slide window across audio
            let numChunks = (totalSamples + chunkSize - 1) / chunkSize
            
            for chunkIndex in 0..<numChunks {
                let start = chunkIndex * chunkSize
                let end = min(start + chunkSize, totalSamples)
                
                var chunk = Array(signal[start..<end])
                
                // Pad last chunk if necessary
                if chunk.count < chunkSize {
                    chunk.append(contentsOf: Array(repeating: 0.0, count: chunkSize - chunk.count))
                }
                
                chunks.append(chunk)
            }
        }
        
        return chunks
    }

    // MARK: - 1. Mono conversion

    private static func makeMonoFloatSignal(from buffer: AVAudioPCMBuffer) throws -> [Float] {
        guard let channelData = buffer.floatChannelData else {
            throw PreprocessError.invalidBuffer
        }

        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)

        if channelCount == 1 {
            // Single channel, just copy
            return Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
        } else {
            // Average all channels → mono
            var mono = [Float](repeating: 0.0, count: frameLength)
            for ch in 0..<channelCount {
                let channel = channelData[ch]
                vDSP_vadd(mono, 1, channel, 1, &mono, 1, vDSP_Length(frameLength))
            }
            var divisor = Float(channelCount)
            vDSP_vsdiv(mono, 1, &divisor, &mono, 1, vDSP_Length(frameLength))
            return mono
        }
    }

    // MARK: - 2. Resampling

    private static func resampleIfNeeded(signal: [Float],
                                         fromSampleRate: Double,
                                         toSampleRate: Double) throws -> [Float] {
        if abs(fromSampleRate - toSampleRate) < 1.0 {
            // Already ~22.05k
            return signal
        }

        let ratio = toSampleRate / fromSampleRate
        let inputCount = signal.count
        let outputCount = Int(Double(inputCount) * ratio)

        var output = [Float](repeating: 0.0, count: outputCount)

        // Use simple linear interpolation for resampling
        for i in 0..<outputCount {
            let srcIndex = Double(i) / ratio
            let lowIndex = Int(srcIndex)
            let highIndex = min(lowIndex + 1, inputCount - 1)
            let fraction = srcIndex - Double(lowIndex)
            
            if lowIndex < inputCount {
                output[i] = signal[lowIndex] * Float(1.0 - fraction) + 
                          (highIndex < inputCount ? signal[highIndex] * Float(fraction) : 0)
            }
        }

        return output
    }

    // MARK: - Error

    enum PreprocessError: Error {
        case invalidBuffer
        case resampleFailed
        case invalidChunkSize
        case mlArrayCreationFailed
    }
}
