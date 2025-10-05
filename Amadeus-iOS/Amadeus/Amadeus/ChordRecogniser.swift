//
//  ChordRecogniser.swift
//  Amadeus - Advanced chord recognition using CQT-derived chromagrams
//
//  This module implements triad and extended chord recognition using template matching
//  with chromagram features derived from the Constant-Q Transform.
//  Based on music theory principles and optimised for real-time detection.
//

import Foundation

// MARK: - Chord Templates

/// Chord quality definitions and their interval patterns
enum ChordQuality: String, CaseIterable {
    case major = "major"
    case minor = "minor"
    case diminished = "diminished"
    case augmented = "augmented"
    case dominantSeventh = "dominant 7th"
    case majorSeventh = "major 7th"
    case minorSeventh = "minor 7th"
    case halfDiminishedSeventh = "half-diminished 7th"
    case diminishedSeventh = "diminished 7th"
    case sus2 = "sus2"
    case sus4 = "sus4"
    
    /// Semitone intervals from root for this chord quality
    /// These define the theoretical pitch content of each chord type
    var intervals: [Int] {
        switch self {
        case .major:
            return [0, 4, 7]  // Root, major third, perfect fifth
        case .minor:
            return [0, 3, 7]  // Root, minor third, perfect fifth
        case .diminished:
            return [0, 3, 6]  // Root, minor third, diminished fifth
        case .augmented:
            return [0, 4, 8]  // Root, major third, augmented fifth
        case .dominantSeventh:
            return [0, 4, 7, 10]  // Major triad + minor seventh
        case .majorSeventh:
            return [0, 4, 7, 11]  // Major triad + major seventh
        case .minorSeventh:
            return [0, 3, 7, 10]  // Minor triad + minor seventh
        case .halfDiminishedSeventh:
            return [0, 3, 6, 10]  // Diminished triad + minor seventh
        case .diminishedSeventh:
            return [0, 3, 6, 9]   // Diminished triad + diminished seventh
        case .sus2:
            return [0, 2, 7]      // Root, major second, perfect fifth
        case .sus4:
            return [0, 5, 7]      // Root, perfect fourth, perfect fifth
        }
    }
    
    /// Symbol used in chord naming
    var symbol: String {
        switch self {
        case .major: return ""
        case .minor: return "m"
        case .diminished: return "°"
        case .augmented: return "+"
        case .dominantSeventh: return "7"
        case .majorSeventh: return "maj7"
        case .minorSeventh: return "m7"
        case .halfDiminishedSeventh: return "ø7"
        case .diminishedSeventh: return "°7"
        case .sus2: return "sus2"
        case .sus4: return "sus4"
        }
    }
    
    /// Priority for template matching - more common chords get priority
    var priority: Int {
        switch self {
        case .major: return 10
        case .minor: return 10
        case .dominantSeventh: return 8
        case .majorSeventh: return 7
        case .minorSeventh: return 7
        case .sus4: return 6
        case .sus2: return 5
        case .diminished: return 4
        case .augmented: return 3
        case .halfDiminishedSeventh: return 2
        case .diminishedSeventh: return 1
        }
    }
}

// MARK: - Chord Template

/// Template for chord recognition using chromagram matching
struct ChordTemplate {
    /// Root note index (0-11, where 0=C, 1=C#, etc.)
    let rootIndex: Int
    
    /// Chord quality (major, minor, etc.)
    let quality: ChordQuality
    
    /// Template vector for chromagram matching
    /// Each element represents the expected strength of a pitch class
    let template: [Float]
    
    /// Chord name for display
    var name: String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return noteNames[rootIndex] + quality.symbol
    }
    
    /// Full chord description
    var fullName: String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return noteNames[rootIndex] + " " + quality.rawValue
    }
    
    init(rootIndex: Int, quality: ChordQuality) {
        self.rootIndex = rootIndex
        self.quality = quality
        
        // Generate template vector for this chord
        var template = [Float](repeating: 0.0, count: 12)
        
        // Set strength for each chord tone
        for interval in quality.intervals {
            let pitchClass = (rootIndex + interval) % 12
            
            // Weight chord tones by importance
            switch interval {
            case 0:  // Root
                template[pitchClass] = 1.0
            case 3, 4:  // Third (determines major/minor)
                template[pitchClass] = 0.8
            case 7:  // Fifth
                template[pitchClass] = 0.6
            default:  // Extensions (7ths, etc.)
                template[pitchClass] = 0.4
            }
        }
        
        self.template = template
    }
}

