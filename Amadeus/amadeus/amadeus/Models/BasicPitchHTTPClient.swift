//
//  BasicPitchHTTPClient.swift
//  amadeus
//
//  created by facundo franchino on 09/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  http client for server-based basic pitch analysis
//  sends audio files to python server for advanced chord inference
//
//  acknowledgements:
//  - basic pitch model by rachel bittner et al. (icassp 2022)
//  - network patterns based on urlsession best practices
//

import Foundation
import AVFoundation

//http client for communicating with basic pitch server
class BasicPitchHTTPClient: ChordAnalyzer {
    
    //possible errors during http communication
    enum HTTPError: Error {
        case invalidURL
        case noData
        case serverError(String)
        case networkError(Error)
        case decodingError(Error)
        case audioExportFailed
    }
    
    private let serverURL: String
    private let chordAssembler = ChordAssembler()
    
    private struct ServerAnalysisResult {
        let notes: [APINote]
        let chords: [ChordDetection]
        let key: APIKeyInfo?
    }
    
    init(serverURL: String = "http://localhost:8000") {
        self.serverURL = serverURL
        print("BasicPitchHTTPClient initialized with server: \(serverURL)")
    }
    
    //analyse audio using basic pitch server
    func analyze(audioBuffer: AVAudioPCMBuffer, sampleRate: Float) async -> [ChordDetection] {
        print("*** BASIC PITCH HTTP CLIENT ANALYZE() CALLED ***")
        print("Server URL: \(serverURL)")
        print("  • Buffer: \(audioBuffer.frameLength) frames @ \(sampleRate) Hz")
        
        do {
            //first convert audio buffer to wav data
            print("Converting audio buffer to WAV...")
            let wavData = try convertAudioBufferToWAV(audioBuffer)
            print("  Created WAV data (\(wavData.count) bytes)")
            
            //then upload to server and get analysis results
            print("Sending audio to server at \(serverURL)/analyze...")
            let analysisResult = try await uploadAudioAndGetAnalysis(wavData)
            print("Received analysis from server:")
            print("   • \(analysisResult.notes.count) notes")
            print("   • \(analysisResult.chords.count) chords")
            if let key = analysisResult.key {
                print("   • Key: \(key.key) \(key.mode) (confidence: \(String(format: "%.2f", key.confidence)))")
            }
            
            //then use server's chord inference if available, otherwise fall back to local assembly
            let chordDetections: [ChordDetection]
            if !analysisResult.chords.isEmpty {
                print("Using server's advanced chord inference...")
                chordDetections = analysisResult.chords
            } else {
                print("Server chords unavailable, using local assembly...")
                let noteEvents = analysisResult.notes.map { apiNote in
                    NoteEvent(
                        onsetTime: apiNote.onset,
                        offsetTime: apiNote.offset,
                        midiPitch: apiNote.pitch,
                        confidence: Float(apiNote.confidence)
                    )
                }
                chordDetections = chordAssembler.assembleChords(from: noteEvents)
            }
            
            print("*** HTTP BASIC PITCH ANALYSIS COMPLETE ***")
            print("   Result: \(analysisResult.notes.count) notes -> \(chordDetections.count) chords")
            
            //print first few chords for debugging
            for (index, chord) in chordDetections.prefix(5).enumerated() {
                print("   Chord \(index + 1): \(chord.chordName) at \(String(format: "%.2f", chord.startTime))s")
            }
            
            return chordDetections
            
        } catch {
            print("*** HTTP BASIC PITCH ANALYSIS FAILED ***")
            print("   Error: \(error)")
            print("   Server URL: \(serverURL)")
            
            //fall back to simulation on network failure
            print("*** FALLING BACK TO SIMULATION ***")
            return await SimulatedChordAnalyzer().analyze(audioBuffer: audioBuffer, sampleRate: sampleRate)
        }
    }
    
    // MARK: - audio conversion
    
