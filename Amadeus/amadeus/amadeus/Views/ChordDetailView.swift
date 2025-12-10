import SwiftUI

struct ChordDetailView: View {
    let chordName: String
    let chordType: String
    
    // Legacy view - keeping for backward compatibility
    var intervals: [String] {
        switch chordType {
        case "Major": return ["Root", "Major 3rd", "Perfect 5th"]
        case "Minor": return ["Root", "Minor 3rd", "Perfect 5th"]
        case "7th": return ["Root", "Major 3rd", "Perfect 5th", "Minor 7th"]
        case "maj7": return ["Root", "Major 3rd", "Perfect 5th", "Major 7th"]
        default: return ["Root", "3rd", "5th"]
        }
    }
    
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
                // Chord Name Header
                VStack {
                    Text(chordName)
                        .font(.system(size: 48, weight: .bold))
                    Text(chordType)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Piano Diagram
                PianoView(highlightedNotes: getHighlightedNotes())
                    .frame(height: 150)
                    .padding()
                
                // Intervals
                VStack(alignment: .leading, spacing: 12) {
                    Text("Intervals")
                        .font(.headline)
                    
                    ForEach(Array(intervals.enumerated()), id: \.offset) { index, interval in
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(index + 1)")
                                        .fontWeight(.bold)
                                )
                            
                            Text(interval)
                                .font(.body)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Formula
                VStack(alignment: .leading, spacing: 8) {
                    Text("Formula")
                        .font(.headline)
                    Text(formula)
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(getChordDescription())
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Play Button
                Button(action: playChord) {
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
    }
    
    func getHighlightedNotes() -> Set<Int> {
        // Return piano key indices to highlight
        // These will be corrected with proper music theory later
        switch chordName {
        case "C": return [0, 4, 7]
        case "Am": return [9, 0, 4]
        case "F": return [5, 9, 0]
        case "G": return [7, 11, 2]
        default: return [0, 4, 7]
        }
    }
    
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
    
    func playChord() {
        // Placeholder for chord playback
        print("Playing \(chordName)")
    }
}

// Simple Piano View (to be corrected with proper music theory)
struct PianoView: View {
    let highlightedNotes: Set<Int>
    let whiteKeys = 7
    let blackKeyPositions = [0.5, 1.5, 3.5, 4.5, 5.5]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // White keys
                HStack(spacing: 2) {
                    ForEach(0..<whiteKeys, id: \.self) { key in
                        Rectangle()
                            .fill(highlightedNotes.contains(key) ? Color.blue : Color.white)
                            .border(Color.gray)
                    }
                }
                
                // Black keys
                ForEach(Array(blackKeyPositions.enumerated()), id: \.offset) { index, position in
                    Rectangle()
                        .fill(highlightedNotes.contains(index + 7) ? Color.blue.opacity(0.8) : Color.black)
                        .frame(width: geometry.size.width / 10, height: geometry.size.height * 0.6)
                        .offset(x: (geometry.size.width / 7) * position)
                }
            }
        }
    }
}

// Enhanced Chord Detail View using the new ChordDefinition
struct EnhancedChordDetailView: View {
    let chord: ChordDefinition
    @State private var selectedRoot: String = "C"
    
