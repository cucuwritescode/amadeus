import Foundation
import AVFoundation
import Accelerate
import CoreML

///raw audio preprocessing for Basic Pitch CoreML model:
/// AVAudioPCMBuffer to mono 22.05 kHz to 43,844-sample chunks to MLMultiArray[1, 43844, 1]
struct BasicPitchPreprocessor {

    //basic pitch CoreML model parameters
    static let targetSampleRate: Double = 22_050.0
    static let chunkSampleCount: Int = 43_844  //exactly what the model expects
    
    // MARK: - Public entry point

    ///main function: turn any AVAudioPCMBuffer into raw audio chunks for the CoreML model
    /// - Returns: Array of MLMultiArray with shape [1, 43844, 1] ready for model inference
    static func audioBufferToModelInputs(_ buffer: AVAudioPCMBuffer) throws -> [MLMultiArray] {
        //convert to mono float array
        let mono = try makeMonoFloatSignal(from: buffer)

        // resample to 22.05 kHz if needed
        let resampled = try resampleIfNeeded(signal: mono,
                                             fromSampleRate: buffer.format.sampleRate,
                                             toSampleRate: targetSampleRate)

        //create 43,844-sample chunks
        let chunks = createAudioChunks(signal: resampled, chunkSize: chunkSampleCount)
        
        // convert each chunk to MLMultiArray[1, 43844, 1]
        return try chunks.map { chunk in
            try createModelInput(from: chunk)
        }
    }
    
    ///creates MLMultiArray from raw audio samples with shape [1, 43844, 1]
    private static func createModelInput(from samples: [Float]) throws -> MLMultiArray {
        guard samples.count == chunkSampleCount else {
            throw PreprocessError.invalidChunkSize
        }
        
        let inputShape = [1, chunkSampleCount, 1]
        guard let inputArray = try? MLMultiArray(shape: inputShape.map(NSNumber.init), dataType: .float32) else {
            throw PreprocessError.mlArrayCreationFailed
        }
        
        let dataPointer = inputArray.dataPointer.bindMemory(to: Float.self, capacity: chunkSampleCount)
        
        // copy normalised samples [-1, 1] into MLMultiArray
        for i in 0..<chunkSampleCount {
            dataPointer[i] = samples[i]
        }
        
        return inputArray
    }
    
    /// creates fixed-size audio chunks from continuous signal
    private static func createAudioChunks(signal: [Float], chunkSize: Int) -> [[Float]] {
        guard !signal.isEmpty else { return [] }
        
        var chunks: [[Float]] = []
        let totalSamples = signal.count
        
        if totalSamples <= chunkSize {
            // single chunk,pad with zeros if needed
            var chunk = signal
            if chunk.count < chunkSize {
                chunk.append(contentsOf: Array(repeating: 0.0, count: chunkSize - chunk.count))
            }
            chunks.append(chunk)
        } else {
            //multiple chunks, slide window across audio
            let numChunks = (totalSamples + chunkSize - 1) / chunkSize
            
            for chunkIndex in 0..<numChunks {
                let start = chunkIndex * chunkSize
                let end = min(start + chunkSize, totalSamples)
                
                var chunk = Array(signal[start..<end])
                
                //pad last chunk if necessary
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
            //single channel, just copy
            return Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
        } else {
            // average all channels to mono
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
            // already around 22.05k anyways
            return signal
        }

        let ratio = toSampleRate / fromSampleRate
        let inputCount = signal.count
        let outputCount = Int(Double(inputCount) * ratio)

        var output = [Float](repeating: 0.0, count: outputCount)

        //use simple linear interpolation for resampling
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
