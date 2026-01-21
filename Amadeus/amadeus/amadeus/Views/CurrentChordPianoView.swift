//
//  CurrentChordPianoView.swift
//  amadeus
//
//  created by facundo franchino on 20/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  visual piano keyboard showing currently playing chord notes
//  highlights active keys based on detected chord during playback
//
//  acknowledgements:
//  - chord interval mappings based on standard western music theory
//  - piano key layout follows standard 7 white + 5 black key octave pattern
//

import SwiftUI

// MARK: - Current Chord Piano View

//container view that manages the piano display based on current playback chord
//observes the audio manager for real-time chord updates
struct CurrentChordPianoView: View {
    //observed audio manager providing current chord and pitch shift data
    @ObservedObject var audioManager: AudioManager

    //parses a chord name and returns the set of pitch classes (0-11) that should be highlighted
    //handles root note extraction and chord quality interval mapping
    private func getHighlightedKeysForChord(_ chordName: String) -> Set<Int> {
        //normalise chord name for parsing (lowercase, no spaces)
        let chordKey = chordName.lowercased().replacingOccurrences(of: " ", with: "")

        //variables to hold parsed root note (as semitone 0-11) and chord quality string
        var rootNote = 0
        var chordQuality = ""

        //extract root note from chord name
        //handles both sharp and flat enharmonic equivalents
        //accidentals (# or b) must be checked first as they're two characters
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

        //determine chord intervals based on quality string
        //intervals are semitone offsets from root (0 = root, 4 = major 3rd, 7 = perfect 5th, etc.)
        var intervals: [Int] = []

        switch chordQuality {
        case "", "maj", "major": //major triad
            intervals = [0, 4, 7]
        case "m", "min", "minor": //minor triad
            intervals = [0, 3, 7]
        case "7", "dom7": //dominant 7th
            intervals = [0, 4, 7, 10]
        case "maj7", "major7": //major 7th
            intervals = [0, 4, 7, 11]
        case "m7", "min7", "minor7": //minor 7th
            intervals = [0, 3, 7, 10]
        case "dim", "°": //diminished triad
            intervals = [0, 3, 6]
        case "dim7", "°7": //diminished 7th (fully diminished)
            intervals = [0, 3, 6, 9]
        case "m7b5", "ø7", "half-dim": //half-diminished 7th (minor 7 flat 5)
            intervals = [0, 3, 6, 10]
        case "aug", "+": //augmented triad
            intervals = [0, 4, 8]
        case "sus2": //suspended 2nd
            intervals = [0, 2, 7]
        case "sus4": //suspended 4th
            intervals = [0, 5, 7]
        case "6": //major 6th
            intervals = [0, 4, 7, 9]
        case "m6": //minor 6th
            intervals = [0, 3, 7, 9]
        case "9": //dominant 9th (practical voicing omits 5th)
            intervals = [0, 4, 10, 2]  // 1, 3, b7, 9
        case "maj9": //major 9th (practical voicing omits 5th)
            intervals = [0, 4, 11, 2]  // 1, 3, 7, 9
        case "m9": //minor 9th (practical voicing omits 5th)
            intervals = [0, 3, 10, 2]  // 1, b3, b7, 9
        case "add9": //add 9 (no 7th, just triad plus 9)
            intervals = [0, 4, 7, 2]   // 1, 3, 5, 9
        case "11": //dominant 11th (omit 3rd and 5th for practical voicing)
            intervals = [0, 10, 2, 5]  // 1, b7, 9, 11
        case "maj11": //major 11th (omit 3rd due to dissonance with 11)
            intervals = [0, 7, 11, 2, 5]  // 1, 5, 7, 9, 11
        case "m11": //minor 11th (full voicing works better than maj11)
            intervals = [0, 3, 10, 2, 5]  // 1, b3, b7, 9, 11
        case "13": //dominant 13th (essential tones only)
            intervals = [0, 4, 10, 9]  // 1, 3, b7, 13
        case "maj13": //major 13th (essential tones)
            intervals = [0, 4, 11, 9]  // 1, 3, 7, 13
        case "m13": //minor 13th (essential tones)
            intervals = [0, 3, 10, 9]  // 1, b3, b7, 13
        case "7b9": //dominant 7 flat 9 (altered dominant)
            intervals = [0, 4, 10, 1]  // 1, 3, b7, b9 (omit 5th)
        case "7#9": //dominant 7 sharp 9 (hendrix chord)
            intervals = [0, 4, 10, 3]  // 1, 3, b7, #9 (omit 5th)
        case "7b5": //dominant 7 flat 5
            intervals = [0, 4, 6, 10]
        case "7#5": //dominant 7 sharp 5
            intervals = [0, 4, 8, 10]
        default: //unrecognised quality defaults to major triad
            print("⚠️ Unknown chord quality: '\(chordQuality)' for chord '\(chordName)'")
            intervals = [0, 4, 7]
        }

        //transpose intervals to the actual root note and wrap within single octave
        let finalKeys = intervals.map { interval in
            let transposed = (rootNote + interval) % 12
            return transposed
        }

        //convert to set to remove any duplicates from octave reduction
        let result = Set(finalKeys)

        //debug output for troubleshooting chord mapping
        print("🎹 Chord: \(chordName) | Root: \(rootNote) | Quality: '\(chordQuality)' | Keys: \(result.sorted())")

        return result
    }

