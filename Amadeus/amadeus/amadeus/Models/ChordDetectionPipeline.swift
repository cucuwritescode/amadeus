//
//  ChordDetectionPipeline.swift
//  amadeus
//
//  created by facundo franchino on 07/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  main pipeline coordinating audio analysis through basic pitch
//  manages the flow from audio input to chord detection output
//
//  acknowledgements:
//  - basic pitch neural network by rachel bittner et al. (icassp 2022)
//  - audiokit framework for audio file handling 
//

import Foundation
import AVFoundation
import Accelerate
//created by Facundo Franchino
// MARK: - data structures

// represents a detected chord with timing and confidence
struct ChordDetection: Codable {
    let startTime: Double
    let endTime: Double
    let chordName: String
    let confidence: Float
    let pitchClasses: Set<Int>
}

// contains complete analysis results for an audio file
struct AnalysisResult {
    let detections: [ChordDetection]
    let estimatedKey: String
    let tempo: Float?
    let duration: Double
}

// MARK: - analysis pipeline protocol

//protocol for chord analysis implementations
protocol ChordAnalyzer {
    func analyze(audioBuffer: AVAudioPCMBuffer, sampleRate: Float) async -> [ChordDetection]
}

// MARK: - main pipeline

//orchestrates the complete chord detection and analysis process
class ChordDetectionPipeline {
    
// possible errors during analysis
    enum AnalysisError: Error {
        case failedToReadFile
        case invalidAudioFormat
        case processingFailed
    }
    
    private let analyzer: ChordAnalyzer
    
// initialise pipeline with appropriate analyser based on configuration
    init(analyzer: ChordAnalyzer? = nil) {
        if let analyzer = analyzer {
            self.analyzer = analyzer
        } else {
//choose analyser based on configuration
            switch BasicPitchConfig.defaultMode {
            case .http(let serverURL):
                self.analyzer = BasicPitchHTTPClient(serverURL: serverURL)
            case .coreML:
                self.analyzer = BasicPitchAnalyzer()
            case .simulation:
                self.analyzer = SimulatedChordAnalyzer()
            }
        }
        print("ChordDetectionPipeline initialized with: \(type(of: self.analyzer))")
    }
    
// main analysis entry point for processing audio files
    func analyzeFile(_ url: URL, progress: ((Float) -> Void)? = nil) async throws -> AnalysisResult {
        
//load audio file
        progress?(0.1)
        let audioFile = try AVAudioFile(forReading: url)
        
// then extract audio buffer
        progress?(0.2)
        guard let buffer = extractAudioBuffer(from: audioFile) else {
            throw AnalysisError.failedToReadFile
        }
        
//then run basic pitch analysis
        progress?(0.3)
        let detections = await analyzer.analyze(
            audioBuffer: buffer,
            sampleRate: Float(audioFile.fileFormat.sampleRate)
        )
        
//apply chord smoothing
        progress?(0.75)
        let smoothedDetections = smoothChords(detections)
        
//estimate key from smoothed detections
        progress?(0.9)
        let estimatedKey = estimateKey(from: smoothedDetections)
        
//package results
        progress?(1.0)
        return AnalysisResult(
            detections: smoothedDetections,
            estimatedKey: estimatedKey,
            tempo: nil, //future: beat tracking
            duration: Double(audioFile.length) / audioFile.fileFormat.sampleRate
        )
    }
    
// extract pcm buffer from audio file
    private func extractAudioBuffer(from audioFile: AVAudioFile) -> AVAudioPCMBuffer? {
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        do {
            try audioFile.read(into: buffer)
            buffer.frameLength = frameCount
            return buffer
        } catch {
            print("Error reading audio buffer: \(error)")
            return nil
        }
    }
    
// apply median filtering to smooth chord transitions
    private func smoothChords(_ detections: [ChordDetection]) -> [ChordDetection] {
        guard detections.count > 2 else { return detections }
        
        var smoothedDetections = detections
        let _ = 3 //window size for median filter
        
// apply median filter with window size 3
        for i in 1..<(detections.count - 1) {
            let window = [
                detections[i-1].chordName,
                detections[i].chordName,
                detections[i+1].chordName
            ]
            
// find the modal (most common) chord in the window
            let chordCounts = window.reduce(into: [:]) { counts, chord in
                counts[chord, default: 0] += 1
            }
            
            if let modalChord = chordCounts.max(by: { $0.value < $1.value })?.key {
// only smooth if the modal chord is different and appears more than once
                if modalChord != detections[i].chordName && chordCounts[modalChord, default: 0] > 1 {
                    smoothedDetections[i] = ChordDetection(
                        startTime: detections[i].startTime,
                        endTime: detections[i].endTime,
                        chordName: modalChord,
                        confidence: detections[i].confidence * 0.9, //slightly reduce confidence
                        pitchClasses: detections[i].pitchClasses
                    )
                }
            }
        }
        
        return smoothedDetections
    }
    
//improved key estimation using chord function analysis
    private func estimateKey(from detections: [ChordDetection]) -> String {
        guard !detections.isEmpty else { return "Unknown" }
        
//count pitch class occurrences weighted by chord duration
        var pitchClassWeights = [Int: Double]()
        var totalDuration: Double = 0
        
        for detection in detections {
            let duration = detection.endTime - detection.startTime
            totalDuration += duration
            
            for pitchClass in detection.pitchClasses {
                pitchClassWeights[pitchClass, default: 0] += duration
            }
        }
        
        guard !pitchClassWeights.isEmpty else { return "Unknown" }
        
// normalise weights
        for key in pitchClassWeights.keys {
            pitchClassWeights[key]! /= totalDuration
        }
        
//major and minor key profiles (krumhansl-schmuckler)
        let majorProfile: [Double] = [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88]
        let minorProfile: [Double] = [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17]
        
        var bestKey = "C major"
        var bestScore = -Double.infinity
        
        let keyNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
//test all 24 keys (12 major + 12 minor)
        for tonic in 0..<12 {
//test major key
            var majorScore: Double = 0
            for pitchClass in 0..<12 {
                let profileIndex = (pitchClass - tonic + 12) % 12
                let weight = pitchClassWeights[pitchClass] ?? 0
                majorScore += weight * majorProfile[profileIndex]
            }
            
            if majorScore > bestScore {
                bestScore = majorScore
                bestKey = "\(keyNames[tonic]) major"
            }
            
//test minor key
            var minorScore: Double = 0
            for pitchClass in 0..<12 {
                let profileIndex = (pitchClass - tonic + 12) % 12
                let weight = pitchClassWeights[pitchClass] ?? 0
                minorScore += weight * minorProfile[profileIndex]
            }
            
            if minorScore > bestScore {
                bestScore = minorScore
                bestKey = "\(keyNames[tonic]) minor"
            }
        }
        
        return bestKey
    }
}

