import Foundation
//created by Facundo Franchino
// MARK: - Note Event Data Structure

struct NoteEvent {
    let onsetTime: Double
    let offsetTime: Double
    let midiPitch: Int
    let confidence: Float
    
    var duration: Double {
        return offsetTime - onsetTime
    }
    
    var pitchClass: Int {
        return midiPitch % 12
    }
    
    var isValid: Bool {
        return onsetTime >= 0 && 
               offsetTime > onsetTime && 
               midiPitch >= 0 && 
               midiPitch <= 127 &&
               confidence >= 0 && 
               confidence <= 1
    }
}


// MARK: - Basic Pitch Output Processing

struct BasicPitchOutput {
    let onsetProbs: [[Float]]  // [time][pitch]
    let frameProbs: [[Float]]  // [time][pitch]
    let contourProbs: [[Float]]? // Optional pitch bend data
    
    var numTimeFrames: Int { onsetProbs.count }
    var numPitches: Int { onsetProbs.first?.count ?? 0 }
    
    func timeForFrame(_ frame: Int) -> Double {
        // Using hardcoded values since BasicPitchConfig is in separate file
        let hopLength = 255
        let sampleRate = 22050.0
        return Double(frame * hopLength) / sampleRate
    }
}
