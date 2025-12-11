//
//  ChordDictionary.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  comprehensive chord dictionary with voicings and music theory
//  provides chord structures, intervals, and categorisation
//
//  acknowledgements:
//  - inspired by tonic library chord representations
// 
//

import Foundation
//created by Facundo Franchino
//represents a chord with its symbols and theory information
struct ChordDefinition: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbols: [String]
    let formula: String
    let pitchClassesC: String
    let pianoKeys: [Int]
    let description: String
    
    var primarySymbol: String {
        return symbols.first ?? name
    }
}

// comprehensive chord dictionary with musical theory information
class ChordDictionary {
    static let shared = ChordDictionary()
    
    let chords: [ChordDefinition] = [
        //triads
        ChordDefinition(
            name: "Major Triad",
            symbols: ["C", "CM", "Cmaj"],
            formula: "1–3–5",
            pitchClassesC: "C–E–G",
            pianoKeys: [0, 4, 7],
            description: "A major triad has a bright, stable and consonant sound (the basic \"happy\" chord)."
        ),
        ChordDefinition(
            name: "Minor Triad",
            symbols: ["Cm", "Cmin", "C–"],
            formula: "1–♭3–5",
            pitchClassesC: "C–E♭–G",
            pianoKeys: [0, 3, 7],
            description: "A minor triad has a darker, sadder sound than major due to the lowered third."
        ),
        ChordDefinition(
            name: "Diminished Triad",
            symbols: ["Cdim", "C°"],
            formula: "1–♭3–♭5",
            pitchClassesC: "C–E♭–G♭",
            pianoKeys: [0, 3, 6],
            description: "A tense, unstable chord of two minor thirds; often functions as a leading-tone chord resolving to a stable chord."
        ),
        ChordDefinition(
            name: "Augmented Triad",
            symbols: ["Caug", "C+"],
            formula: "1–3–♯5",
            pitchClassesC: "C–E–G♯",
            pianoKeys: [0, 4, 8],
            description: "An augmented triad has a raised 5th, giving it a dissonant, unsettled sound that seeks resolution."
        ),
        
        //sus chords
        ChordDefinition(
            name: "Suspended 2nd Chord",
            symbols: ["Csus2"],
            formula: "1–2–5",
            pitchClassesC: "C–D–G",
            pianoKeys: [0, 2, 7],
            description: "A sus2 chord replaces the third with a second, creating an open, hovering sound (neither major nor minor)."
        ),
        ChordDefinition(
            name: "Suspended 4th Chord",
            symbols: ["Csus4"],
            formula: "1–4–5",
            pitchClassesC: "C–F–G",
            pianoKeys: [0, 5, 7],
            description: "A sus4 chord replaces the third with a fourth, giving a sense of tension that usually resolves down to a major chord."
        ),
        
        // 6th Chords
        ChordDefinition(
            name: "Major 6th Chord",
            symbols: ["C6"],
            formula: "1–3–5–6",
            pitchClassesC: "C–E–G–A",
            pianoKeys: [0, 4, 7, 9],
            description: "A major triad with an added 6th. It has a lush, sonorous quality and often substitutes for a tonic chord in jazz and pop."
        ),
        ChordDefinition(
            name: "Minor 6th Chord",
            symbols: ["Cm6"],
            formula: "1–♭3–5–6",
            pitchClassesC: "C–E♭–G–A",
            pianoKeys: [0, 3, 7, 9],
            description: "A minor triad with a major 6th added. Common in jazz and classical (the iv⁶ chord in minor), it has a somewhat bittersweet sound."
        ),
        
        // 7th chords
        ChordDefinition(
            name: "Dominant 7th Chord",
            symbols: ["C7", "Cdom7"],
            formula: "1–3–5–♭7",
            pitchClassesC: "C–E–G–B♭",
            pianoKeys: [0, 4, 7, 10],
            description: "A major triad plus a minor 7th. The dominant 7th has a strong tension that resolves to the tonic (e.g., C7 resolves to F)."
        ),
        ChordDefinition(
            name: "Major 7th Chord",
            symbols: ["Cmaj7", "CΔ7"],
            formula: "1–3–5–7",
            pitchClassesC: "C–E–G–B",
            pianoKeys: [0, 4, 7, 11],
            description: "A major triad plus a major 7th. It has a rich, dreamy sound (common in jazz and R&B) without the need to resolve like a dominant 7th."
        ),
        ChordDefinition(
            name: "Minor 7th Chord",
            symbols: ["Cm7", "Cmin7", "C–7"],
            formula: "1–♭3–5–♭7",
            pitchClassesC: "C–E♭–G–B♭",
            pianoKeys: [0, 3, 7, 10],
            description: "A minor triad with a minor 7th added. This chord has a mellow, soulful quality; it's the ii chord in major keys and i chord in minor keys."
        ),
        ChordDefinition(
            name: "Half-Diminished 7th Chord",
            symbols: ["Cm7♭5", "Cø7"],
            formula: "1–♭3–♭5–♭7",
            pitchClassesC: "C–E♭–G♭–B♭",
            pianoKeys: [0, 3, 6, 10],
            description: "Also called a minor 7 flat 5, this chord has a diminished fifth and minor 7th. It occurs naturally as vii°7 in major (or iiø7 in minor) and has a subdued, unstable sound."
        ),
        ChordDefinition(
            name: "Diminished 7th Chord",
            symbols: ["Cdim7", "C°7"],
            formula: "1–♭3–♭5–♭♭7",
            pitchClassesC: "C–E♭–G♭–B♭♭",
            pianoKeys: [0, 3, 6, 9],
            description: "A four-note chord of stacked minor thirds (e.g., C–E♭–G♭–B♭♭). The double-flatted 7th (B♭♭ = A) gives a dim7 its distinctive tense, \"unstable\" character. It often resolves to a chord one half-step above the root."
        ),
        ChordDefinition(
            name: "Minor-Major 7th Chord",
            symbols: ["Cm(maj7)", "CminΔ7"],
            formula: "1–♭3–5–7",
            pitchClassesC: "C–E♭–G–B",
            pianoKeys: [0, 3, 7, 11],
            description: "A minor triad with a major 7th. This uncommon chord produces a haunting, melancholic sound (notably used as iMaj7 in harmonic minor contexts)."
        ),
        
        //ext chords
        ChordDefinition(
            name: "Add 2 (Add 9) Chord",
            symbols: ["Cadd2", "Cadd9"],
            formula: "1–3–5–9",
            pitchClassesC: "C–E–G–D",
            pianoKeys: [0, 4, 7, 14],
            description: "A major triad with an added 2nd (9th) scale degree. It creates a spacious, modern sound (common in pop ballads) without the dissonance of a 7th."
        ),
        ChordDefinition(
            name: "Dominant 9th Chord",
            symbols: ["C9"],
            formula: "1–3–5–♭7–9",
            pitchClassesC: "C–E–G–B♭–D",
            pianoKeys: [0, 4, 7, 10, 14],
            description: "A C7 (dominant 7th) with an added 9th. This 5-note chord has rich tension (♭7 against 9) and is common in jazz and funk (often voiced with omitted 5th)."
        ),
        ChordDefinition(
            name: "Major 9th Chord",
            symbols: ["Cmaj9"],
            formula: "1–3–5–7–9",
            pitchClassesC: "C–E–G–B–D",
            pianoKeys: [0, 4, 7, 11, 14],
            description: "A Cmaj7 chord with an added 9th. It sounds lush and smooth, commonly used in jazz and R&B for color on a tonic or IV chord."
        ),
        ChordDefinition(
            name: "Minor 9th Chord",
            symbols: ["Cm9"],
            formula: "1–♭3–5–♭7–9",
            pitchClassesC: "C–E♭–G–B♭–D",
            pianoKeys: [0, 3, 7, 10, 14],
            description: "A Cm7 chord with an added 9th. This chord has a soulful, contemplative quality and is often used as the ii chord in jazz minor-key progressions."
        ),
        ChordDefinition(
            name: "Dominant 7♭9 Chord",
            symbols: ["C7♭9"],
            formula: "1–3–5–♭7–♭9",
            pitchClassesC: "C–E–G–B♭–D♭",
            pianoKeys: [0, 4, 7, 10, 13],
            description: "A C7 chord with a flattened 9th. The ♭9 adds strong dissonance (root–♭9 clash), giving a very tense sound that resolves typically to a minor chord (common in classical and flamenco)."
        ),
        ChordDefinition(
            name: "Dominant 7♯9 Chord",
            symbols: ["C7♯9"],
            formula: "1–3–5–♭7–♯9",
            pitchClassesC: "C–E–G–B♭–D♯",
            pianoKeys: [0, 4, 7, 10, 15],
            description: "A C7 with a sharpened 9th (often called the \"Hendrix chord\"). The ♯9 (enharmonic to a minor 3rd) played against a major 3rd creates a bluesy, complex dissonance used in rock and jazz."
        ),
        ChordDefinition(
            name: "Major 11th Chord",
            symbols: ["Cmaj11"],
            formula: "1–3–5–7–9–11",
            pitchClassesC: "C–E–G–B–D–F",
            pianoKeys: [0, 4, 7, 11, 14, 17],
            description: "A major 7th chord with added 9th and 11th (all notes of the major scale). This chord is very dissonant (the major 3rd (E) clashes with the 11th (F)), so it's usually played with omissions or as a sustained, ethereal pad."
        ),
        ChordDefinition(
            name: "Minor 11th Chord",
            symbols: ["Cm11"],
            formula: "1–♭3–5–♭7–9–11",
            pitchClassesC: "C–E♭–G–B♭–D–F",
            pianoKeys: [0, 3, 7, 10, 14, 17],
            description: "A Cm9 chord with added 11th (C–E♭–G–B♭–D–F). Less dissonant than the major 11th (since E♭ and F are a whole step apart), it creates a lush, modal minor sound (frequently used on the iv chord in jazz)."
        ),
        ChordDefinition(
            name: "13th Chord (Dominant 13th)",
            symbols: ["C13"],
            formula: "1–3–5–♭7–9–11–13",
            pitchClassesC: "C–E–G–B♭–D–F–A",
            pianoKeys: [0, 4, 7, 10, 14, 17, 21],
            description: "The fully extended dominant chord (C7 plus 9, 11, and 13). It contains every note of the C Mixolydian scale. In practice, 13th chords are often voiced with some omissions (common tones), but they have a full, soulful sound in gospel and jazz."
        ),
        ChordDefinition(
            name: "Major 13th Chord",
            symbols: ["Cmaj13"],
            formula: "1–3–5–7–9–11–13",
            pitchClassesC: "C–E–G–B–D–F–A",
            pianoKeys: [0, 4, 7, 11, 14, 17, 21],
            description: "A Cmaj7 with all extensions (9, 11, 13). It essentially combines the entire major scale in one chord, producing a very complex, colorful sound. (In practice, the 11th (F) is often sharpened or omitted to reduce dissonance with the 3rd.)"
        ),
        ChordDefinition(
            name: "Minor 13th Chord",
            symbols: ["Cm13"],
            formula: "1–♭3–5–♭7–9–11–13",
            pitchClassesC: "C–E♭–G–B♭–D–F–A",
            pianoKeys: [0, 3, 7, 10, 14, 17, 21],
            description: "A Cm11 chord with an added 13 (A). In jazz, minor 13th chords typically imply a natural 13 (major 6th) even in minor keys. The chord has a warm, expansive minor sound (often used as the ii chord in a major key or iv chord in minor)."
        )
    ]
    
