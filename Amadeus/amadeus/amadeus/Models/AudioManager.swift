import Foundation
import AudioKit
import AVFoundation

// manages audio playback, processing and analysis for the application
class AudioManager: ObservableObject {
// audiokit engine for audio processing
    private var engine: AudioEngine
//audio player instance for file playback
    private var player: AudioPlayer?
// variable speed processor for tempo adjustment
    private var variSpeed: VariSpeed?
// pitch shifting processor for transposition
    private var timePitch: TimePitch?
    
//playback state tracking
    @Published var isPlaying = false
// indicates whether an audio file is currently loaded
    @Published var isFileLoaded = false
// status message for user feedback
    @Published var statusMessage = "No file loaded"
// current chord being played at the current playback position
    @Published var currentChord = "—"
//original key of the loaded audio file
    @Published var originalKey = "C major"
// current key after pitch transposition
    @Published var currentKey = "C major"
//current playback position in seconds
    @Published var currentTime: Double = 0
// total duration of the loaded audio file
    @Published var duration: Double = 0
// shows loading indicator during analysis
    @Published var showAnalysisLoading = false
//shows completion message after analysis
    @Published var showAnalysisComplete = false
// playback speed multiplier with automatic update
    @Published var playbackSpeed: Float = 1.0 {
        didSet { updateSpeed() }
    }
// pitch transposition in semitones with automatic update
    @Published var pitchShift: Int = 0 {
        didSet { updatePitch() }
    }
    
// manages chord and key analysis
    let analysisManager = AnalysisManager()
// timer for tracking playback position
    private var playbackTimer: Timer?
    
// initialise audio manager with fresh engine
    init() {
        engine = AudioEngine()
    }
    
// load and prepare an audio file for playback and analysis
    func loadFile(_ url: URL) {
        print("Loading audio file: \(url.lastPathComponent)")
        
        do {
//stop current engine and reset completely
            engine.stop()
            
//reset audio session to ensure proper volume levels
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .default, options: [])
                try audioSession.setActive(true)
            } catch {
                print("AudioSession setup warning: \(error)")
            }
            
// files from documentpicker are already copied to temp directory
// bundle resources don't need security scope
            let isTempFile = url.path.contains(FileManager.default.temporaryDirectory.path)
            let isBundleFile = url.path.contains(Bundle.main.bundlePath)
            
            print("  • File path: \(url.path)")
            print("  • Is temp file: \(isTempFile)")
            print("  • Is bundle file: \(isBundleFile)")
            
// validate file exists and is readable
            guard FileManager.default.fileExists(atPath: url.path) else {
                statusMessage = "File not found"
                print("File not found: \(url.path)")
                return
            }
            
// try to create avaudiofile with better error handling
            let audioFile: AVAudioFile
            do {
                audioFile = try AVAudioFile(forReading: url)
                print("Audio file opened successfully")
                print("  • Format: \(audioFile.fileFormat)")
                print("  • Duration: \(Double(audioFile.length) / audioFile.fileFormat.sampleRate) seconds")
            } catch let avError as NSError {
                let errorMessage = "Cannot read audio file (Error \(avError.code))"
                statusMessage = errorMessage
                print("AVAudioFile error: \(avError.localizedDescription)")
                print("   Domain: \(avError.domain), Code: \(avError.code)")
                return
            }
            
// validate audio format
            guard audioFile.length > 0 else {
                statusMessage = "Audio file is empty"
                print("Audio file is empty")
                return
            }
            
// create fresh audio chain
            player = AudioPlayer(file: audioFile)
            variSpeed = VariSpeed(player!)
            timePitch = TimePitch(variSpeed!)
            
            engine.output = timePitch
            
// start engine
            try engine.start()
            print("AudioKit engine started")
            
//get duration
            duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            
            isFileLoaded = true
            statusMessage = "File loaded: \(url.lastPathComponent)"
            
// reset controls when loading new file
            pitchShift = 0
            playbackSpeed = 1.0
            
//show loading animation and start analysis
            showAnalysisLoading = true
            
            Task {
                await analysisManager.analyzeAudioFile(url)
                await MainActor.run {
                    self.originalKey = analysisManager.estimatedKey
                    self.currentKey = self.transposeKey(analysisManager.estimatedKey, semitones: self.pitchShift)
                    
// hide loading and show completion
                    self.showAnalysisLoading = false
                    self.showAnalysisComplete = true
                    
// auto-hide completion after a moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.showAnalysisComplete = false
                    }
                    
                    print("Analysis complete. Ready for playback.")
                }
            }
            
