//
//  ScaleDictionary.swift
//  amadeus
//
//  created by facundo franchino on 10/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  comprehensive scale dictionary with intervals and modes
//  educational resource for scale theory and practice
//
//  acknowledgements:
//  - scale theory from my own musical education with Beatriz Feldman, Matias Couriel, etc.
//
//

import Foundation
//created by Facundo Franchino
//a dictionary of scales for the library page

//represents a musical scale
struct ScaleDefinition: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let formula: String // w-h pattern
    let degrees: String
    let cExample: String
    let semitoneOffsets: [Int] //relative semitones from root
    let usage: String
    let category: String
    
    var displayName: String {
        return name
    }
}

//a dictionary of musical scales and modes
class ScaleDictionary {
    static let shared = ScaleDictionary()
    
    let scales: [ScaleDefinition] = [
        // major and nat. minor
        ScaleDefinition(
            name: "Major Scale (Ionian Mode)",
            formula: "W–W–H–W–W–W–H",
            degrees: "1–2–3–4–5–6–7",
            cExample: "C–D–E–F–G–A–B",
            semitoneOffsets: [0, 2, 4, 5, 7, 9, 11],
            usage: "The major scale is the fundamental do-re-mi scale of Western music. It sounds happy, stable, and complete. Used everywhere: pop melodies, classical compositions, folk songs. It's the basis of major keys, and its modes. Virtually every musician learns this first, it's the source of basic harmony (I, IV, V chords) in Western music.",
            category: "Major/Minor"
        ),
        
        ScaleDefinition(
            name: "Natural Minor Scale (Aeolian Mode)",
            formula: "W–H–W–W–H–W–W",
            degrees: "1–2–♭3–4–5–♭6–♭7",
            cExample: "C–D–E♭–F–G–A♭–B♭",
            semitoneOffsets: [0, 2, 3, 5, 7, 8, 10],
            usage: "The natural minor (Aeolian) scale is the relative minor of the major scale (shares the same key signature). It sounds sad, dark, or serious compared to major. It's common in classical music, as well as in rock, metal, and folk. Natural minor is the basis for minor key harmony.",
            category: "Major/Minor"
        ),
        
        ScaleDefinition(
            name: "Harmonic Minor Scale",
            formula: "W–H–W–W–H–W+H–H",
            degrees: "1–2–♭3–4–5–♭6–7",
            cExample: "C–D–E♭–F–G–A♭–B",
            semitoneOffsets: [0, 2, 3, 5, 7, 8, 11],
            usage: "Harmonic minor is a natural minor scale with a raised 7th to create a leading tone. This scale has an exotic, somewhat Middle Eastern or Baroque sound due to the augmented 2nd leap between ♭6 and 7. It's used in classical minor key harmony to form the dominant V chord in minor. It evokes drama and tension. Many metal and neoclassical pieces use harmonic minor for its dramatic leading-tone tension.",
            category: "Major/Minor"
        ),
        
        ScaleDefinition(
            name: "Melodic Minor Scale",
            formula: "W–H–W–W–W–W–H (ascending)",
            degrees: "1–2–♭3–4–5–6–7",
            cExample: "C–D–E♭–F–G–A–B (ascending)",
            semitoneOffsets: [0, 2, 3, 5, 7, 9, 11],
            usage: "The melodic minor scale raises the 6th and 7th when ascending, avoiding the awkward leap of harmonic minor. In jazz, the ascending form (jazz minor) is used in both directions. Ascending melodic minor has a smoother, more melodic minor quality. Less exotic than harmonic minor, more soulful. It's heavily used in jazz improvisation and in romantic classical melodies.",
            category: "Major/Minor"
        ),
        
        // Pentatonic Scales
        ScaleDefinition(
            name: "Major Pentatonic Scale",
            formula: "W–W–(W+H)–W–(W+H)",
            degrees: "1–2–3–5–6",
            cExample: "C–D–E–G–A",
            semitoneOffsets: [0, 2, 4, 7, 9],
            usage: "The major pentatonic is a 5-note scale found in many cultures. It has no semitone steps, so it sounds very open and consonant (hard to land on a 'wrong' note). It's famously heard in East Asian music, native South American music, African-American spirituals, folk songs, rock and country music. Children's songs often use it. It gives a bright, sweet, uncomplicated sound.",
            category: "Pentatonic"
        ),
        
        ScaleDefinition(
            name: "Minor Pentatonic Scale",
            formula: "(W+H)–W–W–(W+H)–W",
            degrees: "1–♭3–4–5–♭7",
            cExample: "C–E♭–F–G–B♭",
            semitoneOffsets: [0, 3, 5, 7, 10],
            usage: "The minor pentatonic is the go-to scale for blues, rock, and pop solos. Remove the 2nd and 6th from natural minor and you get this scale. It sounds bluesy, soulful, and slightly melancholic but stable. Guitarists use it for riffs and improvisation. Almost every rock/blues guitar solo is based on minor pentatonic. It's universally a 'cool' or 'sad' scale that's easy to play with.",
            category: "Pentatonic"
        ),
        
        ScaleDefinition(
            name: "Blues Scale",
            formula: "m3–W–H–H–m3–W",
            degrees: "1–♭3–4–♭5–5–♭7",
            cExample: "C–E♭–F–G♭–G–B♭",
            semitoneOffsets: [0, 3, 5, 6, 7, 10],
            usage: "The blues scale is essentially the minor pentatonic plus one extra note: the diminished 5th (blue note). This added note creates a lot of the expressive dissonance characteristic of blues. Musicians will bend or slide through that blue note for emotion. It sounds bluesy, gritty, and soulful. Used in blues, rock, jazz, any genre influenced by blues. The blues scale's ♭5 gives a tension that resolves to the 4 or 5.",
            category: "Pentatonic"
        ),
        
        // Modal Scales
        ScaleDefinition(
            name: "Dorian Mode",
            formula: "W–H–W–W–W–H–W",
            degrees: "1–2–♭3–4–5–6–♭7",
            cExample: "C–D–E♭–F–G–A–B♭",
            semitoneOffsets: [0, 2, 3, 5, 7, 9, 10],
            usage: "Dorian is like a natural minor scale but with a raised 6th. Its sound is minor but a bit brighter/smoother due to that major 6th. Dorian is common in jazz, funk and modal rock. 'So What' by Miles Davis is in D Dorian mode throughout. Dorian mode often gives a melancholy yet hopeful vibe. It's also heard in Celtic music.",
            category: "Modes"
        ),
        
        ScaleDefinition(
            name: "Phrygian Mode",
            formula: "H–W–W–W–H–W–W",
            degrees: "1–♭2–♭3–4–5–♭6–♭7",
            cExample: "C–D♭–E♭–F–G–A♭–B♭",
            semitoneOffsets: [0, 1, 3, 5, 7, 8, 10],
            usage: "Phrygian has a very southern Spanish, flamenco flavor due to the ♭2 step right above the tonic. It sounds dark, exotic, and unresolved. In flamenco music, it's heavily used. The intro riff of Metallica's 'Wherever I May Roam' centers on E Phrygian. Use Phrygian mode for a brooding or ethnic feel. You can also hear this in Miles Davis 'Sketches of Spain' with spanish music written by De Falla and Rodrigo.",
            category: "Modes"
        ),
        
        ScaleDefinition(
            name: "Lydian Mode",
            formula: "W–W–W–H–W–W–H",
            degrees: "1–2–3–♯4–5–6–7",
            cExample: "C–D–E–F♯–G–A–B",
            semitoneOffsets: [0, 2, 4, 6, 7, 9, 11],
            usage: "Lydian is like a major scale with a sharpened 4th. This raised 4th gives Lydian a dreamy, floating, otherworldly quality. Lydian often appears in film scores and progressive rock to convey wonder or brightness. The theme from The Simpsons starts with a Lydian chord. Use Lydian when you want a majestic or ethereal twist on major.",
            category: "Modes"
        ),
        
        ScaleDefinition(
            name: "Mixolydian Mode",
            formula: "W–W–H–W–W–H–W",
            degrees: "1–2–3–4–5–6–♭7",
            cExample: "C–D–E–F–G–A–B♭",
            semitoneOffsets: [0, 2, 4, 5, 7, 9, 10],
            usage: "Mixolydian is like a major scale but with a minor 7th. The ♭7 gives it a bluesy or folksy feel and removes the leading tone. Mixolydian is extremely common in rock, blues, and folk. 'Sweet Home Alabama' verses are essentially D Mixolydian. Celtic folk music often uses Mixolydian. The Mixolydian mode gives a relaxed, groove-oriented major vibe.",
            category: "Modes"
        ),
        
        ScaleDefinition(
            name: "Locrian Mode",
            formula: "H–W–W–H–W–W–W",
            degrees: "1–♭2–♭3–4–♭5–♭6–♭7",
            cExample: "C–D♭–E♭–F–G♭–A♭–B♭",
            semitoneOffsets: [0, 1, 3, 5, 6, 8, 10],
            usage: "Locrian is a fairly unstable mode, the 5th scale degree is flattened, so the tonic chord is a diminished chord! Locrian sounds dissonant, unresolved, and rarely functions as a home scale in tonal music. It's used to create a sense of tension or evil. Some metal riffs or jazz passages use Locrian mode over half-diminished chords. Locrian's character is dark and unstable, best used when you want listeners to feel unsettled.",
            category: "Modes"
        ),
        
        //"exotic" scales, lol
        ScaleDefinition(
            name: "Whole Tone Scale",
            formula: "W–W–W–W–W–W",
            degrees: "1–2–3–♯4–♯5–♭7",
            cExample: "C–D–E–F♯–G♯–A♯",
            semitoneOffsets: [0, 2, 4, 6, 8, 10],
            usage: "The whole tone scale is a 6-note symmetric scale where every interval is a whole step. This produces a very distinctive dreamlike, floating sound often described as 'impressionistic.' Debussy and Stravinsky famously used whole tone passages to evoke an ethereal, ambiguous atmosphere. In jazz, it's used to solo over augmented chords. Use it when wanting to eliminate a sense of key, it gives a wandering, magical vibe.",
            category: "Exotic"
        ),
        
        ScaleDefinition(
            name: "Chromatic Scale",
            formula: "H–H–H–H–H–H–H–H–H–H–H–H",
            degrees: "1–♭2–2–♭3–3–4–♭5–5–♭6–6–♭7–7",
            cExample: "C–C♯–D–D♯–E–F–F♯–G–G♯–A–A♯–B",
            semitoneOffsets: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
            usage: "The chromatic scale includes every semitone in the octave. It doesn't belong to a particular key; instead, it's used for embellishment, modulation, or effect. Chromatic runs or fills are common. By itself, the chromatic scale sounds tonally ambiguous and very tense if sustained. However, when used in passing, it enriches melodies. It's the musical alphabet with all letters, used to construct any melody.",
            category: "Exotic"
        ),
        
        //diminished scales
        ScaleDefinition(
            name: "Half-Whole Diminished Scale",
            formula: "H–W–H–W–H–W–H–W",
            degrees: "1–♭2–♭3–3–♭5–5–6–♭7",
            cExample: "C–D♭–E♭–E–F♯–G–A–B♭",
            semitoneOffsets: [0, 1, 3, 4, 6, 7, 9, 10],
            usage: "The half-whole diminished scale is commonly used over dominant 7th chords, especially those with altered ninths. Jazz improvisers use it on dominants to create a dissonant, driving sound that resolves to the next chord. Classical composers used the octatonic scales to evoke an ominous or mysterious atmosphere. This scale is tense, complex, and unstable, making it perfect for leading into resolution. Think Wagner, or Bernard Herrmann in Hitchcock's 'Vertigo'",
            category: "Diminished"
        ),
        
        ScaleDefinition(
            name: "Whole-Half Diminished Scale",
            formula: "W–H–W–H–W–H–W–H",
            degrees: "1–2–♭3–4–♭5–♭6–6–7",
            cExample: "C–D–E♭–F–G♭–A♭–A–B",
            semitoneOffsets: [0, 2, 3, 5, 6, 8, 9, 11],
            usage: "The whole-half diminished scale is typically used over diminished 7th chords. This scale has a very symmetric structure that aligns with the diminished chord. It sounds unsettled, spooky, and suspenseful. Think of classic horror or film noir music where diminished runs signal danger. In jazz, if you see a dim7 chord, the whole-half scale is a tool to navigate it.",
            category: "Diminished"
        )
    ]
    
