//
//  ProgressionDictionary.swift
//  amadeus
//
//  created by facundo franchino on 23/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  common chord progression patterns and analysis
//  educational resource for understanding harmonic movement
//
//  acknowledgements:
//  - progression theory from berklee college of music resources
//  - roman numeral analysis based on western classical harmony 
//

import Foundation
//created by Facundo Franchino
//a dictionary of chord progressions for the library page
// represents a chord within a progression
struct ProgressionChord: Identifiable, Hashable {
    let id = UUID()
    let chord: String
    let notes: [Int] //midi note numbers (c4 being 60)
}

//represents a complete chord progression with theory information
struct ChordProgression: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nickname: String
    let romanNumeralsMajor: String
    let romanNumeralsMinor: String
    let description: String
    let tempoRange: String
    let songExamples: [String]
    let majorProgression: [ProgressionChord]
    let minorProgression: [ProgressionChord]
    
    var displayName: String {
        "\(romanNumeralsMajor) (\(nickname))"
    }
}

//dictionary of common chord progressions
class ProgressionDictionary {
    static let shared = ProgressionDictionary()
    
    let progressions: [ChordProgression] = [
        // I–V–vi–IV (Pop Progression)
        ChordProgression(
            name: "I–V–vi–IV",
            nickname: "Pop Progression",
            romanNumeralsMajor: "I–V–vi–IV",
            romanNumeralsMinor: "i–♭VII–♭III–♭VI",
            description: """
            Often called the "4-chord pop" progression, it is ubiquitous in modern pop and rock. In a major key it goes: I → V → vi → IV (e.g., in C: C → G → Am → F). It creates a strong emotional pull: starting on the triumphant I, moving through tension on V, a relative minor vi for a poignant lift, and IV which leads back warmly. This progression feels uplifting, catchy, and resolves satisfyingly to I.
            
            In minor, the analogous sequence i–♭VII–♭III–♭VI is common in rock (e.g., in A minor: Am → G → C → F) giving a heroic, modal sound.
            """,
            tempoRange: "Medium (75–120 BPM)",
            songExamples: ["Don't Stop Believin' (Journey)", "With or Without You (U2)", "Let It Be (The Beatles)", "Zombie (The Cranberries)"],
            majorProgression: [
                ProgressionChord(chord: "C", notes: [60, 64, 67]),   //C major (I)
                ProgressionChord(chord: "G", notes: [55, 59, 62]),   // G major (V)
                ProgressionChord(chord: "Am", notes: [57, 60, 64]),  // A minor (vi)
                ProgressionChord(chord: "F", notes: [53, 57, 60])    //F major (IV)
            ],
            minorProgression: [
                ProgressionChord(chord: "Cm", notes: [60, 63, 67]),  // C minor (i)
                ProgressionChord(chord: "B♭", notes: [58, 62, 65]),  // B♭ major (♭VII)
                ProgressionChord(chord: "E♭", notes: [63, 67, 70]),  // E♭ major (♭III)
                ProgressionChord(chord: "A♭", notes: [56, 60, 65])   //A♭ major (♭VI)
            ]
        ),
        
        // ii–V–I (jazz "2wo-five-one")
        ChordProgression(
            name: "ii–V–I",
            nickname: "Jazz Two-Five-One",
            romanNumeralsMajor: "ii–V–I",
            romanNumeralsMinor: "ii°–V–i",
            description: """
            The ii–V–I is the signature chord turnaround in jazz. In a major key, it's ii (a minor chord) → V (dominant) → I (tonic major). For example, in C major: Dm7 → G7 → Cmaj7. This progression establishes strong functional harmony: ii leads to V (dominant function), which creates tension that resolves to I.
            
            It produces that unmistakable satisfying cadence at the end of jazz phrases or song sections. Emotionally, it gives a sense of forward motion and resolution – essential in swing, bebop, and standards. In minor keys, the pattern is ii°–V–i with the ii chord being half-diminished, giving a darker color leading into the dominant.
            """,
            tempoRange: "Varies widely (60–200+ BPM)",
            songExamples: ["Autumn Leaves", "Fly Me to the Moon", "All the Things You Are", "Giant Steps"],
            majorProgression: [
                ProgressionChord(chord: "Dm7", notes: [62, 65, 69, 72]), // D minor 7 (ii)
                ProgressionChord(chord: "G7", notes: [55, 59, 62, 65]),  //G7 (V)
                ProgressionChord(chord: "Cmaj7", notes: [60, 64, 67, 71]) // Cmaj7 (I)
            ],
            minorProgression: [
                ProgressionChord(chord: "Dm7♭5", notes: [62, 65, 68, 72]), // Dm7♭5 (ii°)
                ProgressionChord(chord: "G7", notes: [55, 59, 62, 65]),     // G7 (V)
                ProgressionChord(chord: "Cm", notes: [60, 63, 67])          //Cm (i)
            ]
        ),
        
        // I–IV–V (three-chord rock/blues)
        ChordProgression(
            name: "I–IV–V",
            nickname: "Three-Chord Rock/Blues",
            romanNumeralsMajor: "I–IV–V",
            romanNumeralsMinor: "i–iv–V",
            description: """
            The 1-4-5 progression is one of the simplest and most influential patterns in Western music. In a major key (I, IV, V are all major chords), it underpins countless blues, rock, country, and folk songs. For example, in G major: G (I) → C (IV) → D (V).
            
            Emotionally it feels stable, familiar, and high-energy. It outlines the tonic, then subdominant, then the dominant that pulls back to the tonic. It's the basis of the 12-bar blues and countless early rock 'n' roll hits. In minor, the comparable progression is i–iv–V, where the V is often major (harmonic minor influence) to get that leading-tone pull.
            """,
            tempoRange: "Medium to upbeat (100–140 BPM)",
            songExamples: ["La Bamba", "Twist and Shout", "Louie Louie", "Wild Thing"],
            majorProgression: [
                ProgressionChord(chord: "C", notes: [60, 64, 67]),   // C major (I)
                ProgressionChord(chord: "F", notes: [53, 57, 60]),   // F major (IV)
                ProgressionChord(chord: "G", notes: [55, 59, 62])    // G major (V)
            ],
            minorProgression: [
                ProgressionChord(chord: "Cm", notes: [60, 63, 67]),  // C minor (i)
                ProgressionChord(chord: "Fm", notes: [53, 56, 60]),  // F minor (iv)
                ProgressionChord(chord: "G", notes: [55, 59, 62])    // G major (V)
            ]
        ),
        
        // vi–IV–I–V ("Pop Rock" progression)
        ChordProgression(
            name: "vi–IV–I–V",
            nickname: "Pop Rock Progression",
            romanNumeralsMajor: "vi–IV–I–V",
            romanNumeralsMinor: "i–♭VI–♭III–♭VII",
            description: """
            This is a rotated variant of the I–V–vi–IV progression, starting on the vi chord. In a major key, vi is the relative minor, so beginning on vi gives a wistful, emotional flavor before rising to the triumphant I. In C major: Am (vi) → F (IV) → C (I) → G (V).
            
            This progression has a strong sense of resolution at the end (V to I loops back nicely to vi in repetition). It's extremely popular in pop-rock ballads and anthems. The emotional quality is often yearning or inspirational – starting minor and resolving to major.
            """,
            tempoRange: "Moderate (80–110 BPM)",
            songExamples: ["Africa (Toto)", "Demons (Imagine Dragons)", "Zombie (The Cranberries)"],
            majorProgression: [
                ProgressionChord(chord: "Am", notes: [57, 60, 64]),  // vi = A minor
                ProgressionChord(chord: "F", notes: [53, 57, 60]),   // IV = F major
                ProgressionChord(chord: "C", notes: [60, 64, 67]),   // I = C major
                ProgressionChord(chord: "G", notes: [55, 59, 62])    // V = G major
            ],
            minorProgression: [
                ProgressionChord(chord: "Cm", notes: [60, 63, 67]),  // i = C minor
                ProgressionChord(chord: "A♭", notes: [56, 60, 63]),  // ♭VI = A♭
                ProgressionChord(chord: "E♭", notes: [63, 67, 70]),  // ♭III = E♭
                ProgressionChord(chord: "B♭", notes: [58, 62, 65])   // ♭VII = B♭
            ]
        ),
        
        // I–vi–IV–V (1950a doo-wop progression)
        ChordProgression(
            name: "I–vi–IV–V",
            nickname: "50s Doo-Wop Progression",
            romanNumeralsMajor: "I–vi–IV–V",
            romanNumeralsMinor: "i–♭III–♭VI–♭VII",
            description: """
            Also known as the "50s progression," I–vi–IV–V was the foundation of many early rock 'n' roll, doo-wop, and pop songs in the 1950s and early 60s. In C major: C (I) → Am (vi) → F (IV) → G (V).
            
            This progression cycles from the cheery I to its relative minor (vi) giving a sentimental touch, then to IV and strong dominant V, which yearns to resolve back to I. It has a nostalgic, warm, and romantic feel, think classic doo-wop ballads and soul.
            """,
            tempoRange: "Mid-tempo or slow (50–90 BPM)",
            songExamples: ["Stand By Me (Ben E. King)", "Earth Angel (The Penguins)", "Blue Moon", "Every Breath You Take (The Police)"],
            majorProgression: [
                ProgressionChord(chord: "C", notes: [60, 64, 67]),   // I = C major
                ProgressionChord(chord: "Am", notes: [57, 60, 64]),  // vi = A minor
                ProgressionChord(chord: "F", notes: [53, 57, 60]),   // IV = F major
                ProgressionChord(chord: "G", notes: [55, 59, 62])    // V = G major
            ],
            minorProgression: [
                ProgressionChord(chord: "Cm", notes: [60, 63, 67]),  // i = C minor
                ProgressionChord(chord: "E♭", notes: [63, 67, 70]),  // ♭III = E♭
                ProgressionChord(chord: "A♭", notes: [56, 60, 63]),  // ♭VI = A♭
                ProgressionChord(chord: "B♭", notes: [58, 62, 65])   // ♭VII = B♭
            ]
        ),
        
        // I–♭VII–IV (Mixolydian Rock)
        ChordProgression(
            name: "I–♭VII–IV",
            nickname: "Mixolydian Rock",
            romanNumeralsMajor: "I–♭VII–IV",
            romanNumeralsMinor: "i–♭VII–iv",
            description: """
            I–♭VII–IV is a common progression in classic rock, creating a Mixolydian mode flavor (because the ♭VII chord implies a flattened 7th scale degree as in the Mixolydian scale). The ♭VII chord (a whole step below the tonic) adds a bluesy, modal feel without the typical V chord tension.
            
            The progression often loops and has an anthemic, driving quality great for riffs. It's uplifting in a raw, rootsy way, as it eschews the strong V chord resolution. In minor, a similar idea might be i–♭VII–iv which appears in some rock contexts.
            """,
            tempoRange: "Upbeat (100–130 BPM)",
            songExamples: ["Sweet Home Alabama (Lynyrd Skynyrd)", "Glory Days (Bruce Springsteen)", "Free Fallin' (Tom Petty)"],
            majorProgression: [
                ProgressionChord(chord: "C", notes: [60, 64, 67]),   // I = C major
                ProgressionChord(chord: "B♭", notes: [58, 62, 65]),  // ♭VII = B♭ major
                ProgressionChord(chord: "F", notes: [53, 57, 60])    //IV = F major
            ],
            minorProgression: [
                ProgressionChord(chord: "Cm", notes: [60, 63, 67]),  // i = C minor
                ProgressionChord(chord: "B♭", notes: [58, 62, 65]),  //♭VII = B♭ major
                ProgressionChord(chord: "Fm", notes: [53, 56, 60])   // iv = F minor
            ]
        ),
        
        // i–♭VII–♭VI–V (Andalusian Cadence)
        ChordProgression(
            name: "i–♭VII–♭VI–V",
            nickname: "Andalusian Cadence",
            romanNumeralsMajor: "I–♭VII–♭VI–V",
            romanNumeralsMinor: "i–♭VII–♭VI–V",
            description: """
            This four-chord sequence is a classic minor-key progression, sometimes called the Andalusian cadence. In A minor: Am (i) → G (♭VII) → F (♭VI) → E(7) (V). It features a stepwise descending bass line (A → G → F → E) which gives it a dramatic, Spanish or classical feel.
            
            Emotionally it's intense and dark yet satisfying because the V (major V in minor) provides a strong pull back to i. It's the basis of many flamenco progressions and appears frequently in rock music with modal mixture for dramatic effect.
            """,
            tempoRange: "Variable (60–200+ BPM)",
            songExamples: ["Hit the Road Jack (Ray Charles)", "All Along the Watchtower", "Spanish Caravan (The Doors)"],
            majorProgression: [
                ProgressionChord(chord: "C", notes: [60, 64, 67]),   // I = C major
                ProgressionChord(chord: "B♭", notes: [58, 62, 65]),  // ♭VII = B♭ major
                ProgressionChord(chord: "A♭", notes: [56, 60, 63]),  // ♭VI = A♭ major
                ProgressionChord(chord: "G", notes: [55, 59, 62])    // V = G major
            ],
            minorProgression: [
                ProgressionChord(chord: "Cm", notes: [60, 63, 67]),   // i = C minor
                ProgressionChord(chord: "B♭", notes: [58, 62, 65]),   // ♭VII = B♭ major
                ProgressionChord(chord: "A♭", notes: [56, 60, 63]),   // ♭VI = A♭ major
                ProgressionChord(chord: "G", notes: [55, 59, 62])     // V = G major
            ]
        ),
        
        // ii–V–iii–vi (Circle Progression)
        ChordProgression(
            name: "ii–V–iii–vi",
            nickname: "Circle Progression",
            romanNumeralsMajor: "ii–V–iii–vi",
            romanNumeralsMinor: "ii°–V–♭III–♭VI",
            description: """
            This progression is a sequence of descending fifths (or ascending fourths) through the diatonic scale. In C major: Dm (ii) → G (V) → Em (iii) → Am (vi). Each chord's root is a fifth below the previous, creating continuous movement through the circle of fifths.
            
            It's often used as a turnaround or circle-of-fifths progression to lead back to a ii or IV. Because it's part of the cycle of fifths, it gives a sense of continuous movement. In jazz it can sound sophisticated, adding surprise before resolving.
            """,
            tempoRange: "Variable (often medium-fast in jazz)",
            songExamples: ["I Got Rhythm (bridge)", "Sunday Morning (Maroon 5)", "Rhythm Changes"],
            majorProgression: [
                ProgressionChord(chord: "Dm7", notes: [62, 65, 69]),  // ii = Dm7
                ProgressionChord(chord: "G7", notes: [55, 59, 65]),   // V = G7
                ProgressionChord(chord: "Em", notes: [52, 55, 59]),   // iii = Em
                ProgressionChord(chord: "Am", notes: [57, 60, 64])    // vi = Am
            ],
            minorProgression: [
                ProgressionChord(chord: "Dm7♭5", notes: [62, 65, 68]), // ii° = Dm7♭5
                ProgressionChord(chord: "G7", notes: [55, 59, 65]),     // V = G7
                ProgressionChord(chord: "E♭", notes: [63, 67, 70]),     // ♭III = E♭
                ProgressionChord(chord: "A♭", notes: [56, 60, 63])      // ♭VI = A♭
            ]
        )
    ]
    