    //convert audio buffer to wav format for server upload
    private func convertAudioBufferToWAV(_ buffer: AVAudioPCMBuffer) throws -> Data {
        print("  Input buffer: \(buffer.format.channelCount) channels, \(buffer.frameLength) frames")
        
        //create mono format cos we always need a single channel for basic pitch
        guard let monoFormat = AVAudioFormat(standardFormatWithSampleRate: buffer.format.sampleRate, channels: 1) else {
            throw HTTPError.audioExportFailed
        }
        
        //convert to mono buffer
        let monoBuffer = try convertToMono(buffer: buffer, targetFormat: monoFormat)
        let originalSize = Int(buffer.frameLength) * Int(buffer.format.channelCount) * 4 // 4 bytes per float32
        let monoSize = Int(monoBuffer.frameLength) * Int(monoBuffer.format.channelCount) * 4
        
        print("  Converted to mono: \(monoBuffer.format.channelCount) channel, \(monoBuffer.frameLength) frames")
        print("  Size reduction: \(originalSize) -> \(monoSize) bytes (~\(Int(100 * Float(monoSize) / Float(originalSize)))%)")
        
        //create temporary file to export as wav
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")
        
        do {
            //create 16-bit pcm wav settings (compatible with all python audio loaders)
            let wavSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: monoFormat.sampleRate,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
            
            //create audio file for writing with 16-bit pcm wav format
            let audioFile = try AVAudioFile(forWriting: tempURL, settings: wavSettings)
            
            print("  Writing \(monoBuffer.frameLength) frames to WAV...")
            
            //write the mono buffer to file - synchronously
            try audioFile.write(from: monoBuffer)
            
            //force close the file to flush all data to disk
            //this is a safety net to make sure the wav file is complete before we read it
            //avaudiofile doesn't have an explicit close, but we can nil it
            
            //calculate expected file size for validation
            let expectedSampleCount = Int(monoBuffer.frameLength)
            let expectedFileSize = expectedSampleCount * 2 + 44  //16-bit = 2 bytes per sample + wav header
            
            print("  WAV write complete, validating file...")
            print("    Expected: \(expectedSampleCount) samples = ~\(expectedFileSize) bytes")
            
            //small delay to ensure file system flush (ios can be async)
            usleep(50_000)  //50ms using usleep instead of async task.sleep
            
            //validate file exists and has correct size
            var fileAttributes: [FileAttributeKey: Any]
            do {
                fileAttributes = try FileManager.default.attributesOfItem(atPath: tempURL.path)
                let actualFileSize = fileAttributes[.size] as? Int ?? 0
                print("    Actual file size: \(actualFileSize) bytes")
                
                if actualFileSize < expectedFileSize / 2 {
                    throw HTTPError.audioExportFailed  //file is clearly truncated
                }
                
                if actualFileSize == 0 {
                    throw HTTPError.audioExportFailed  //empty file
                }
            } catch {
                print("  Cannot read WAV file attributes: \(error)")
                throw HTTPError.audioExportFailed
            }
            
            //read the complete file data
            let data = try Data(contentsOf: tempURL)
            
            print("  Successfully exported WAV: \(data.count) bytes")
            
            //final size validation
            if data.count < expectedFileSize / 2 {
                print("  WAV file too small - export was truncated!")
                print("    Got: \(data.count) bytes, Expected: ~\(expectedFileSize) bytes")
                throw HTTPError.audioExportFailed
            }
            
            //clean up temp file
            try? FileManager.default.removeItem(at: tempURL)
            
            return data
            
        } catch {
            //clean up temp file on error
            try? FileManager.default.removeItem(at: tempURL)
            print("  Failed to export mono WAV: \(error)")
            throw HTTPError.audioExportFailed
        }
    }
    
    //convert audio buffer to mono format
    private func convertToMono(buffer: AVAudioPCMBuffer, targetFormat: AVAudioFormat) throws -> AVAudioPCMBuffer {
        guard let monoBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: buffer.frameLength) else {
            throw HTTPError.audioExportFailed
        }
        
        monoBuffer.frameLength = buffer.frameLength
        
        guard let inputData = buffer.floatChannelData,
              let outputData = monoBuffer.floatChannelData else {
            throw HTTPError.audioExportFailed
        }
        
        let frameCount = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        if channelCount == 1 {
            //already mono - just copy
            memcpy(outputData[0], inputData[0], frameCount * MemoryLayout<Float>.size)
        } else {
            //downmix stereo/multichannel to mono using simple averaging
            for frame in 0..<frameCount {
                var sum: Float = 0.0
                for channel in 0..<channelCount {
                    sum += inputData[channel][frame]
                }
                //simple average downmix (could use equal-power, but average seems fine for basic pitch)
                outputData[0][frame] = sum / Float(channelCount)
            }
        }
        
        return monoBuffer
    }
    
    // MARK: - network request
    
    //upload audio to server and get analysis results
    private func uploadAudioAndGetAnalysis(_ wavData: Data) async throws -> ServerAnalysisResult {
        guard let url = URL(string: "\(serverURL)/analyze") else {
            throw HTTPError.invalidURL
        }
        
        //create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        let body = createMultipartBody(wavData: wavData, boundary: boundary)
        
        //create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 120  //2 minutes timeout for large files
        
        //perform request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            //check http response
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw HTTPError.serverError("HTTP \(httpResponse.statusCode): \(errorMessage)")
                }
            }
            
            //parse json response
            let analysisResponse = try JSONDecoder().decode(AnalysisResponse.self, from: data)
            
            //convert server chords to chorddetection objects
            let chordDetections: [ChordDetection]
            if let serverChords = analysisResponse.chords, !serverChords.isEmpty {
                chordDetections = serverChords.map { apiChord in
                    ChordDetection(
                        startTime: apiChord.onset,
                        endTime: apiChord.offset,
                        chordName: apiChord.chord,
                        confidence: Float(apiChord.confidence),
                        pitchClasses: Set(apiChord.pitch_classes)
                    )
                }
            } else {
                chordDetections = []
            }
            
            return ServerAnalysisResult(
                notes: analysisResponse.notes,
                chords: chordDetections,
                key: analysisResponse.key
            )
            
        } catch let decodingError as DecodingError {
            print("JSON decoding error: \(decodingError)")
            throw HTTPError.decodingError(decodingError)
        } catch {
            print("Network error: \(error)")
            throw HTTPError.networkError(error)
        }
    }
    
    // MARK: - multipart form data
    
    //create multipart form body for file upload
    private func createMultipartBody(wavData: Data, boundary: String) -> Data {
        var body = Data()
        
        //add file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(wavData)
        body.append("\r\n".data(using: .utf8)!)
        
        //add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

// MARK: - api response models

//server analysis response structure
private struct AnalysisResponse: Codable {
    let notes: [APINote]
    let chords: [APIChord]?  //chord information from server
    let key: APIKeyInfo?      //key information from server
}

//note detection from server
private struct APINote: Codable {
    let onset: Double
    let offset: Double
    let pitch: Int
    let confidence: Double
}

//chord detection from server
private struct APIChord: Codable {
    let onset: Double
    let offset: Double
    let chord: String
    let confidence: Double
    let pitch_classes: [Int]
}

//key estimation from server
private struct APIKeyInfo: Codable {
    let key: String
    let mode: String
    let confidence: Double
}
