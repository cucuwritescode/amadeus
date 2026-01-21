//
//  ChordDetailView.swift
//  amadeus
//
//  created by facundo franchino on 18/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  detailed chord information view with intervals and formula
//  legacy view maintained for backward compatibility
//
//  acknowledgements:
//  - chord theory based on western music harmony conventions
//  - piano keyboard layout follows standard octave mapping
//

import SwiftUI

// MARK: - Chord Detail View (Legacy)

//displays detailed chord information including intervals and formula
//legacy view maintained for backward compatibility with older navigation
struct ChordDetailView: View {
    //chord root note name (e.g., "C", "Am")
    let chordName: String

    //chord quality type (e.g., "Major", "Minor", "7th")
    let chordType: String

    //controls visibility of coming soon alert for play button
    @State private var showPlayAlert = false

    //computed property returning interval names for the chord type
    //intervals describe the distance between each note and the root
    var intervals: [String] {
        switch chordType {
        case "Major": return ["Root", "Major 3rd", "Perfect 5th"]
        case "Minor": return ["Root", "Minor 3rd", "Perfect 5th"]
        case "7th": return ["Root", "Major 3rd", "Perfect 5th", "Minor 7th"]
        case "maj7": return ["Root", "Major 3rd", "Perfect 5th", "Major 7th"]
        default: return ["Root", "3rd", "5th"]
        }
    }