    var scalesByCategory: [String: [ScaleDefinition]] {
        var categorized: [String: [ScaleDefinition]] = [:]
        
        for scale in scales {
            if categorized[scale.category] == nil {
                categorized[scale.category] = []
            }
            categorized[scale.category]?.append(scale)
        }
        
        return categorized
    }
    
    func searchScales(_ query: String) -> [ScaleDefinition] {
        if query.isEmpty {
            return scales
        }
        
        return scales.filter { scale in
            scale.name.localizedCaseInsensitiveContains(query) ||
            scale.degrees.localizedCaseInsensitiveContains(query) ||
            scale.formula.localizedCaseInsensitiveContains(query) ||
            scale.usage.localizedCaseInsensitiveContains(query) ||
            scale.category.localizedCaseInsensitiveContains(query)
        }
    }
    
    //generate scale notes for any root note
    func getScaleNotes(scale: ScaleDefinition, rootNote: String) -> [String] {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let rootMap: [String: Int] = [
            "C": 0, "C#/Db": 1, "D": 2, "D#/Eb": 3, "E": 4, "F": 5,
            "F#/Gb": 6, "G": 7, "G#/Ab": 8, "A": 9, "A#/Bb": 10, "B": 11
        ]
        
        guard let rootIndex = rootMap[rootNote] else { return [] }
        
        return scale.semitoneOffsets.map { offset in
            let noteIndex = (rootIndex + offset) % 12
            return noteNames[noteIndex]
        }
    }
}
