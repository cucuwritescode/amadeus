//
//  ChordDetectorService.swift
//  Amadeus - chord detection protocol & fake implementation
//
//  
//  this file demonstrates protocol-oriented programming and dependency injection
//

import Foundation
import AudioKit
import Tonic  // for proper chord naming

// MARK: - Data Models
// these structures hold our chord detection data

/// represents a detected chord with confidence level
struct ChordResult: Equatable {
    let chord: Chord? // the detected chord
    let chordName: String // human-readable name like "C major" or "Am7"
    let confidence: Float // how confident we are (0.0 to 1.0)
    let timestamp: Date  // when this was detected
    let rootNote: String? // root note like "C", "F#", etc.
    let quality: String? // "major", "minor", "diminished", etc.
    
    /// Creates a "no chord detected" result
    static var noChord: ChordResult {
        ChordResult(
            chord: nil,
            chordName: "—",
            confidence: 0.0,
            timestamp: Date(),
            rootNote: nil,
            quality: nil
        )
    }
}

// MARK: - Protocol Definition
// tthis is the "contract" that all chord detectors must follow

/// protocol for any chord detection service
/// this allows us to swap implementations (fake vs real) easily
protocol ChordDetectorService {
    /// analyses audio and returns detected chord
    func detectChord(from amplitude: Float) -> ChordResult
    
    /// resets internal state (if any)
    func reset()
    
    /// returns true if the detector is ready
    var isReady: Bool { get }
}

// MARK: - Fake Implementation
// this simulates chord detection for UI development

/// fake chord detector that returns plausible chords without real analysis
/// perfect for UI development and testing
class FakeChordDetector: ChordDetectorService {
    
    // MARK: - Properties
    
    /// common chord progressions to make it seem realistic
    private let chordProgressions = [
        // pop progression (I-V-vi-IV in C)
        ["C", "G", "Am", "F"],
        // jazz progression (ii-V-I)
        ["Dm7", "G7", "Cmaj7"],
        // blues progression
        ["C7", "F7", "C7", "G7"],
        // folk progression
        ["G", "Em", "C", "D"],
        // minor progression
        ["Am", "Dm", "G", "C", "F", "E", "Am"]
    ]
    
    /// current progression we're "playing"
    private var currentProgression: [String] = []
    private var currentIndex = 0
    
    /// timer for changing chords
    private var lastChordChange = Date()
    private let chordDuration: TimeInterval = 1.5  // change every 1.5 seconds
    
    /// smoothing for confidence (makes it look more realistic)
    private var smoothedConfidence: Float = 0.75
    
    /// ready state
    var isReady: Bool = true
    
    // MARK: - Initialisation
    
    init() {
        // pick a random progression to start
        selectNewProgression()
    }
    
    // MARK: - Protocol Implementation
    
    /// simulates chord detection based on amplitude
    func detectChord(from amplitude: Float) -> ChordResult {
        
        // if it's too quiet, return "no chord"
        if amplitude < 0.05 {
            smoothedConfidence *= 0.9  // gradually decrease confidence
            return ChordResult.noChord
        }
        
        // check if it's time to change chord
        if Date().timeIntervalSince(lastChordChange) > chordDuration {
            moveToNextChord()
            lastChordChange = Date()
        }
        
        // get current chord name
        let chordName = currentProgression[currentIndex]
        
        // calculate confidence based on amplitude
        // higher amplitude = higher confidence (+some randomness)
        let baseConfidence = min(amplitude * 2, 0.95)  // cap at 95%
        let noise = Float.random(in: -0.05...0.05)      // add slight variation
        let targetConfidence = baseConfidence + noise
        
        // smooth the confidence (gradual changes look more realistic)
        smoothedConfidence = (smoothedConfidence * 0.7) + (targetConfidence * 0.3)
        
        // parse the chord using Tonic
        let (root, quality) = parseChordName(chordName)
        
        // create result
        return ChordResult(
            chord: nil,  // we're not using real Tonic Chord objects in fake mode
            chordName: chordName,
            confidence: max(0.1, min(1.0, smoothedConfidence)),  // clamp between 0.1 and 1.0
            timestamp: Date(),
            rootNote: root,
            quality: quality
        )
    }
    
    /// resets the detector state
    func reset() {
        selectNewProgression()
        currentIndex = 0
        lastChordChange = Date()
        smoothedConfidence = 0.75
    }
    
    // MARK: - Private Methods
    
    /// moves to the next chord in the progression
    private func moveToNextChord() {
        currentIndex = (currentIndex + 1) % currentProgression.count
        
        // occasionally switch to a new progression
        if currentIndex == 0 && Float.random(in: 0...1) > 0.7 {
            selectNewProgression()
        }
    }
    
    /// selects a new chord progression
    private func selectNewProgression() {
        currentProgression = chordProgressions.randomElement() ?? ["C", "G", "Am", "F"]
        currentIndex = 0
    }
    
    /// parses a chord name into root and quality
    private func parseChordName(_ name: String) -> (root: String?, quality: String?) {
        // simple parsing for common chord types
        // in real implementation, Tonic library would handle this properly
        
        // check for 7th chords
        if name.contains("maj7") {
            let root = name.replacingOccurrences(of: "maj7", with: "")
            return (root, "major 7th")
        }
        if name.contains("m7") {
            let root = name.replacingOccurrences(of: "m7", with: "")
            return (root, "minor 7th")
        }
        if name.contains("7") {
            let root = name.replacingOccurrences(of: "7", with: "")
            return (root, "dominant 7th")
        }
        
        // Check for minor
        if name.contains("m") {
            let root = name.replacingOccurrences(of: "m", with: "")
            return (root, "minor")
        }
        
        // otherwise it's major
        return (name, "major")
    }
}

// MARK: - Real Implementation Placeholder
// this is where the real chord detection will go

/// real chord detector using FFT and chroma analysis
/// TODO: Implement this with actual audio processing
class RealChordDetector: ChordDetectorService {
    
    var isReady: Bool = false
    
    init() {
        // TODO: Initialize FFT, chroma extraction, etc.
        print("RealChordDetector: Not yet implemented - using fake detector")
    }
    
    func detectChord(from amplitude: Float) -> ChordResult {
        // TODO: Implement real chord detection
        // 1))) get FFT data from audio buffer
        // 2))) extract chroma features
        // 3))) match against chord templates
        // 4))) use Tonic to name the chord properly
        
        return ChordResult.noChord
    }
    
    func reset() {
        // TODO: reset any internal state
    }
}
