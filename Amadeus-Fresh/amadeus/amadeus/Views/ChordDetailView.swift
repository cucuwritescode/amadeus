import SwiftUI

struct ChordDetailView: View {
    let chordName: String
    let chordType: String
    
    // Example chord data - would be populated from a database
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