    // organise chords by categories for the ui
    var chordsByCategory: [String: [ChordDefinition]] {
        var categorized: [String: [ChordDefinition]] = [:]
        
        for chord in chords {
            let category = getChordCategory(chord)
            if categorized[category] == nil {
                categorized[category] = []
            }
            categorized[category]?.append(chord)
        }
        
        return categorized
    }
    
    private func getChordCategory(_ chord: ChordDefinition) -> String {
        let name = chord.name.lowercased()
        
        if name.contains("major") && !name.contains("7") && !name.contains("6") && !name.contains("9") && !name.contains("11") && !name.contains("13") {
            return "Major"
        } else if name.contains("minor") && !name.contains("7") && !name.contains("6") && !name.contains("9") && !name.contains("11") && !name.contains("13") {
            return "Minor"
        } else if name.contains("diminished") {
            return "Diminished"
        } else if name.contains("augmented") {
            return "Augmented"
        } else if name.contains("suspended") {
            return "Suspended"
        } else if name.contains("6th") {
            return "6th Chords"
        } else if name.contains("7th") || name.contains("7") {
            return "7th Chords"
        } else if name.contains("9th") || name.contains("9") {
            return "9th Chords"
        } else if name.contains("11th") || name.contains("11") {
            return "11th Chords"
        } else if name.contains("13th") || name.contains("13") {
            return "13th Chords"
        } else if name.contains("add") {
            return "Add Chords"
        }
        
        return "Other"
    }
    
    // find chord by symbol notation
    func getChordBySymbol(_ symbol: String) -> ChordDefinition? {
        return chords.first { chord in
            chord.symbols.contains { $0.lowercased() == symbol.lowercased() }
        }
    }
    
    // search chords by name, symbol, formula or description
    func searchChords(_ query: String) -> [ChordDefinition] {
        if query.isEmpty {
            return chords
        }
        
        return chords.filter { chord in
            chord.name.localizedCaseInsensitiveContains(query) ||
            chord.symbols.contains { $0.localizedCaseInsensitiveContains(query) } ||
            chord.formula.localizedCaseInsensitiveContains(query) ||
            chord.description.localizedCaseInsensitiveContains(query)
        }
    }
}
