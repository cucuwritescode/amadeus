import SwiftUI

struct ChordCategoryView: View {
    let category: String
    
    var chords: [(String, String)] {
        switch category {
        case "Major":
            return [
                ("C", "C Major"), ("D", "D Major"), ("E", "E Major"), ("F", "F Major"),
                ("G", "G Major"), ("A", "A Major"), ("B", "B Major"),
                ("Db", "Db Major"), ("Eb", "Eb Major"), ("F#", "F# Major"),
                ("Ab", "Ab Major"), ("Bb", "Bb Major")
            ]
        case "Minor":
            return [
                ("Cm", "C Minor"), ("Dm", "D Minor"), ("Em", "E Minor"), ("Fm", "F Minor"),
                ("Gm", "G Minor"), ("Am", "A Minor"), ("Bm", "B Minor"),
                ("C#m", "C# Minor"), ("Ebm", "Eb Minor"), ("F#m", "F# Minor"),
                ("Abm", "Ab Minor"), ("Bbm", "Bb Minor")
            ]
        case "7th":
            return [
                ("C7", "C Dominant 7th"), ("Dm7", "D Minor 7th"), ("Em7", "E Minor 7th"),
                ("Fmaj7", "F Major 7th"), ("G7", "G Dominant 7th"), ("Am7", "A Minor 7th"),
                ("Bm7b5", "B Half Diminished")
            ]
        case "Diminished":
            return [
                ("Cdim", "C Diminished"), ("Ddim", "D Diminished"), ("Edim", "E Diminished"),
                ("Fdim", "F Diminished"), ("Gdim", "G Diminished"), ("Adim", "A Diminished"),
                ("Bdim", "B Diminished")
            ]
        case "Augmented":
            return [
                ("Caug", "C Augmented"), ("Daug", "D Augmented"), ("Eaug", "E Augmented"),
                ("Faug", "F Augmented"), ("Gaug", "G Augmented"), ("Aaug", "A Augmented"),
                ("Baug", "B Augmented")
            ]
        case "Suspended":
            return [
                ("Csus2", "C Suspended 2nd"), ("Csus4", "C Suspended 4th"),
                ("Dsus2", "D Suspended 2nd"), ("Dsus4", "D Suspended 4th"),
                ("Esus2", "E Suspended 2nd"), ("Esus4", "E Suspended 4th"),
                ("Fsus2", "F Suspended 2nd"), ("Fsus4", "F Suspended 4th")
            ]
        default:
            return [("C", "C Major"), ("Dm", "D Minor"), ("G7", "G Dominant 7th")]
        }
    }
    
    var body: some View {
        List {
            ForEach(chords, id: \.0) { chord, fullName in
                NavigationLink(destination: ChordDetailView(chordName: chord, chordType: category)) {
                    HStack {
                        // Chord symbol
                        Text(chord)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 60, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text(fullName)
                                .font(.headline)
                            Text(getChordDescription(chord))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("\(category) Chords")
    }
    
    func getChordDescription(_ chord: String) -> String {
        switch category {
        case "Major": return "Bright, happy sound"
        case "Minor": return "Sad, melancholic feel"
        case "7th": return "Jazzy, sophisticated"
        case "Diminished": return "Tense, unstable"
        case "Augmented": return "Mysterious, unsettled"
        case "Suspended": return "Floating, unresolved"
        default: return "Harmonic chord"
        }
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

#Preview {
    NavigationView {
        ChordCategoryView(category: "Major")
    }
}