    //computed property returning the numeric formula for the chord
    //formula shows scale degrees (b = flat, # = sharp)
    var formula: String {
        switch chordType {
        case "Major": return "1 - 3 - 5"
        case "Minor": return "1 - b3 - 5"
        case "7th": return "1 - 3 - 5 - b7"
        case "maj7": return "1 - 3 - 5 - 7"
        default: return "1 - 3 - 5"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                //chord name header with large display
                VStack {
                    //chord symbol in large bold text
                    Text(chordName)
                        .font(.system(size: 48, weight: .bold))
                    //chord quality label below
                    Text(chordType)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding()

                //piano keyboard showing chord voicing
                PianoView(highlightedNotes: getHighlightedNotes())
                    .frame(height: 150)
                    .padding()

                //intervals section listing each note's relationship to root
                VStack(alignment: .leading, spacing: 12) {
                    Text("Intervals")
                        .font(.headline)

                    //list each interval with numbered badge
                    ForEach(Array(intervals.enumerated()), id: \.offset) { index, interval in
                        HStack {
                            //circular badge with position number
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(index + 1)")
                                        .fontWeight(.bold)
                                )

                            //interval name
                            Text(interval)
                                .font(.body)

                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                //formula section showing numeric representation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Formula")
                        .font(.headline)
                    //formula in monospaced font for clarity
                    Text(formula)
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()

                //description section explaining chord character
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(getChordDescription())
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()

                //play button (audio playback not yet implemented)
                Button(action: { showPlayAlert = true }) {
                    Label("Play Chord", systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle(chordName)
        .navigationBarTitleDisplayMode(.inline)
        //alert shown when play button tapped
        .alert("Coming Soon", isPresented: $showPlayAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Audio playback will be available in a future update.")
        }
    }

    //returns set of piano key indices to highlight for this chord
    //indices correspond to pitch classes (0=c, 1=c#, etc.)
    func getHighlightedNotes() -> Set<Int> {
        switch chordName {
        case "C": return [0, 4, 7]      //c major: c-e-g
        case "Am": return [9, 0, 4]     //a minor: a-c-e
        case "F": return [5, 9, 0]      //f major: f-a-c
        case "G": return [7, 11, 2]     //g major: g-b-d
        default: return [0, 4, 7]       //default to c major shape
        }
    }

    //returns descriptive text explaining the chord's musical character
    func getChordDescription() -> String {
        switch chordType {
        case "Major":
            return "A major chord creates a bright, happy sound. It's built from the root, major third, and perfect fifth of a scale."
        case "Minor":
            return "A minor chord has a sad or melancholic quality. It uses a minor third instead of a major third."
        case "7th":
            return "A dominant 7th chord adds tension and movement. It's commonly used in blues and jazz progressions."
        default:
            return "This chord type has unique harmonic characteristics that define its sound."
        }
    }

    //placeholder for future audio playback functionality
    func playChord() {
        print("Playing \(chordName)")
    }
}

// MARK: - Simple Piano View

//basic piano keyboard visualisation for legacy chord detail view
//displays one octave with highlighted keys for chord notes
struct PianoView: View {
    //set of key indices to highlight (white keys 0-6, black keys 7-11)
    let highlightedNotes: Set<Int>

    //number of white keys to display (one octave)
    let whiteKeys = 7

    //x positions for black keys as fractions of white key width
    let blackKeyPositions = [0.5, 1.5, 3.5, 4.5, 5.5]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                //white keys layer (drawn first, behind black keys)
                HStack(spacing: 2) {
                    ForEach(0..<whiteKeys, id: \.self) { key in
                        Rectangle()
                            //highlight if key is part of the chord
                            .fill(highlightedNotes.contains(key) ? Color.blue : Color.white)
                            .border(Color.gray)
                    }
                }

                //black keys layer (drawn on top)
                ForEach(Array(blackKeyPositions.enumerated()), id: \.offset) { index, position in
                    Rectangle()
                        //black keys indexed starting at 7
                        .fill(highlightedNotes.contains(index + 7) ? Color.blue.opacity(0.8) : Color.black)
                        //black keys are narrower and shorter than white keys
                        .frame(width: geometry.size.width / 10, height: geometry.size.height * 0.6)
                        .offset(x: (geometry.size.width / 7) * position)
                }
            }
        }
    }
}

// MARK: - Enhanced Chord Detail View

//comprehensive chord view with interactive root selection and detailed information
//uses the chorddefinition model for rich data display
struct EnhancedChordDetailView: View {
    //chord definition containing all data to display
    let chord: ChordDefinition

    //currently selected root note for transposition
    @State private var selectedRoot: String = "C"

    //controls visibility of coming soon alert for play button
    @State private var showPlayAlert = false

    //all twelve chromatic root notes with enharmonic equivalents
    let rootNotes = ["C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                //header section with chord symbol and root selector
                VStack(spacing: 12) {
                    //chord symbol in large prominent text (updates with root selection)
                    Text(getChordSymbolForRoot())
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    //chord quality name below symbol
                    Text(chord.name)
                        .font(.title2)
                        .foregroundColor(.secondary)

                    //root note picker allowing transposition to any key
                    VStack {
                        Text("Root Note")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        //segmented control for root selection
                        Picker("Root Note", selection: $selectedRoot) {
                            ForEach(rootNotes, id: \.self) { root in
                                Text(root).tag(root)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .scaleEffect(0.8)
                    }
                }
                .padding()

                //piano keyboard visualisation showing chord voicing
                EnhancedPianoView(highlightedKeys: getHighlightedKeysForRoot())
                    .frame(height: 120)
                    .padding(.horizontal)

                //information cards displaying chord properties
                VStack(spacing: 16) {
                    //interval formula card (e.g., "1-3-5" for major triad)
                    InfoCard(title: "Interval Formula", content: chord.formula, icon: "number", color: .blue)

                    //actual note names in the currently selected key
                    InfoCard(title: "Notes (in \(selectedRoot))", content: getNotesForRoot(), icon: "music.note", color: .green)

                    //alternative chord symbol notations
                    InfoCard(title: "Alternative Symbols", content: getAlternativeSymbols(), icon: "textformat.alt", color: .orange)
                }
                .padding(.horizontal)

                //description card explaining chord character and usage
                VStack(alignment: .leading, spacing: 12) {
                    //card header with icon
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.purple)
                            .font(.title2)
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.purple)
                        Spacer()
                    }

                    //detailed description text
                    Text(chord.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                //play button (audio playback not yet implemented)
                Button(action: { showPlayAlert = true }) {
                    Label("Play \(getChordSymbolForRoot())", systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(chord.name)
        .navigationBarTitleDisplayMode(.inline)
        //alert shown when play button tapped
        .alert("Coming Soon", isPresented: $showPlayAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Audio playback will be available in a future update.")
        }
    }

    //generates chord symbol for the currently selected root note
    //takes the chord's suffix and appends it to the new root
    private func getChordSymbolForRoot() -> String {
        //map picker values to display note names
        let rootMap: [String: String] = [
            "C": "C", "C#/Db": "C#", "D": "D", "D#/Eb": "Eb", "E": "E", "F": "F",
            "F#/Gb": "F#", "G": "G", "G#/Ab": "Ab", "A": "A", "A#/Bb": "Bb", "B": "B"
        ]

        let root = rootMap[selectedRoot] ?? "C"
        //extract chord quality suffix by removing the original root (c)
        let suffix = chord.primarySymbol.dropFirst()
        return root + suffix
    }

    //returns note names for the chord in the selected key
    private func getNotesForRoot() -> String {
        //map picker values to semitone values
        let rootMap: [String: Int] = [
            "C": 0, "C#/Db": 1, "D": 2, "D#/Eb": 3, "E": 4, "F": 5,
            "F#/Gb": 6, "G": 7, "G#/Ab": 8, "A": 9, "A#/Bb": 10, "B": 11
        ]

        //chromatic note names for output
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let rootNote = rootMap[selectedRoot] ?? 0

        //transpose each chord tone to the selected key
        let chordNotes = chord.pianoKeys.map { offset in
            let noteIndex = (rootNote + offset) % 12
            return noteNames[noteIndex]
        }

        //join with en-dash for proper musical notation
        return chordNotes.joined(separator: "–")
    }

    //generates alternative symbol notations for the current root
    private func getAlternativeSymbols() -> String {
        let rootMap: [String: String] = [
            "C": "C", "C#/Db": "C#", "D": "D", "D#/Eb": "Eb", "E": "E", "F": "F",
            "F#/Gb": "F#", "G": "G", "G#/Ab": "Ab", "A": "A", "A#/Bb": "Bb", "B": "B"
        ]

        let root = rootMap[selectedRoot] ?? "C"
        //apply new root to each alternative symbol, skipping the primary
        let alternativeSymbols = chord.symbols.dropFirst().map { symbol in
            root + String(symbol.dropFirst())
        }

        return alternativeSymbols.joined(separator: ", ")
    }

    //calculates which piano keys to highlight for the selected root
    private func getHighlightedKeysForRoot() -> Set<Int> {
        let rootMap: [String: Int] = [
            "C": 0, "C#/Db": 1, "D": 2, "D#/Eb": 3, "E": 4, "F": 5,
            "F#/Gb": 6, "G": 7, "G#/Ab": 8, "A": 9, "A#/Bb": 10, "B": 11
        ]

        let rootNote = rootMap[selectedRoot] ?? 0

        //transpose each chord interval to the selected key
        let highlightedKeys = chord.pianoKeys.map { offset in
            (rootNote + offset) % 12
        }

        return Set(highlightedKeys)
    }

    //placeholder for future audio playback functionality
    private func playChord() {
        print("Playing \(getChordSymbolForRoot())")
    }
}

// MARK: - Info Card

//reusable card component for displaying chord properties
//used for formula, notes, and alternative symbols sections
struct InfoCard: View {
    //card title displayed in header
    let title: String

    //main content text to display
    let content: String

    //sf symbol name for header icon
    let icon: String

    //theme colour for header and background tint
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            //card header with icon and title
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
            }

            //content text below header
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Enhanced Piano View

//improved piano keyboard with proper semitone mapping and note labels
//displays one octave with pitch class-based highlighting
struct EnhancedPianoView: View {
    //set of pitch class values (0-11) to highlight
    let highlightedKeys: Set<Int>

    //pitch class values for white keys (c=0, d=2, e=4, f=5, g=7, a=9, b=11)
    private let whiteKeyNotes: [Int] = [0, 2, 4, 5, 7, 9, 11]

    //pitch class values for black keys (c#=1, d#=3, f#=6, g#=8, a#=10)
    private let blackKeyNotes: [Int] = [1, 3, 6, 8, 10]

    //x positions for black keys relative to white key width
    //positioned between the appropriate white key pairs
    //piano layout: c c# d d# e | f f# g g# a a# b
    private let blackKeyPositions: [CGFloat] = [
        0.85,  //c# between c(0) and d(1)
        1.85,  //d# between d(1) and e(2)
        3.85,  //f# between f(3) and g(4)
        4.85,  //g# between g(4) and a(5)
        5.85   //a# between a(5) and b(6)
    ]

    var body: some View {
        GeometryReader { geometry in
            //calculate key dimensions based on available width
            let whiteKeyWidth = geometry.size.width / 7
            let blackKeyWidth = whiteKeyWidth * 0.6
            let blackKeyHeight = geometry.size.height * 0.65

            ZStack(alignment: .topLeading) {
                //white keys layer (drawn first, behind black keys)
                HStack(spacing: 1) {
                    ForEach(0..<7, id: \.self) { keyIndex in
                        let noteValue = whiteKeyNotes[keyIndex]
                        Rectangle()
                            //highlight if note is in the chord
                            .fill(highlightedKeys.contains(noteValue) ? Color.blue.opacity(0.7) : Color.white)
                            .border(Color.gray, width: 1)
                            .overlay(
                                //note name label at bottom of key
                                VStack {
                                    Spacer()
                                    Text(getNoteNameForSemitone(noteValue))
                                        .font(.caption2)
                                        .foregroundColor(highlightedKeys.contains(noteValue) ? .white : .gray)
                                        .padding(.bottom, 4)
                                }
                            )
                    }
                }

                //black keys layer (drawn on top of white keys)
                ForEach(Array(blackKeyNotes.enumerated()), id: \.offset) { index, noteValue in
                    let position = blackKeyPositions[index]
                    let xOffset = whiteKeyWidth * position

                    Rectangle()
                        //highlight if note is in the chord
                        .fill(highlightedKeys.contains(noteValue) ? Color.blue : Color.black)
                        .frame(width: blackKeyWidth, height: blackKeyHeight)
                        .cornerRadius(4)
                        .overlay(
                            //note name label on black key
                            VStack {
                                Spacer()
                                Text(getNoteNameForSemitone(noteValue))
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 4)
                            }
                        )
                        .position(x: xOffset, y: blackKeyHeight / 2)
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    //converts semitone value (0-11) to note name string
    private func getNoteNameForSemitone(_ semitone: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return noteNames[semitone % 12]
    }
}
