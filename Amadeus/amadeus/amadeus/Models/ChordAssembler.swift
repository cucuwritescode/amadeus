import Foundation
import Tonic
//created by Facundo Franchino

// MARK: - Chord Assembly Configuration

struct ChordAssemblerConfig {
    static let windowSizeSec: Double = 2.0   // 2 second windows for chord analysis
    static let overlapSec: Double = 1.0      // 1 second overlap
    static let minConfidence: Float = 0.4    //moderately high threshold for note inclusion
    static let maxChordGap: Double = 0.5     //,ax gap to merge chords
    static let minNotesPerChord: Int = 2     //minimum notes to form a chord
}

// MARK: - Chord Assembler

class ChordAssembler {
    
    func assembleChords(from noteEvents: [NoteEvent]) -> [ChordDetection] {
        guard !noteEvents.isEmpty else { return [] }
        
        //first create time windows
        let windows = createTimeWindows(from: noteEvents)
        
        //then coonvert windows to chord detections
        var chordDetections: [ChordDetection] = []
        for window in windows {
            if let detection = analyzeWindow(window) {
                chordDetections.append(detection)
            }
        }
        
        //merge adjacent identical chords
        return mergeAdjacentChords(chordDetections)
    }
    
    private func createTimeWindows(from noteEvents: [NoteEvent]) -> [TimeWindow] {
        let sortedEvents = noteEvents.sorted { $0.onsetTime < $1.onsetTime }
        
        guard let firstEvent = sortedEvents.first,
              let lastEvent = sortedEvents.last else { return [] }
        
        let startTime = firstEvent.onsetTime
        let endTime = max(lastEvent.offsetTime, lastEvent.onsetTime + 1.0)
        
        var windows: [TimeWindow] = []
        var currentTime = startTime
        
        while currentTime < endTime {
            let windowEnd = min(currentTime + ChordAssemblerConfig.windowSizeSec, endTime)
            let notesInWindow = findNotesInWindow(
                sortedEvents,
                start: currentTime,
                end: windowEnd
            )
            
            windows.append(TimeWindow(
                startTime: currentTime,
                endTime: windowEnd,
                notes: notesInWindow
            ))
            
            currentTime += ChordAssemblerConfig.windowSizeSec - ChordAssemblerConfig.overlapSec
        }
        
        return windows
    }
    
    private func findNotesInWindow(_ sortedEvents: [NoteEvent], start: Double, end: Double) -> [NoteEvent] {
        return sortedEvents.filter { note in
            //note is active during this window if it overlaps with the window
            note.offsetTime > start && note.onsetTime < end
        }
    }
    
    private func analyzeWindow(_ window: TimeWindow) -> ChordDetection? {
        let validNotes = window.notes.filter { 
            $0.isValid && $0.confidence >= ChordAssemblerConfig.minConfidence 
        }
        
        guard validNotes.count >= ChordAssemblerConfig.minNotesPerChord else { return nil }
        
        //extract pitch classes and their weights with a more decent scoring
        var pitchClassWeights: [Int: Float] = [:]
        
        for note in validNotes {
            let pc = note.pitchClass
            //simple weighting by confidence and duration
            let weight = note.confidence * Float(note.duration)
            pitchClassWeights[pc, default: 0] += weight
        }
        
        //only keep the strongest pitch classes
        let sortedByWeight = pitchClassWeights.sorted { $0.value > $1.value }
        let topWeights = Array(sortedByWeight.prefix(6)) //max 6 notes in a chord
        
        //only keep pitch classes that are at least 20% of the strongest
        let maxWeight = topWeights.first?.value ?? 0
        let threshold = maxWeight * 0.2
        
        let significantPitchClasses = topWeights.compactMap { (pc, weight) in
            weight >= threshold ? pc : nil
        }
        
        guard significantPitchClasses.count >= 2 else { return nil }
        
        //tracing/debug, show what notes being detected with their weights
        let noteInfo = topWeights.prefix(4).map { (pc, weight) in
            let names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
            return "\(names[pc % 12])(\(String(format: "%.2f", weight)))"
        }
        print("    🎹 Window \(String(format: "%.1f", window.startTime))s: \(noteInfo.joined(separator: ", "))")
        
        //convert pitch classes to Pitches for Tonic
        let pitches = significantPitchClasses.map { pitchClass in
            Pitch(Int8(pitchClass + 60)) // Middle C octave
        }
        let pitchSet = PitchSet(pitches: pitches)
        
        //try identifying the chord using Tonic,with C major as default key
        var chord: Chord
        if let identifiedChord = pitchSet.chord(in: Key(root: NoteClass(.C))) {
            chord = identifiedChord
            print("     Tonic identified: \(chord.description)")
        } else {
            //fallback to maj chord from lowest note
            let rootPitchClass = significantPitchClasses.min() ?? 0
            //pitch class mapping (0-11) to note letters
            // 0=C, 1=C#, 2=D, 3=D#, 4=E, 5=F, 6=F#, 7=G, 8=G#, 9=A, 10=A#, 11=B
            let pitchClassToLetter: [Letter] = [.C, .C, .D, .D, .E, .F, .F, .G, .G, .A, .A, .B]
            let rootLetter = pitchClassToLetter[rootPitchClass % 12]
            let accidental: Accidental = [1, 3, 6, 8, 10].contains(rootPitchClass) ? .sharp : .natural
            chord = Chord(NoteClass(rootLetter, accidental: accidental), type: .major)
            print("    ⚠️ Tonic failed, fallback: \(chord.description)")
        }
        
        //calc confidence based on note strength
        let totalWeight = topWeights.map(\.value).reduce(0, +)
        let avgConfidence = totalWeight / Float(validNotes.count)
        
        return ChordDetection(
            startTime: window.startTime,
            endTime: window.endTime,
            chordName: chord.description,
            confidence: min(avgConfidence, 1.0),
            pitchClasses: Set(significantPitchClasses)
        )
    }
    
    private func mergeAdjacentChords(_ detections: [ChordDetection]) -> [ChordDetection] {
        guard detections.count > 1 else { return detections }
        
        var merged: [ChordDetection] = []
        var current = detections[0]
        
        for next in detections.dropFirst() {
            if shouldMergeChords(current, next) {
                //merge 'em chords
                current = ChordDetection(
                    startTime: current.startTime,
                    endTime: next.endTime,
                    chordName: current.chordName,
                    confidence: (current.confidence + next.confidence) / 2,
                    pitchClasses: current.pitchClasses.union(next.pitchClasses)
                )
            } else {
                merged.append(current)
                current = next
            }
        }
        merged.append(current)
        
        return merged
    }
    
    private func shouldMergeChords(_ chord1: ChordDetection, _ chord2: ChordDetection) -> Bool {
        return chord1.chordName == chord2.chordName && 
               (chord2.startTime - chord1.endTime) <= ChordAssemblerConfig.maxChordGap
    }
}

// MARK: - Helper Structures

private struct TimeWindow {
    let startTime: Double
    let endTime: Double
    let notes: [NoteEvent]
    
    var duration: Double {
        return endTime - startTime
    }
}