    //transposes a set of pitch classes by the given number of semitones
    //handles negative transposition with modulo arithmetic
    private func transposeKeys(_ keys: Set<Int>, semitones: Int) -> Set<Int> {
        return Set(keys.map { ($0 + semitones + 12) % 12 })
    }
    
    var body: some View {
        VStack(spacing: 8) {
            //only show piano when there's an active chord being played
            if audioManager.currentChord != "—" {
                //section label above the piano
                Text("Current Chord")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                //piano visualisation with highlighted chord notes
                CurrentChordPiano(
                    highlightedKeys: transposeKeys(
                        getHighlightedKeysForChord(audioManager.currentChord),
                        semitones: 0 //don't double transpose, audio manager already handles transposition
                    ),
                    chordName: audioManager.currentChord
                )
                .frame(height: 70)
                //smooth transition when chord changes
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.3), value: audioManager.currentChord)
            } else {
                //placeholder space when no chord is playing to maintain layout
                Spacer().frame(height: 80)
            }
        }
    }
}

// MARK: - Current Chord Piano

//visual piano keyboard component showing a single octave with highlighted keys
//displays chord name above the keyboard visualisation
struct CurrentChordPiano: View {
    //set of pitch classes (0-11) to highlight on the keyboard
    let highlightedKeys: Set<Int>

    //chord name to display above the piano
    let chordName: String

    //pitch class values for the seven white keys (c, d, e, f, g, a, b)
    private let whiteKeyNotes: [Int] = [0, 2, 4, 5, 7, 9, 11]

    //pitch class values for the five black keys (c#, d#, f#, g#, a#)
    private let blackKeyNotes: [Int] = [1, 3, 6, 8, 10]

    //horizontal positions for black keys relative to white key widths
    //positions place black keys between appropriate white keys
    private let blackKeyPositions: [CGFloat] = [0.85, 1.85, 3.85, 4.85, 5.85]

    var body: some View {
        VStack(spacing: 4) {
            //chord name label above piano
            Text(chordName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            //piano keyboard using geometry reader for responsive sizing
            GeometryReader { geometry in
                //calculate key dimensions based on available width
                let whiteKeyWidth = geometry.size.width / 7
                let blackKeyWidth = whiteKeyWidth * 0.6
                let blackKeyHeight = geometry.size.height * 0.65

                ZStack(alignment: .topLeading) {
                    //white keys layer (background)
                    HStack(spacing: 1) {
                        ForEach(0..<7, id: \.self) { keyIndex in
                            let noteValue = whiteKeyNotes[keyIndex]
                            //white key with blue highlight when part of current chord
                            Rectangle()
                                .fill(highlightedKeys.contains(noteValue) ? Color.blue.opacity(0.8) : Color.white)
                                .border(Color.gray, width: 0.5)
                                .cornerRadius(2)
                        }
                    }

                    //black keys layer (foreground, positioned absolutely)
                    ForEach(Array(blackKeyNotes.enumerated()), id: \.offset) { index, noteValue in
                        let position = blackKeyPositions[index]
                        let xOffset = whiteKeyWidth * position

                        //black key with blue highlight when part of current chord
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
        //card background for the piano
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
}
