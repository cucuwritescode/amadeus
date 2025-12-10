import SwiftUI

struct ChordCategoryView: View {
    let category: String
    private let chordDictionary = ChordDictionary.shared
    
    var chords: [ChordDefinition] {
        return chordDictionary.chordsByCategory[category] ?? []
    }
    
    var body: some View {
        List {
            ForEach(chords) { chord in
                NavigationLink(destination: EnhancedChordDetailView(chord: chord)) {
                    HStack {
                        // Chord symbol
                        Text(chord.primarySymbol)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 60, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chord.name)
                                .font(.headline)
                            
                            Text("Formula: \(chord.formula)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(chord.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
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

struct ProgressionDetailView: View {
    let name: String
    let chords: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Progression Name
                Text(name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Chord Sequence
                VStack(alignment: .leading) {
                    Text("Chord Sequence")
                        .font(.headline)
                    
                    HStack {
                        ForEach(Array(chords.enumerated()), id: \.offset) { index, chord in
                            VStack {
                                Text(chord)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if index < chords.count - 1 {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(getProgressionDescription())
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Common Usage
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common in")
                        .font(.headline)
                    Text(getGenres())
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Play Button
                Button(action: playProgression) {
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
    }
    
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
    
    func getGenres() -> String {
        switch name {
        case "ii–V–I": return "Jazz, Bebop, Swing"
        case "I–V–vi–IV": return "Pop, Rock, Country"
        case "I–vi–IV–V": return "Doo-wop, Classic Rock, Oldies"
        default: return "Various genres"
        }
    }
    
    func playProgression() {
        print("Playing progression: \(chords.joined(separator: " - "))")
    }
}

// Enhanced Progression Detail View using the new ChordProgression model
struct EnhancedProgressionDetailView: View {
    let progression: ChordProgression
    @State private var selectedKey: String = "C"
    @State private var isMinorMode: Bool = false
    
    let keys = ["C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(progression.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
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
                
                // Mode and Key Selector
                VStack(spacing: 16) {
                    // Mode selector
                    Picker("Mode", selection: $isMinorMode) {
                        Text("Major").tag(false)
                        Text("Minor").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Key selector  
                    VStack {
                        Text("Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
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
                
                // Roman Numerals Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "number.circle")
                            .foregroundColor(.purple)
                            .font(.title2)
                        Text("Roman Numeral Analysis")
                            .font(.headline)
                            .foregroundColor(.purple)
                        Spacer()
                    }
                    
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
                
                // Current Progression Display
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("Progression in \(selectedKey) \(isMinorMode ? "minor" : "major")")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    // Chord progression display
                    VStack(spacing: 16) {
                        ForEach(getCurrentProgression()) { chord in
                            VStack(spacing: 12) {
                                // Chord name and Roman numeral
                                HStack {
                                    Text(chord.chord)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                    
                                    Text("MIDI: \(chord.notes.map(String.init).joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Mini piano visualization for this chord
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
                
                // Description
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
                
                // Tempo Information
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
                
                // Song Examples
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
                
                // Play Button
                Button(action: playProgression) {
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
    }
    
    private func getCurrentProgression() -> [ProgressionChord] {
        return isMinorMode ? progression.minorProgression : progression.majorProgression
    }
    
    private func getRelativeNotes(from midiNotes: [Int]) -> [Int] {
        // Convert MIDI notes to relative semitone positions (0-11)
        return midiNotes.map { $0 % 12 }
    }
    
    private func playProgression() {
        let currentChords = getCurrentProgression()
        let chordNames = currentChords.map { $0.chord }.joined(separator: " - ")
        print("Playing \(progression.name) in \(selectedKey) \(isMinorMode ? "minor" : "major"): \(chordNames)")
    }
}

// Compact Piano View for progression display
struct CompactPianoView: View {
    let highlightedNotes: Set<Int>
    
    private let whiteKeys = [0, 2, 4, 5, 7, 9, 11] // C, D, E, F, G, A, B
    private let blackKeys = [1, 3, 6, 8, 10] // C#, D#, F#, G#, A#
    private let blackKeyPositions: [CGFloat] = [0.85, 1.85, 3.85, 4.85, 5.85]
    
    var body: some View {
        GeometryReader { geometry in
            let whiteKeyWidth = geometry.size.width / 7
            let blackKeyWidth = whiteKeyWidth * 0.6
            let blackKeyHeight = geometry.size.height * 0.65
            
            ZStack(alignment: .topLeading) {
                // White keys
                HStack(spacing: 1) {
                    ForEach(0..<7, id: \.self) { keyIndex in
                        let noteValue = whiteKeys[keyIndex]
                        Rectangle()
                            .fill(highlightedNotes.contains(noteValue) ? Color.blue.opacity(0.8) : Color.white)
                            .border(Color.gray, width: 0.5)
                            .overlay(
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
                
                // Black keys
                ForEach(Array(blackKeys.enumerated()), id: \.offset) { index, noteValue in
                    let position = blackKeyPositions[index]
                    let xOffset = whiteKeyWidth * position
                    
                    Rectangle()
                        .fill(highlightedNotes.contains(noteValue) ? Color.blue : Color.black)
                        .frame(width: blackKeyWidth, height: blackKeyHeight)
                        .cornerRadius(3)
                        .overlay(
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

#Preview {
    NavigationView {
        ChordCategoryView(category: "Major")
    }
}