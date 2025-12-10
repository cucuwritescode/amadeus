import SwiftUI

struct CurrentChordPianoView: View {
    @ObservedObject var audioManager: AudioManager
    
    private func getHighlightedKeysForChord(_ chordName: String) -> Set<Int> {
        // Comprehensive chord mappings
        let chordKey = chordName.lowercased().replacingOccurrences(of: " ", with: "")
        
        // Parse chord into root note and quality
        var rootNote = 0
        var chordQuality = ""
        
        // Extract root note
        if chordKey.hasPrefix("c#") || chordKey.hasPrefix("db") {
            rootNote = 1
            chordQuality = String(chordKey.dropFirst(2))
        } else if chordKey.hasPrefix("d#") || chordKey.hasPrefix("eb") {
            rootNote = 3
            chordQuality = String(chordKey.dropFirst(2))
        } else if chordKey.hasPrefix("f#") || chordKey.hasPrefix("gb") {
            rootNote = 6
            chordQuality = String(chordKey.dropFirst(2))
        } else if chordKey.hasPrefix("g#") || chordKey.hasPrefix("ab") {
            rootNote = 8
            chordQuality = String(chordKey.dropFirst(2))
        } else if chordKey.hasPrefix("a#") || chordKey.hasPrefix("bb") {
            rootNote = 10
            chordQuality = String(chordKey.dropFirst(2))
        } else if chordKey.hasPrefix("c") {
            rootNote = 0
            chordQuality = String(chordKey.dropFirst(1))
        } else if chordKey.hasPrefix("d") {
            rootNote = 2
            chordQuality = String(chordKey.dropFirst(1))
        } else if chordKey.hasPrefix("e") {
            rootNote = 4
            chordQuality = String(chordKey.dropFirst(1))
        } else if chordKey.hasPrefix("f") {
            rootNote = 5
            chordQuality = String(chordKey.dropFirst(1))
        } else if chordKey.hasPrefix("g") {
            rootNote = 7
            chordQuality = String(chordKey.dropFirst(1))
        } else if chordKey.hasPrefix("a") {
            rootNote = 9
            chordQuality = String(chordKey.dropFirst(1))
        } else if chordKey.hasPrefix("b") {
            rootNote = 11
            chordQuality = String(chordKey.dropFirst(1))
        }
        
        // Get chord intervals based on quality
        var intervals: [Int] = []
        
        switch chordQuality {
        case "", "maj", "major": // Major
            intervals = [0, 4, 7]
        case "m", "min", "minor": // Minor
            intervals = [0, 3, 7]
        case "7", "dom7": // Dominant 7th
            intervals = [0, 4, 7, 10]
        case "maj7", "major7": // Major 7th
            intervals = [0, 4, 7, 11]
        case "m7", "min7", "minor7": // Minor 7th
            intervals = [0, 3, 7, 10]
        case "dim", "°": // Diminished triad
            intervals = [0, 3, 6]
        case "dim7", "°7": // Diminished 7th
            intervals = [0, 3, 6, 9]
        case "m7b5", "ø7", "half-dim": // Half-diminished 7th
            intervals = [0, 3, 6, 10]
        case "aug", "+": // Augmented
            intervals = [0, 4, 8]
        case "sus2": // Sus2
            intervals = [0, 2, 7]
        case "sus4": // Sus4
            intervals = [0, 5, 7]
        case "6": // Major 6th
            intervals = [0, 4, 7, 9]
        case "m6": // Minor 6th
            intervals = [0, 3, 7, 9]
        case "9": // Dominant 9th (often omit 5th in practical voicing)
            intervals = [0, 4, 10, 2]  // 1, 3, b7, 9
        case "maj9": // Major 9th (often omit 5th)
            intervals = [0, 4, 11, 2]  // 1, 3, 7, 9
        case "m9": // Minor 9th (often omit 5th)
            intervals = [0, 3, 10, 2]  // 1, b3, b7, 9
        case "add9": // Add 9 (no 7th)
            intervals = [0, 4, 7, 2]   // 1, 3, 5, 9
        case "11": // Dominant 11th (omit 3rd and 5th for practical voicing)
            intervals = [0, 10, 2, 5]  // 1, b7, 9, 11
        case "maj11": // Major 11th (omit 3rd due to dissonance)
            intervals = [0, 7, 11, 2, 5]  // 1, 5, 7, 9, 11
        case "m11": // Minor 11th (full voicing works better than maj11)
            intervals = [0, 3, 10, 2, 5]  // 1, b3, b7, 9, 11
        case "13": // Dominant 13th (essential tones: 1, 3, b7, 13)
            intervals = [0, 4, 10, 9]  // 1, 3, b7, 13
        case "maj13": // Major 13th (essential tones)
            intervals = [0, 4, 11, 9]  // 1, 3, 7, 13
        case "m13": // Minor 13th (essential tones)
            intervals = [0, 3, 10, 9]  // 1, b3, b7, 13
        case "7b9": // Dominant 7 flat 9
            intervals = [0, 4, 10, 1]  // 1, 3, b7, b9 (omit 5th)
        case "7#9": // Dominant 7 sharp 9 (Hendrix chord)
            intervals = [0, 4, 10, 3]  // 1, 3, b7, #9 (omit 5th)
        case "7b5": // Dominant 7 flat 5
            intervals = [0, 4, 6, 10]
        case "7#5": // Dominant 7 sharp 5
            intervals = [0, 4, 8, 10]
        default: // If we don't recognize it, try basic major
            print("⚠️ Unknown chord quality: '\(chordQuality)' for chord '\(chordName)'")
            intervals = [0, 4, 7]
        }
        
        // Transpose intervals to the root note and ensure they fit in one octave
        let finalKeys = intervals.map { interval in
            let transposed = (rootNote + interval) % 12
            return transposed
        }
        
        // Remove duplicates that might occur from octave reduction
        let result = Set(finalKeys)
        
        // Debug print to help diagnose chord mapping issues
        print("🎹 Chord: \(chordName) | Root: \(rootNote) | Quality: '\(chordQuality)' | Keys: \(result.sorted())")
        
        return result
    }
    