// MARK: - Chord Database

/// Database of all chord templates for matching
class ChordDatabase {
    /// All possible chord templates
    private let templates: [ChordTemplate]
    
    /// Templates organised by priority for efficient searching
    private let prioritisedTemplates: [ChordTemplate]
    
    init() {
        var allTemplates: [ChordTemplate] = []
        
        // Generate templates for all root notes and qualities
        for rootIndex in 0..<12 {
            for quality in ChordQuality.allCases {
                allTemplates.append(ChordTemplate(rootIndex: rootIndex, quality: quality))
            }
        }
        
        self.templates = allTemplates
        
        // Sort by priority (most common chords first)
        self.prioritisedTemplates = allTemplates.sorted { template1, template2 in
            if template1.quality.priority != template2.quality.priority {
                return template1.quality.priority > template2.quality.priority
            }
            // If same priority, sort by root (C, C#, D, etc.)
            return template1.rootIndex < template2.rootIndex
        }
    }
    
    /// Get all templates
    func getAllTemplates() -> [ChordTemplate] {
        return templates
    }
    
    /// Get templates sorted by priority
    func getPrioritisedTemplates() -> [ChordTemplate] {
        return prioritisedTemplates
    }
}

// MARK: - Chord Recognition Engine

/// Main chord recognition engine using template matching
class ChordRecogniser {
    
    /// Database of chord templates
    private let chordDatabase = ChordDatabase()
    
    /// Minimum correlation threshold for chord detection
    private let minimumCorrelationThreshold: Float = 0.3
    
    /// Minimum energy threshold (to avoid detecting chords in silence)
    private let minimumEnergyThreshold: Float = 0.1
    
    /// History buffer for temporal smoothing
    private var recognitionHistory: [ChordTemplate?] = []
    private let historyLength = 5  // Keep last 5 recognitions for smoothing
    
    init() {
        print("ChordRecogniser: Initialised with \(chordDatabase.getAllTemplates().count) chord templates")
    }
    
    // MARK: - Main Recognition Method
    
    /// Recognise chord from chromagram using template matching
    /// - Parameter chromagram: 12-element array of pitch class energies (normalised 0-1)
    /// - Returns: Best matching chord with confidence score
    func recogniseChord(from chromagram: [Float]) -> (template: ChordTemplate?, confidence: Float) {
        
        // Check if we have enough energy to detect a chord
        let totalEnergy = chromagram.reduce(0, +)
        guard totalEnergy > minimumEnergyThreshold else {
            updateHistory(with: nil)
            return (nil, 0.0)
        }
        
        // Normalise chromagram to unit vector for correlation
        let normalisedChroma = normaliseVector(chromagram)
        
        var bestTemplate: ChordTemplate?
        var bestCorrelation: Float = 0.0
        
        // Try all chord templates, prioritising common chords
        for template in chordDatabase.getPrioritisedTemplates() {
            
            // Calculate correlation between chromagram and template
            let correlation = correlate(normalisedChroma, template.template)
            
            // Early exit for high-priority chords with good matches
            if correlation > bestCorrelation {
                bestCorrelation = correlation
                bestTemplate = template
                
                // If we find a very strong match for a high-priority chord, stop searching
                if correlation > 0.8 && template.quality.priority >= 8 {
                    break
                }
            }
        }
        
        // Apply threshold
        guard bestCorrelation > minimumCorrelationThreshold else {
            updateHistory(with: nil)
            return (nil, 0.0)
        }
        
        // Update history for temporal smoothing
        updateHistory(with: bestTemplate)
        
        // Apply temporal smoothing if enabled
        let smoothedTemplate = applyTemporalSmoothing()
        
        return (smoothedTemplate ?? bestTemplate, bestCorrelation)
    }
    
    // MARK: - Helper Methods
    
    /// Normalise vector to unit length for correlation calculation
    private func normaliseVector(_ vector: [Float]) -> [Float] {
        let magnitude = sqrt(vector.map { $0 * $0 }.reduce(0, +))
        guard magnitude > 0 else { return vector }
        
        return vector.map { $0 / magnitude }
    }
    