    let rootNotes = ["C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Chord Header
                VStack(spacing: 12) {
                    // Main chord symbol for selected root
                    Text(getChordSymbolForRoot())
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(chord.name)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    // Root note selector
                    VStack {
                        Text("Root Note")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
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
                
                // Piano Diagram
                EnhancedPianoView(highlightedKeys: getHighlightedKeysForRoot())
                    .frame(height: 120)
                    .padding(.horizontal)
                
                // Chord Information Cards
                VStack(spacing: 16) {
                    // Formula Card
                    InfoCard(title: "Interval Formula", content: chord.formula, icon: "number", color: .blue)
                    
                    // Example Notes Card
                    InfoCard(title: "Notes (in \(selectedRoot))", content: getNotesForRoot(), icon: "music.note", color: .green)
                    
                    // Alternative Symbols Card
                    InfoCard(title: "Alternative Symbols", content: getAlternativeSymbols(), icon: "textformat.alt", color: .orange)
                }
                .padding(.horizontal)
                
                // Description Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.purple)
                            .font(.title2)
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.purple)
                        Spacer()
                    }
                    
                    Text(chord.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Play Button
                Button(action: playChord) {
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
    }
    
    private func getChordSymbolForRoot() -> String {
        let rootMap: [String: String] = [
            "C": "C", "C#/Db": "C#", "D": "D", "D#/Eb": "Eb", "E": "E", "F": "F",
            "F#/Gb": "F#", "G": "G", "G#/Ab": "Ab", "A": "A", "A#/Bb": "Bb", "B": "B"
        ]
        
        let root = rootMap[selectedRoot] ?? "C"
        let suffix = chord.primarySymbol.dropFirst() // Remove the 'C' from the beginning
        return root + suffix
    }
    
    private func getNotesForRoot() -> String {
        let rootMap: [String: Int] = [
            "C": 0, "C#/Db": 1, "D": 2, "D#/Eb": 3, "E": 4, "F": 5,
            "F#/Gb": 6, "G": 7, "G#/Ab": 8, "A": 9, "A#/Bb": 10, "B": 11
        ]
        
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let rootNote = rootMap[selectedRoot] ?? 0
        
        let chordNotes = chord.pianoKeys.map { offset in
            let noteIndex = (rootNote + offset) % 12
            return noteNames[noteIndex]
        }
        
        return chordNotes.joined(separator: "–")
    }
    
    private func getAlternativeSymbols() -> String {
        let rootMap: [String: String] = [
            "C": "C", "C#/Db": "C#", "D": "D", "D#/Eb": "Eb", "E": "E", "F": "F",
            "F#/Gb": "F#", "G": "G", "G#/Ab": "Ab", "A": "A", "A#/Bb": "Bb", "B": "B"
        ]
        
        let root = rootMap[selectedRoot] ?? "C"
        let alternativeSymbols = chord.symbols.dropFirst().map { symbol in
            root + String(symbol.dropFirst())
        }
        
        return alternativeSymbols.joined(separator: ", ")
    }
    
    private func getHighlightedKeysForRoot() -> Set<Int> {
        let rootMap: [String: Int] = [
            "C": 0, "C#/Db": 1, "D": 2, "D#/Eb": 3, "E": 4, "F": 5,
            "F#/Gb": 6, "G": 7, "G#/Ab": 8, "A": 9, "A#/Bb": 10, "B": 11
        ]
        
        let rootNote = rootMap[selectedRoot] ?? 0
        
        let highlightedKeys = chord.pianoKeys.map { offset in
            (rootNote + offset) % 12
        }
        
        return Set(highlightedKeys)
    }
    
    private func playChord() {
        print("Playing \(getChordSymbolForRoot())")
    }
}

struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
            }
            
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

// Enhanced Piano View with proper semitone offset visualization
struct EnhancedPianoView: View {
    let highlightedKeys: Set<Int>
    
    private let whiteKeyNotes: [Int] = [0, 2, 4, 5, 7, 9, 11] // C, D, E, F, G, A, B
    private let blackKeyNotes: [Int] = [1, 3, 6, 8, 10] // C#, D#, F#, G#, A#
    
    // Correct black key positions - positioned BETWEEN white keys
    // Piano layout: C C# D D# E | F F# G G# A A# B
    // White keys:   0        1  2   3     4     5     6
    // Black keys need to be between the correct white key pairs
    private let blackKeyPositions: [CGFloat] = [
        0.85,  // C# - between C(0) and D(1) 
        1.85,  // D# - between D(1) and E(2)
        3.85,  // F# - between F(3) and G(4)  
        4.85,  // G# - between G(4) and A(5)
        5.85   // A# - between A(5) and B(6)
    ]
    
    var body: some View {
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
                            .fill(highlightedKeys.contains(noteValue) ? Color.blue.opacity(0.7) : Color.white)
                            .border(Color.gray, width: 1)
                            .overlay(
                                // Add note labels at the bottom
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
                
                // Black keys - positioned BETWEEN white keys
                ForEach(Array(blackKeyNotes.enumerated()), id: \.offset) { index, noteValue in
                    let position = blackKeyPositions[index]
                    // Position is the exact point between two white keys
                    let xOffset = whiteKeyWidth * position
                    
                    Rectangle()
                        .fill(highlightedKeys.contains(noteValue) ? Color.blue : Color.black)
                        .frame(width: blackKeyWidth, height: blackKeyHeight)
                        .cornerRadius(4)
                        .overlay(
                            // Add note labels
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
    
    private func getNoteNameForSemitone(_ semitone: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return noteNames[semitone % 12]
    }
}