// MARK: - simulated analyser (for dec 11)

//simulated chord analyser for testing and demonstration
class SimulatedChordAnalyzer: ChordAnalyzer {
    
    func analyze(audioBuffer: AVAudioPCMBuffer, sampleRate: Float) async -> [ChordDetection] {
//simulate processing time
        try? await Task.sleep(nanoseconds: 500_000_000) //0.5 seconds
        
//generate realistic chord progression based on audio length
        let duration = Double(audioBuffer.frameLength) / Double(sampleRate)
        return generateSimulatedProgression(duration: duration)
    }
    
//generate simulated chord progression for testing
    private func generateSimulatedProgression(duration: Double) -> [ChordDetection] {
        var detections: [ChordDetection] = []
        
// common progression: i - vi - iv - v
        let progression = [
            ("C", Set([0, 4, 7])),      //c major
            ("Am", Set([9, 0, 4])),      //a minor
            ("F", Set([5, 9, 0])),       //f major
            ("G", Set([7, 11, 2]))       //g major
        ]
        
        let chordDuration = 2.0 //2 seconds per chord
        var currentTime = 0.0
        var chordIndex = 0
        
        while currentTime < duration {
            let (chordName, pitchClasses) = progression[chordIndex % progression.count]
            let endTime = min(currentTime + chordDuration, duration)
            
            detections.append(ChordDetection(
                startTime: currentTime,
                endTime: endTime,
                chordName: chordName,
                confidence: Float.random(in: 0.85...0.95),
                pitchClasses: pitchClasses
            ))
            
            currentTime = endTime
            chordIndex += 1
        }
        
        return detections
    }
}