    /// Calculate Pearson correlation coefficient between two vectors
    private func correlate(_ vector1: [Float], _ vector2: [Float]) -> Float {
        guard vector1.count == vector2.count && vector1.count > 0 else { return 0.0 }
        
        let n = Float(vector1.count)
        
        // Calculate means
        let mean1 = vector1.reduce(0, +) / n
        let mean2 = vector2.reduce(0, +) / n
        
        // Calculate correlation components
        var numerator: Float = 0.0
        var sumSquares1: Float = 0.0
        var sumSquares2: Float = 0.0
        
        for i in 0..<vector1.count {
            let diff1 = vector1[i] - mean1
            let diff2 = vector2[i] - mean2
            
            numerator += diff1 * diff2
            sumSquares1 += diff1 * diff1
            sumSquares2 += diff2 * diff2
        }
        
        // Calculate correlation coefficient
        let denominator = sqrt(sumSquares1 * sumSquares2)
        guard denominator > 0 else { return 0.0 }
        
        return numerator / denominator
    }
    
    /// Update recognition history buffer
    private func updateHistory(with template: ChordTemplate?) {
        recognitionHistory.append(template)
        
        // Maintain history length
        if recognitionHistory.count > historyLength {
            recognitionHistory.removeFirst()
        }
    }
    
    /// Apply temporal smoothing to reduce flickering between similar chords
    private func applyTemporalSmoothing() -> ChordTemplate? {
        guard !recognitionHistory.isEmpty else { return nil }
        
        // Count occurrences of each chord in recent history
        var chordCounts: [String: (template: ChordTemplate, count: Int)] = [:]
        
        for template in recognitionHistory.compactMap({ $0 }) {
            let key = template.name
            if let existing = chordCounts[key] {
                chordCounts[key] = (template: existing.template, count: existing.count + 1)
            } else {
                chordCounts[key] = (template: template, count: 1)
            }
        }
        
        // Find most frequent chord
        let mostFrequent = chordCounts.max { pair1, pair2 in
            pair1.value.count < pair2.value.count
        }
        
        // Only apply smoothing if the most frequent chord appears more than once
        if let frequent = mostFrequent, frequent.value.count > 1 {
            return frequent.value.template
        }
        
        // Otherwise return the most recent detection
        return recognitionHistory.last ?? nil
    }
    
    /// Reset recognition history (call when starting new session)
    func reset() {
        recognitionHistory.removeAll()
    }
    
    // MARK: - Analysis Methods
    
    /// Get the most likely chord candidates with scores
    func getTopCandidates(from chromagram: [Float], count: Int = 5) -> [(template: ChordTemplate, score: Float)] {
        let normalisedChroma = normaliseVector(chromagram)
        
        var candidates: [(template: ChordTemplate, score: Float)] = []
        
        for template in chordDatabase.getAllTemplates() {
            let correlation = correlate(normalisedChroma, template.template)
            candidates.append((template: template, score: correlation))
        }
        
        // Sort by score and return top candidates
        candidates.sort { $0.score > $1.score }
        return Array(candidates.prefix(count))
    }
    
    /// Analyse chromagram and return detailed information
    func analyseChromagram(_ chromagram: [Float]) -> ChromagramAnalysis {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Find peak notes
        let maxEnergy = chromagram.max() ?? 0.0
        let threshold = maxEnergy * 0.3  // Notes above 30% of max
        
        var prominentNotes: [(note: String, energy: Float)] = []
        for i in 0..<12 {
            if chromagram[i] > threshold {
                prominentNotes.append((note: noteNames[i], energy: chromagram[i]))
            }
        }
        
        // Sort by energy
        prominentNotes.sort { $0.energy > $1.energy }
        
        // Calculate clarity (how "peaky" the chromagram is)
        let mean = chromagram.reduce(0, +) / Float(chromagram.count)
        let variance = chromagram.map { pow($0 - mean, 2) }.reduce(0, +) / Float(chromagram.count)
        let clarity = sqrt(variance)
        
        return ChromagramAnalysis(
            prominentNotes: prominentNotes,
            clarity: clarity,
            totalEnergy: chromagram.reduce(0, +)
        )
    }
}

// MARK: - Analysis Results

/// Detailed analysis of a chromagram
struct ChromagramAnalysis {
    /// Notes with significant energy
    let prominentNotes: [(note: String, energy: Float)]
    
    /// How "clear" or "peaky" the chromagram is (0-1)
    let clarity: Float
    
    /// Total energy across all pitch classes
    let totalEnergy: Float
    
    /// Whether this represents a clear harmonic signal
    var isHarmonic: Bool {
        return clarity > 0.2 && totalEnergy > 0.1 && prominentNotes.count >= 2
    }
}