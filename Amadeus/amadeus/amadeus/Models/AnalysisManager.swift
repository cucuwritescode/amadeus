//
//  AnalysisManager.swift
//  amadeus
//
//  created by facundo franchino on 08/09/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  manages audio analysis pipeline for chord detection and key estimation
//  now coordinates between basic pitch NN and post-processing
//
//  acknowledgements:
//  - basic pitch model by rachel bittner et al. (icassp 2022)
//  - krumhansl-schmuckler key-finding algorithm (cognitive foundations of musical pitch, 1990)
//

import Foundation
import AVFoundation
import AudioKit

//manages audio analysis for chord detection and key estimation
class AnalysisManager: ObservableObject {
//analysis state tracking
    @Published var isAnalyzing = false
//progress of current analysis from 0 to 1
    @Published var analysisProgress: Float = 0
//human-readable status message
    @Published var analysisStatus = ""
//detected chord segments with timing information
    @Published var chordDetections: [ChordDetection] = []
//estimated key of the user loaded file
    @Published var estimatedKey = "—"
//total duration of analysed audio in seconds
    @Published var duration: Double = 0
    
// create fresh pipeline each time to read current settings
    private func createPipeline() -> ChordDetectionPipeline {
        print("AnalysisManager creating fresh pipeline...")
        return ChordDetectionPipeline()
    }
    
// analyse audio file for chord detection and key estimation
    func analyzeAudioFile(_ url: URL) async {
        await MainActor.run {
            self.isAnalyzing = true
            self.analysisStatus = "Loading audio file..."
            self.analysisProgress = 0
        }
        
        do {
            let pipeline = createPipeline()
            let result = try await pipeline.analyzeFile(url) { progress in
                Task { @MainActor in
                    self.analysisProgress = progress
                    
// update status based on progress with smooth transitions
                    switch progress {
                    case 0..<0.1:
                        self.analysisStatus = "Loading audio..."
                    case 0.1..<0.2:
                        self.analysisStatus = "Preparing audio data..."
                    case 0.2..<0.3:
                        self.analysisStatus = "Extracting audio features..."
                    case 0.3..<0.7:
                        self.analysisStatus = "Analyzing pitch and harmony..."
                    case 0.7..<0.9:
                        self.analysisStatus = "Detecting chord progressions..."
                    case 0.9..<1.0:
                        self.analysisStatus = "Estimating key signature..."
                    default:
                        self.analysisStatus = "Finalizing analysis..."
                    }
                }
            }
            
            await MainActor.run {
                self.chordDetections = result.detections
                self.estimatedKey = result.estimatedKey
                self.duration = result.duration
                self.isAnalyzing = false
                self.analysisStatus = "Analysis complete"
                
// increment stats
                let songsAnalysed = UserDefaults.standard.integer(forKey: "songsAnalysed")
                UserDefaults.standard.set(songsAnalysed + 1, forKey: "songsAnalysed")
                
                let uniqueChords = Set(result.detections.map { $0.chordName }).count
                let currentChords = UserDefaults.standard.integer(forKey: "chordsLearned")
                UserDefaults.standard.set(max(currentChords, uniqueChords), forKey: "chordsLearned")
                
                print("Found \(result.detections.count) chord segments")
                for detection in result.detections.prefix(5) {
                    print("  \(detection.startTime)s - \(detection.endTime)s: \(detection.chordName) (\(detection.confidence))")
                }
            }
            
        } catch {
            await MainActor.run {
                self.analysisStatus = "Analysis failed: \(error.localizedDescription)"
                self.isAnalyzing = false
            }
        }
    }
    
// get the chord playing at a specific time
    func getChordAt(time: Double) -> String? {
        for detection in chordDetections {
            if time >= detection.startTime && time < detection.endTime {
                return detection.chordName
            }
        }
        return nil
    }
    
// reset all analysis data
    func reset() {
        chordDetections = []
        estimatedKey = "—"
        duration = 0
        analysisProgress = 0
        analysisStatus = ""
    }
}