// start playback time tracking
            startPlaybackTimer()
            
        } catch {
            let errorMessage = "Error loading audio: \(error.localizedDescription)"
            statusMessage = errorMessage
            print("Audio loading failed: \(error)")
        }
    }
    
// start audio playback
    func play() {
        player?.play()
        isPlaying = true
    }
    
// pause audio playback
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
// stop audio playback and reset position
    func stop() {
        player?.stop()
        isPlaying = false
        currentTime = 0
        currentChord = "—"
    }
    
    //stop and reset audio engine completely
    func stopEngine() {
        stop()
        engine.stop()
    }
    
//seek to specific position in the audio file
    func seek(to time: Double) {
        guard let player = player, duration > 0 else { return }
        
        let clampedTime = max(0, min(duration, time))
        print("SEEK: \(currentTime) -> \(clampedTime)")
        
//completely stop timer
        playbackTimer?.invalidate()
        playbackTimer = nil
        
//do the actual seek
        player.stop()
        player.seek(time: clampedTime)
        
// force update current time immediately
        currentTime = clampedTime
        
// restart playback if it was playing
        if isPlaying {
            player.play()
        }
        
// always restart the timer
        startPlaybackTimer()
    }
    
// update playback speed with pitch compensation
    private func updateSpeed() {
// varispeed changes both speed and pitch together
// we need to compensate with opposite pitch shift
        variSpeed?.rate = AUValue(playbackSpeed)
        
// compensate pitch change from speed
// when speed = 0.5 (octave down), we need +1200 cents (octave up)
// when speed = 2.0 (octave up), we need -1200 cents (octave down)
        let pitchCompensation = -1200.0 * log2(playbackSpeed)
        timePitch?.pitch = AUValue(pitchCompensation + Float(pitchShift * 100))
    }
    
//update pitch transposition
    private func updatePitch() {
// apply pitch shift while maintaining speed compensation
        let pitchCompensation = -1200.0 * log2(playbackSpeed)
        timePitch?.pitch = AUValue(pitchCompensation + Float(pitchShift * 100))
        
// update the transposed key
        currentKey = transposeKey(originalKey, semitones: pitchShift)
    }
    
// start timer for tracking playback position and updating current chord
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if self.isPlaying, let player = self.player {
                self.currentTime = player.currentTime
                
// update current chord from analysis and apply transposition
                if let chord = self.analysisManager.getChordAt(time: self.currentTime) {
                    if self.pitchShift != 0 {
                        self.currentChord = self.transposeChord(chord, semitones: self.pitchShift)
                    } else {
                        self.currentChord = chord
                    }
                }
                
// loop at end
                if self.currentTime >= self.duration {
                    self.stop()
                }
            }
        }
    }
    
// transpose a key by given semitones
    private func transposeKey(_ key: String, semitones: Int) -> String {
        guard semitones != 0 else { return key }
        
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let altNotes = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        
// parse the key (e.g., "c major" or "a minor")
        let components = key.split(separator: " ")
        guard components.count >= 1 else { return key }
        
        let rootNote = String(components[0])
        let quality = components.count > 1 ? String(components[1]) : ""
        
// find the index of the root note
        let currentIndex = notes.firstIndex(of: rootNote) ?? altNotes.firstIndex(of: rootNote) ?? 0
        
// transpose
        let newIndex = (currentIndex + semitones + 12) % 12
        let newRoot = notes[newIndex]
        
        return quality.isEmpty ? newRoot : "\(newRoot) \(quality)"
    }
    
// transpose a chord symbol by given semitones
    private func transposeChord(_ chord: String, semitones: Int) -> String {
        guard semitones != 0 else { return chord }
        
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let altNotes = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        
// handle common chord formats: c, cm, c7, cmaj7, etc.
        var rootNote = ""
        var suffix = ""
        
// try to extract root note (may be 1 or 2 characters)
        if chord.count >= 2 && (chord.dropFirst().first == "#" || chord.dropFirst().first == "b") {
            rootNote = String(chord.prefix(2))
            suffix = String(chord.dropFirst(2))
        } else if chord.count >= 1 {
            rootNote = String(chord.prefix(1))
            suffix = String(chord.dropFirst(1))
        } else {
            return chord
        }
        
// find the index of the root note
        let currentIndex = notes.firstIndex(of: rootNote) ?? altNotes.firstIndex(of: rootNote) ?? 0
        
// transpose
        let newIndex = (currentIndex + semitones + 12) % 12
        let newRoot = notes[newIndex]
        
        return "\(newRoot)\(suffix)"
    }
    
// clean up resources when audio manager is deallocated
    deinit {
        engine.stop()
        playbackTimer?.invalidate()
    }
}


