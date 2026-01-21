//
//  ChordCategoryView.swift
//  amadeus
//
//  created by facundo franchino on 18/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  displays chords grouped by category (triads, sevenths, extended, etc.)
//  provides navigation to detailed chord information views
//
//  acknowledgements:
//  - chord theory based on western harmony conventions
//  - roman numeral analysis follows standard music theory notation
//

import SwiftUI

// MARK: - Chord Category View

//lists all chords within a specific category from the chord dictionary
//serves as the drill-down view from the main library category grid
struct ChordCategoryView: View {
    //category name passed from parent navigation (e.g., "triads", "sevenths")
    let category: String

    //shared chord dictionary singleton for data access
    private let chordDictionary = ChordDictionary.shared

    //computed property filtering chords belonging to this category
    var chords: [ChordDefinition] {
        return chordDictionary.chordsByCategory[category] ?? []
    }

    var body: some View {
        List {
            //iterate through all chords in this category
            ForEach(chords) { chord in
                //each chord links to its detailed view
                NavigationLink(destination: EnhancedChordDetailView(chord: chord)) {
                    HStack {
                        //chord symbol displayed prominently (e.g., "Cmaj7")
                        Text(chord.primarySymbol)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 60, alignment: .leading)

                        //chord information stack
                        VStack(alignment: .leading, spacing: 4) {
                            //full chord name (e.g., "major seventh")
                            Text(chord.name)
                                .font(.headline)

                            //interval formula showing chord construction
                            Text("Formula: \(chord.formula)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            //brief description of chord character
                            Text(chord.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        //chevron indicating navigation available
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Progression Detail View (Legacy)

//displays details for a chord progression using simple string-based chords
//legacy view maintained for backward compatibility with older data format
struct ProgressionDetailView: View {
    //progression name in roman numeral format (e.g., "ii-V-I")
    let name: String

    //array of chord names in the progression
    let chords: [String]

    //controls visibility of coming soon alert for play button
    @State private var showPlayAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                //progression title as large header
                Text(name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                //chord sequence visualisation with arrows between chords
                VStack(alignment: .leading) {
                    Text("Chord Sequence")
                        .font(.headline)

                    //horizontal layout showing progression flow
                    HStack {
                        ForEach(Array(chords.enumerated()), id: \.offset) { index, chord in
                            VStack {
                                //chord name in styled box
                                Text(chord)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)

                                //position number below chord
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            //arrow between chords (not after last)
                            if index < chords.count - 1 {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                //description section explaining progression character
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(getProgressionDescription())
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                //genre/style associations section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common in")
                        .font(.headline)
                    Text(getGenres())
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                //play button (audio playback not yet implemented)
                Button(action: { showPlayAlert = true }) {
                    Label("Play Progression", systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        //alert shown when play button tapped
        .alert("Coming Soon", isPresented: $showPlayAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Audio playback will be available in a future update.")
        }
    }

    //returns descriptive text explaining the progression's musical function
    func getProgressionDescription() -> String {
        switch name {
        case "ii–V–I":
            return "The most important progression in jazz. Creates strong harmonic movement through the cycle of fifths, providing a sense of resolution to the tonic."
        case "I–V–vi–IV":
            return "The most popular progression in modern pop music. Creates a cycle that can repeat endlessly while maintaining harmonic interest."
        case "I–vi–IV–V":
            return "A classic progression from the 1950s and 60s. Known as the 'doo-wop' progression, it creates a smooth harmonic flow."
        default:
            return "A common chord progression used in many musical styles."
        }
    }

    //returns genres where this progression is commonly found
    func getGenres() -> String {
        switch name {
        case "ii–V–I": return "Jazz, Bebop, Swing"
        case "I–V–vi–IV": return "Pop, Rock, Country"
        case "I–vi–IV–V": return "Doo-wop, Classic Rock, Oldies"
        default: return "Various genres"
        }
    }

    //placeholder for future audio playback functionality
    func playProgression() {
        print("Playing progression: \(chords.joined(separator: " - "))")
    }
}

// MARK: - Enhanced Progression Detail View

//comprehensive progression view with interactive key/mode selection
//displays roman numerals, chord voicings, and piano visualisations
struct EnhancedProgressionDetailView: View {
    //progression definition containing all data to display
    let progression: ChordProgression

    //currently selected key for transposition, defaults to c
    @State private var selectedKey: String = "C"

    //toggle between major and minor mode interpretations
    @State private var isMinorMode: Bool = false

    //controls visibility of coming soon alert for play button
    @State private var showPlayAlert = false

    //all twelve chromatic keys with enharmonic equivalents
    let keys = ["C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                //header section with progression name and nickname
                VStack(alignment: .leading, spacing: 12) {
                    //main progression name (e.g., "vi-IV-I-V")
                    Text(progression.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    //colloquial name for the progression
                    HStack {
                        Text("Also known as:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(progression.nickname)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

                //interactive mode and key selection controls
                VStack(spacing: 16) {
                    //major/minor mode toggle
                    Picker("Mode", selection: $isMinorMode) {
                        Text("Major").tag(false)
                        Text("Minor").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    //key selection for transposition
                    VStack {
                        Text("Key")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        //segmented picker showing all 12 keys
                        Picker("Key", selection: $selectedKey) {
                            ForEach(keys, id: \.self) { key in
                                Text(key).tag(key)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .scaleEffect(0.85)
                    }
                }
                .padding(.horizontal)

                //roman numeral analysis card showing theoretical notation
                VStack(alignment: .leading, spacing: 12) {
                    //card header
                    HStack {
                        Image(systemName: "number.circle")
                            .foregroundColor(.purple)
                            .font(.title2)
                        Text("Roman Numeral Analysis")
                            .font(.headline)
                            .foregroundColor(.purple)
                        Spacer()
                    }

                    //major and minor key interpretations
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Major Key:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(progression.romanNumeralsMajor)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }

                        HStack {
                            Text("Minor Key:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(progression.romanNumeralsMinor)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                //chord-by-chord breakdown with piano visualisations
                VStack(alignment: .leading, spacing: 16) {
                    //section header showing current key/mode
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("Progression in \(selectedKey) \(isMinorMode ? "minor" : "major")")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                    }

                    //list of chords in the progression
                    VStack(spacing: 16) {
                        ForEach(getCurrentProgression()) { chord in
                            VStack(spacing: 12) {
                                //chord name and midi note info
                                HStack {
                                    Text(chord.chord)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)

                                    Spacer()

                                    //midi note numbers for reference
                                    Text("MIDI: \(chord.notes.map(String.init).joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                //mini piano showing chord voicing
                                CompactPianoView(highlightedNotes: Set(getRelativeNotes(from: chord.notes)))
                                    .frame(height: 60)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                //description card explaining progression character and usage
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.green)
                            .font(.title2)
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                    }

                    Text(progression.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                //tempo information card showing typical bpm range
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "metronome")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Typical Tempo")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Spacer()
                    }

                    Text(progression.tempoRange)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                //famous song examples using this progression
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "music.mic")
                            .foregroundColor(.pink)
                            .font(.title2)
                        Text("Famous Song Examples")
                            .font(.headline)
                            .foregroundColor(.pink)
                        Spacer()
                    }

                    //bulleted list of songs
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(progression.songExamples, id: \.self) { song in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.pink)
                                Text(song)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color.pink.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                //play button (audio playback not yet implemented)
                Button(action: { showPlayAlert = true }) {
                    Label("Play \(isMinorMode ? "Minor" : "Major") Progression", systemImage: "play.circle.fill")
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
        .navigationTitle(progression.name)
        .navigationBarTitleDisplayMode(.inline)
        //alert shown when play button tapped
        .alert("Coming Soon", isPresented: $showPlayAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Audio playback will be available in a future update.")
        }
    }

    //returns the appropriate chord array based on current mode selection
    private func getCurrentProgression() -> [ProgressionChord] {
        return isMinorMode ? progression.minorProgression : progression.majorProgression
    }

    //converts midi note numbers to pitch class values (0-11)
    //used for mapping notes to piano keyboard display
    private func getRelativeNotes(from midiNotes: [Int]) -> [Int] {
        return midiNotes.map { $0 % 12 }
    }

    //placeholder for future audio playback functionality
    private func playProgression() {
        let currentChords = getCurrentProgression()
        let chordNames = currentChords.map { $0.chord }.joined(separator: " - ")
        print("Playing \(progression.name) in \(selectedKey) \(isMinorMode ? "minor" : "major"): \(chordNames)")
    }
}

// MARK: - Compact Piano View

//small piano keyboard visualisation for displaying chord voicings
//used in progression detail views to show individual chord shapes
struct CompactPianoView: View {
    //set of pitch class values (0-11) to highlight on the keyboard
    let highlightedNotes: Set<Int>

    //pitch class values for white keys (c=0, d=2, e=4, f=5, g=7, a=9, b=11)
    private let whiteKeys = [0, 2, 4, 5, 7, 9, 11]

    //pitch class values for black keys (c#=1, d#=3, f#=6, g#=8, a#=10)
    private let blackKeys = [1, 3, 6, 8, 10]

    //x positions for black keys relative to white key width
    //positioned between the appropriate white key pairs
    private let blackKeyPositions: [CGFloat] = [0.85, 1.85, 3.85, 4.85, 5.85]

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
                        let noteValue = whiteKeys[keyIndex]
                        Rectangle()
                            //highlight if note is in the chord
                            .fill(highlightedNotes.contains(noteValue) ? Color.blue.opacity(0.8) : Color.white)
                            .border(Color.gray, width: 0.5)
                            .overlay(
                                //indicator dot for highlighted notes
                                VStack {
                                    Spacer()
                                    if highlightedNotes.contains(noteValue) {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 8, height: 8)
                                            .padding(.bottom, 4)
                                    }
                                }
                            )
                    }
                }

                //black keys layer (drawn on top of white keys)
                ForEach(Array(blackKeys.enumerated()), id: \.offset) { index, noteValue in
                    let position = blackKeyPositions[index]
                    let xOffset = whiteKeyWidth * position

                    Rectangle()
                        //highlight if note is in the chord
                        .fill(highlightedNotes.contains(noteValue) ? Color.blue : Color.black)
                        .frame(width: blackKeyWidth, height: blackKeyHeight)
                        .cornerRadius(3)
                        .overlay(
                            //indicator dot for highlighted notes (white on black key)
                            VStack {
                                Spacer()
                                if highlightedNotes.contains(noteValue) {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 6, height: 6)
                                        .padding(.bottom, 3)
                                }
                            }
                        )
                        .position(x: xOffset, y: blackKeyHeight / 2)
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ChordCategoryView(category: "Major")
    }
}