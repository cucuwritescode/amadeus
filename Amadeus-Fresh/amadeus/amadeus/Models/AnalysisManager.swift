import Foundation
import AVFoundation
import AudioKit

class AnalysisManager: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisProgress: Float = 0
    @Published var analysisStatus = ""
    @Published var chordDetections: [ChordDetection] = []
    @Published var estimatedKey = "—"
    @Published var duration: Double = 0
    
    private let pipeline = ChordDetectionPipeline()
    
    func analyzeAudioFile(_ url: URL) async {
        await MainActor.run {
            self.isAnalyzing = true
            self.analysisStatus = "Loading audio file..."
            self.analysisProgress = 0
        }
        
        do {
            let result = try await pipeline.analyzeFile(url) { progress in
                Task { @MainActor in
                    self.analysisProgress = progress
                    
                    // Update status based on progress
                    switch progress {
                    case 0..<0.2:
                        self.analysisStatus = "Loading audio..."
                    case 0.2..<0.3:
                        self.analysisStatus = "Extracting audio data..."
                    case 0.3..<0.8:
                        self.analysisStatus = "Detecting chords..."
                    case 0.8..<1.0:
                        self.analysisStatus = "Analyzing key..."
                    default:
                        self.analysisStatus = "Finalizing..."
                    }
                }
            }
            
            await MainActor.run {
                self.chordDetections = result.detections
                self.estimatedKey = result.estimatedKey
                self.duration = result.duration
                self.isAnalyzing = false
                self.analysisStatus = "Analysis complete"
                
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
    
    func getChordAt(time: Double) -> String? {
        for detection in chordDetections {
            if time >= detection.startTime && time < detection.endTime {
                return detection.chordName
            }
        }
        return nil
    }
    
    func reset() {
        chordDetections = []
        estimatedKey = "—"
        duration = 0
        analysisProgress = 0
        analysisStatus = ""
    }
}