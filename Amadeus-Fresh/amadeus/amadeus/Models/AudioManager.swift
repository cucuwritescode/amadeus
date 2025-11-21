import Foundation
import AudioKit
import AVFoundation

class AudioManager: ObservableObject {
    private var engine: AudioEngine
    private var player: AudioPlayer?
    private var variSpeed: VariSpeed?
    private var timePitch: TimePitch?
    
    @Published var isPlaying = false
    @Published var isFileLoaded = false
    @Published var statusMessage = "No file loaded"
    @Published var currentChord = "—"
    @Published var currentKey = "C major"
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var playbackSpeed: Float = 1.0 {
        didSet { updateSpeed() }
    }
    @Published var pitchShift: Int = 0 {
        didSet { updatePitch() }
    }
    
    // Analysis
    let analysisManager = AnalysisManager()
    private var playbackTimer: Timer?
    
    init() {
        engine = AudioEngine()
    }
    
    func loadFile(_ url: URL) {
        do {
            // Check if it's a bundle resource or external file
            let needsSecurityScope = !url.path.contains(Bundle.main.bundlePath)
            
            if needsSecurityScope {
                guard url.startAccessingSecurityScopedResource() else {
                    statusMessage = "Permission denied"
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
            }
            
            let audioFile = try AVAudioFile(forReading: url)
            
            player = AudioPlayer(file: audioFile)
            variSpeed = VariSpeed(player!)
            timePitch = TimePitch(variSpeed!)
            
            engine.output = timePitch
            
            try engine.start()
            
            // Get duration
            duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            
            isFileLoaded = true
            statusMessage = "File loaded: \(url.lastPathComponent)"
            
            // Start analysis
            Task {
                await analysisManager.analyzeAudioFile(url)
                await MainActor.run {
                    self.currentKey = analysisManager.estimatedKey
                }
            }
            
            // Start playback time tracking
            startPlaybackTimer()
            
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        currentTime = 0
        currentChord = "—"
    }
    
    func seek(to time: Double) {
        player?.seek(time: time)
        currentTime = time
    }
    
    private func updateSpeed() {
        // VariSpeed changes both speed AND pitch together
        // We need to compensate with opposite pitch shift
        variSpeed?.rate = AUValue(playbackSpeed)
        
        // Compensate pitch change from speed
        // When speed = 0.5 (octave down), we need +1200 cents (octave up)
        // When speed = 2.0 (octave up), we need -1200 cents (octave down)
        let pitchCompensation = -1200.0 * log2(playbackSpeed)
        timePitch?.pitch = AUValue(pitchCompensation + Float(pitchShift * 100))
    }
    
    private func updatePitch() {
        // Apply pitch shift while maintaining speed compensation
        let pitchCompensation = -1200.0 * log2(playbackSpeed)
        timePitch?.pitch = AUValue(pitchCompensation + Float(pitchShift * 100))
        
        if pitchShift == 0 {
            currentKey = "C major"
        } else {
            currentKey = "C major → \(transposeKey(semitones: pitchShift))"
        }
    }
    
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if self.isPlaying, let player = self.player {
                self.currentTime = player.currentTime
                
                // Update current chord from analysis
                if let chord = self.analysisManager.getChordAt(time: self.currentTime) {
                    self.currentChord = chord
                }
                
                // Loop at end
                if self.currentTime >= self.duration {
                    self.stop()
                }
            }
        }
    }
    
    private func transposeKey(semitones: Int) -> String {
        let keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let newIndex = (0 + semitones + 12) % 12
        return "\(keys[newIndex]) major"
    }
    
    deinit {
        engine.stop()
        playbackTimer?.invalidate()
    }
}