    private func transposeKeys(_ keys: Set<Int>, semitones: Int) -> Set<Int> {
        return Set(keys.map { ($0 + semitones + 12) % 12 })
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Only show if there's a current chord and it's not "—"
            if audioManager.currentChord != "—" {
                Text("Current Chord")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                CurrentChordPiano(
                    highlightedKeys: transposeKeys(
                        getHighlightedKeysForChord(audioManager.currentChord), 
                        semitones: 0 // Don't double transpose - AudioManager already handles this
                    ),
                    chordName: audioManager.currentChord
                )
                .frame(height: 70)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.3), value: audioManager.currentChord)
            } else {
                // Empty space when no chord
                Spacer().frame(height: 80)
            }
        }
    }
}

struct CurrentChordPiano: View {
    let highlightedKeys: Set<Int>
    let chordName: String
    
    private let whiteKeyNotes: [Int] = [0, 2, 4, 5, 7, 9, 11] // C, D, E, F, G, A, B
    private let blackKeyNotes: [Int] = [1, 3, 6, 8, 10] // C#, D#, F#, G#, A#
    
    private let blackKeyPositions: [CGFloat] = [0.85, 1.85, 3.85, 4.85, 5.85]
    
    var body: some View {
        VStack(spacing: 4) {
            // Chord name above piano
            Text(chordName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            // Compact piano
            GeometryReader { geometry in
                let whiteKeyWidth = geometry.size.width / 7
                let blackKeyWidth = whiteKeyWidth * 0.6
                let blackKeyHeight = geometry.size.height * 0.65
                
                ZStack(alignment: .topLeading) {
                    // White keys
                    HStack(spacing: 1) {
                        ForEach(0..<7, id: \.self) { keyIndex in
                            let noteValue = whiteKeyNotes[keyIndex]
                            Rectangle()
                                .fill(highlightedKeys.contains(noteValue) ? Color.blue.opacity(0.8) : Color.white)
                                .border(Color.gray, width: 0.5)
                                .cornerRadius(2)
                        }
                    }
                    
                    // Black keys
                    ForEach(Array(blackKeyNotes.enumerated()), id: \.offset) { index, noteValue in
                        let position = blackKeyPositions[index]
                        let xOffset = whiteKeyWidth * position
                        
                        Rectangle()
                            .fill(highlightedKeys.contains(noteValue) ? Color.blue : Color.black)
                            .frame(width: blackKeyWidth, height: blackKeyHeight)
                            .cornerRadius(2)
                            .position(x: xOffset, y: blackKeyHeight / 2)
                    }
                }
            }
            .frame(height: 45)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
}