    var progressionsByCategory: [String: [ChordProgression]] {
        var categorized: [String: [ChordProgression]] = [:]
        
        for progression in progressions {
            let category = getProgressionCategory(progression)
            if categorized[category] == nil {
                categorized[category] = []
            }
            categorized[category]?.append(progression)
        }
        
        return categorized
    }
    
    private func getProgressionCategory(_ progression: ChordProgression) -> String {
        let nickname = progression.nickname.lowercased()
        
        if nickname.contains("pop") {
            return "Pop/Rock"
        } else if nickname.contains("jazz") {
            return "Jazz"
        } else if nickname.contains("blues") || nickname.contains("rock") {
            return "Blues/Rock"
        } else if nickname.contains("doo-wop") || nickname.contains("50s") {
            return "Classic/Vintage"
        } else if nickname.contains("andalusian") || nickname.contains("mixolydian") {
            return "Modal/World"
        } else if nickname.contains("circle") {
            return "Advanced/Jazz"
        }
        
        return "Other"
    }
    
    func searchProgressions(_ query: String) -> [ChordProgression] {
        if query.isEmpty {
            return progressions
        }
        
        return progressions.filter { progression in
            progression.name.localizedCaseInsensitiveContains(query) ||
            progression.nickname.localizedCaseInsensitiveContains(query) ||
            progression.romanNumeralsMajor.localizedCaseInsensitiveContains(query) ||
            progression.romanNumeralsMinor.localizedCaseInsensitiveContains(query) ||
            progression.description.localizedCaseInsensitiveContains(query) ||
            progression.songExamples.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}
