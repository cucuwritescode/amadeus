import Foundation
import AVFoundation
import CoreML
import Accelerate

// MARK: - Basic Pitch Analyzer

class BasicPitchAnalyzer: ChordAnalyzer {
    
    private var model: nmp?
    private let chordAssembler = ChordAssembler()
    
    enum BasicPitchError: Error {
        case modelLoadFailed
        case invalidAudioFormat
        case predictionFailed
        case modelNotFound
    }
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        print("Attempting to load Basic Pitch model...")
        do {
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all
            model = try nmp(configuration: configuration)
            print("Basic Pitch model loaded successfully")
            print("   Model: \(model.debugDescription)")
        } catch {
            print("Failed to load Basic Pitch model: \(error)")
            print("   Error details: \(error.localizedDescription)")
        }
    }
    
    func analyze(audioBuffer: AVAudioPCMBuffer, sampleRate: Float) async -> [ChordDetection] {
        print("BasicPitchAnalyzer.analyze() called")
        print("  • Buffer: \(audioBuffer.frameLength) frames @ \(sampleRate) Hz")
        
        // Check if model is available
        guard model != nil else {
            print("Basic Pitch model not available, falling back to simulation")
            print("   Model is nil - check if nmp.mlpackage is in the project")
            return await SimulatedChordAnalyzer().analyze(audioBuffer: audioBuffer, sampleRate: sampleRate)
        }
        
        print("Model is loaded, attempting analysis...")
        
        do {
            // Step 1: Convert audio to raw sample chunks for CoreML model
            print("  Step 1: Converting audio to 43,844-sample chunks...")
            let modelInputs = try BasicPitchPreprocessor.audioBufferToModelInputs(audioBuffer)
            print("   Created \(modelInputs.count) audio chunks of 43,844 samples each")
            
            var allNoteEvents: [NoteEvent] = []
            let numChunks = modelInputs.count
            let chunkDurationSeconds = Double(BasicPitchPreprocessor.chunkSampleCount) / BasicPitchPreprocessor.targetSampleRate
            
            for chunkIndex in 0..<numChunks {
                let timeOffsetSeconds = Double(chunkIndex) * chunkDurationSeconds
                
                // Only show progress for every 20 chunks or last chunk
                if chunkIndex % 20 == 0 || chunkIndex == numChunks - 1 {
                    print("   Processing chunk \(chunkIndex + 1)/\(numChunks) (time: \(String(format: "%.1f", timeOffsetSeconds))s)")
                }
                
                // Run Basic Pitch on this raw audio chunk
                let modelOutput = try await runBasicPitchInference(modelInputs[chunkIndex])
                let chunkNotes = extractNoteEvents(from: modelOutput)
                
                // Adjust note times by chunk offset
                let adjustedNotes = chunkNotes.map { note in
                    NoteEvent(
                        onsetTime: note.onsetTime + timeOffsetSeconds,
                        offsetTime: note.offsetTime + timeOffsetSeconds,
                        midiPitch: note.midiPitch,
                        confidence: note.confidence
                    )
                }
                
                allNoteEvents.append(contentsOf: adjustedNotes)
                // Only log chunks with significant notes
                if adjustedNotes.count > 5 {
                    print("     Extracted \(adjustedNotes.count) notes from chunk \(chunkIndex + 1)")
                }
            }
            
            print("   Total: \(allNoteEvents.count) notes from \(numChunks) chunks")
            
            // Step 3: Convert note events to chord detections
            print("  Step 3: Assembling chords...")
            let chordDetections = chordAssembler.assembleChords(from: allNoteEvents)
            print("   Assembled \(chordDetections.count) chord segments")
            
            print("✅ Basic Pitch analysis complete: \(allNoteEvents.count) notes → \(chordDetections.count) chords")
            
            // Print first few chords for debugging
            for (index, chord) in chordDetections.prefix(5).enumerated() {
                print("   Chord \(index + 1): \(chord.chordName) at \(String(format: "%.2f", chord.startTime))s")
            }
            
            return chordDetections
            
        } catch {
            print(" Basic Pitch analysis failed at some step")
            print("   Error type: \(type(of: error))")
            print("   Error: \(error)")
            print("   Falling back to simulation")
            return await SimulatedChordAnalyzer().analyze(audioBuffer: audioBuffer, sampleRate: sampleRate)
        }
    }
    
    // MARK: - Audio Preprocessing (now handled by BasicPitchPreprocessor)
    
    // MARK: - CoreML Inference
    
    private func runBasicPitchInference(_ audioInput: MLMultiArray) async throws -> BasicPitchOutput {
        guard let model = model else {
            throw BasicPitchError.modelNotFound
        }
        
        // Create input for the auto-generated nmp model
        let input = nmpInput(input_2: audioInput)
        
        // Run prediction using the auto-generated nmp class
        let output = try await Task {
            try model.prediction(input: input)
        }.value
        
        // Extract outputs from the nmpOutput
        return try extractModelOutputs(output)
    }
    
    private func extractModelOutputs(_ output: nmpOutput) throws -> BasicPitchOutput {
        // Extract outputs using MLFeatureProvider interface since property names may vary
        
        var onsetArray: MLMultiArray?
        var frameArray: MLMultiArray?
        var contourArray: MLMultiArray?
        
        // Basic Pitch typically has: onset (Identity_1), frame (Identity_2), contour (Identity)
        // Let's map them correctly based on common patterns
        for name in output.featureNames {
            if let array = output.featureValue(for: name)?.multiArrayValue {
                // Map based on common Basic Pitch naming patterns
                if name.contains("1") || name.contains("onset") {
                    onsetArray = array
                } else if name.contains("2") || name.contains("frame") {
                    frameArray = array
                } else {
                    contourArray = array
                }
            }
        }
        
        guard let onsets = onsetArray else {
            print("     No outputs found in model response!")
            print("    Available outputs: \(output.featureNames)")
            throw BasicPitchError.predictionFailed
        }
        
        // If we only have one output, duplicate it for frame (temporary workaround)
        if frameArray == nil {
            print("    ⚠️ Only one output found, using it for both onset and frame")
            frameArray = onsets
        }
        
        guard let frames = frameArray else {
            throw BasicPitchError.predictionFailed
        }
        
        let onsetProbs = convertMLArrayTo2D(onsets)
        let frameProbs = convertMLArrayTo2D(frames)
        let contourProbs = contourArray.map { convertMLArrayTo2D($0) }
        
        // TEMP DEBUG: Verify dimensions and pitch mapping
        if !onsetProbs.isEmpty {
            print("DEBUG: timeFrames = \(onsetProbs.count), pitches = \(onsetProbs[0].count)")
            for p in 0..<min(5, onsetProbs[0].count) {
                let maxOnsetForPitch = onsetProbs.map { $0[p] }.max() ?? 0
                print("  PitchIndex \(p) (MIDI \(21 + p)) max onset = \(maxOnsetForPitch)")
            }
        }
        
        // Debug: Check actual probability ranges
        if !onsetProbs.isEmpty && !frameProbs.isEmpty {
            let maxOnset = onsetProbs.flatMap { $0 }.max() ?? 0
            let maxFrame = frameProbs.flatMap { $0 }.max() ?? 0
            print("     Probability ranges - Max onset: \(String(format: "%.3f", maxOnset)), Max frame: \(String(format: "%.3f", maxFrame))")
        }
        
        return BasicPitchOutput(
            onsetProbs: onsetProbs,
            frameProbs: frameProbs,
            contourProbs: contourProbs
        )
    }
    
    private func convertMLArrayTo2D(_ array: MLMultiArray) -> [[Float]] {
        let shape = array.shape.map { $0.intValue }

        switch shape.count {
        case 3:
            // Expect [batch, time, pitch] = [1, 172, 88]
            let batch   = shape[0]
            let time    = shape[1]
            let pitches = shape[2]

            precondition(batch == 1, "Only batch size 1 is supported")

            let totalCount = batch * time * pitches
            let ptr = array.dataPointer.bindMemory(to: Float.self,
                                                   capacity: totalCount)

            var result = Array(
                repeating: Array(repeating: Float(0), count: pitches),
                count: time
            )

            // Row-major layout: index = b*(time*pitches) + t*pitches + p
            for t in 0..<time {
                for p in 0..<pitches {
                    let idx = 0 * (time * pitches) + t * pitches + p
                    result[t][p] = ptr[idx]
                }
            }
            return result

        case 2:
            // Fallback: [time, pitch]
            let time    = shape[0]
            let pitches = shape[1]
            let total   = time * pitches
            let ptr = array.dataPointer.bindMemory(to: Float.self, capacity: total)

            var result = Array(
                repeating: Array(repeating: Float(0), count: pitches),
                count: time
            )

            for t in 0..<time {
                for p in 0..<pitches {
                    let idx = t * pitches + p
                    result[t][p] = ptr[idx]
                }
            }
            return result

        default:
            print("Unexpected MLMultiArray shape: \(shape)")
            return []
        }
    }
    
    // MARK: - Note Event Extraction
    
    private func extractNoteEvents(from output: BasicPitchOutput) -> [NoteEvent] {
        var noteEvents: [NoteEvent] = []
        
        let _ = output.numTimeFrames
        let numPitches = output.numPitches
        
        // Basic Pitch outputs 88 piano keys starting from MIDI note 21 (A0)
        let baseMidiNote = 21 // A0
        print("  📝 Processing \(numPitches) pitch classes starting from MIDI note \(baseMidiNote)")
        
        // Filter to reasonable pitch range (C2-C7, MIDI 36-96) to avoid harmonics
        // Most music is between MIDI 36-84 (C2-C6)
        let minReasonablePitch = 15  // Start from MIDI 36 (C2) = index 15
        let maxReasonablePitch = 75  // End at MIDI 96 (C7) = index 75
        
        // Process all pitches in reasonable range
        for pitchIndex in minReasonablePitch..<min(maxReasonablePitch, numPitches) {
            let actualMidiPitch = baseMidiNote + pitchIndex
            let noteEventsForPitch = extractNotesForPitch(
                midiPitch: actualMidiPitch,
                onsetProbs: output.onsetProbs.map { $0[pitchIndex] },
                frameProbs: output.frameProbs.map { $0[pitchIndex] }
            )
            noteEvents.append(contentsOf: noteEventsForPitch)
        }
        
        // Filter notes by minimum duration
        
        // Filter by minimum duration and sort by onset time
        let filteredNotes = noteEvents.filter { 
            $0.duration >= BasicPitchConfig.minimumNoteDuration 
        }.sorted { 
            $0.onsetTime < $1.onsetTime 
        }
        
        // Only show extraction count for significant chunks
        if filteredNotes.count > 10 {
            print("     Extracted \(filteredNotes.count) notes from chunk")
        }
        return filteredNotes
    }
    
    private func midiToNoteName(_ midiPitch: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = (midiPitch / 12) - 1
        let noteName = noteNames[midiPitch % 12]
        return "\(noteName)\(octave)"
    }
    
    private func extractNotesForPitch(midiPitch: Int, onsetProbs: [Float], frameProbs: [Float]) -> [NoteEvent] {
        guard onsetProbs.count == frameProbs.count else { return [] }
        
        var noteEvents: [NoteEvent] = []
        var noteStartFrame: Int? = nil
        
        // Debug: check if we have any values above threshold for this pitch
        let _ = onsetProbs.max() ?? 0
        let _ = frameProbs.max() ?? 0
        let _ = onsetProbs.filter { $0 > BasicPitchConfig.onsetThreshold }.count
        let _ = frameProbs.filter { $0 > BasicPitchConfig.frameThreshold }.count
        
        for frameIndex in 0..<onsetProbs.count {
            let onsetProb = onsetProbs[frameIndex]
            let frameProb = frameProbs[frameIndex]
            
            // Basic Pitch detection: require onset to trigger note start, frame to sustain
            let hasOnset = onsetProb > BasicPitchConfig.onsetThreshold
            let hasFrame = frameProb > BasicPitchConfig.frameThreshold
            
            // Start note on onset detection OR high frame confidence
            if (hasOnset || hasFrame) && noteStartFrame == nil {
                noteStartFrame = frameIndex
            }
            
            // Continue note while frame activity remains (with tolerance for gaps)
            if let startFrame = noteStartFrame {
                // More sophisticated note ending logic:
                // 1. We're past the start frame
                // 2. Current frame has no activity
                // 3. Look ahead to see if note truly ended
                
                var shouldEndNote = false
                if frameIndex > startFrame && !hasFrame {
                    // Count consecutive frames without activity
                    var gapCount = 0
                    for ahead in 0..<4 {  // Check current + next 3 frames
                        let checkIdx = frameIndex + ahead
                        if checkIdx >= frameProbs.count {
                            // Reached end of frames
                            shouldEndNote = true
                            break
                        }
                        if frameProbs[checkIdx] <= BasicPitchConfig.frameThreshold {
                            gapCount += 1
                        } else {
                            // Found activity, continue note
                            break
                        }
                    }
                    // End note only if we have 3+ consecutive frames below threshold
                    shouldEndNote = (gapCount >= 3)
                }
                
                if shouldEndNote {
                    let note = createNoteEvent(
                        midiPitch: midiPitch,
                        startFrame: startFrame,
                        endFrame: frameIndex,
                        onsetProbs: onsetProbs,
                        frameProbs: frameProbs
                    )
                    
                    // Only add if duration meets minimum threshold
                    if note.duration >= BasicPitchConfig.minimumNoteDuration {
                        noteEvents.append(note)
                    }
                    
                    noteStartFrame = nil
                } else if frameIndex == onsetProbs.count - 1 && frameIndex > startFrame {
                    // We're at the end of the sequence, close any open notes
                    let note = createNoteEvent(
                        midiPitch: midiPitch,
                        startFrame: startFrame,
                        endFrame: frameIndex + 1,
                        onsetProbs: onsetProbs,
                        frameProbs: frameProbs
                    )
                    
                    if note.duration >= BasicPitchConfig.minimumNoteDuration {
                        noteEvents.append(note)
                    }
                }
            }
        }
        
        return noteEvents
    }
    
    private func createNoteEvent(midiPitch: Int, startFrame: Int, endFrame: Int, 
                                onsetProbs: [Float], frameProbs: [Float]) -> NoteEvent {
        let startTime = Double(startFrame * BasicPitchConfig.hopLength) / Double(BasicPitchConfig.sampleRate)
        let endTime = Double(endFrame * BasicPitchConfig.hopLength) / Double(BasicPitchConfig.sampleRate)
        
        // Calculate average confidence over the note duration
        let relevantFrameProbs = Array(frameProbs[startFrame...min(endFrame, frameProbs.count - 1)])
        let avgConfidence = relevantFrameProbs.isEmpty ? 0.0 : relevantFrameProbs.reduce(0, +) / Float(relevantFrameProbs.count)
        
        return NoteEvent(
            onsetTime: startTime,
            offsetTime: endTime,
            midiPitch: midiPitch,
            confidence: avgConfidence
        )
    }
}
