import Foundation
import AVFoundation
//created by Facundo Franchino
//  handles audio recording functionality
class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession?
    
    @Published var isRecording = false
    @Published var recordingURL: URL?
    @Published var recordingTime: TimeInterval = 0
    @Published var hasRecording = false
    
    private var recordingTimer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default)
            try audioSession?.setActive(true)
            
            //  request recording permission
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { allowed in
                    if !allowed {
                        print("Recording permission denied")
                    }
                }
            } else {
                audioSession?.requestRecordPermission { allowed in
                    if !allowed {
                        print("Recording permission denied")
                    }
                }
            }
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // start recording audio
    func startRecording() {
        // create unique file name in temp directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording_\(Date().timeIntervalSince1970).wav"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // configure recording settings for wav format
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            
            // start rec
            audioRecorder?.record()
            isRecording = true
            hasRecording = false
            recordingURL = fileURL
            recordingTime = 0
            
            // start timer to track rec duration
            recordingTimer?.invalidate()
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.recordingTime = self?.audioRecorder?.currentTime ?? 0
                
                // limit recording to 30 seconds for performance
                if (self?.recordingTime ?? 0) >= 30 {
                    self?.stopRecording()
                }
            }
            
            print("Started recording to: \(fileURL.lastPathComponent)")
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    // stop rec and save file
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        hasRecording = true
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        if let url = recordingURL {
            print("Stopped recording. File saved to: \(url.lastPathComponent)")
            print("   Duration: \(recordingTime) seconds")
        }
    }
    
    //delete the recorded file
    func deleteRecording() {
        guard let url = recordingURL else { return }
        
        //stop rec if still active
        if isRecording {
            stopRecording()
        }
        
        do {
            try FileManager.default.removeItem(at: url)
            recordingURL = nil
            hasRecording = false
            recordingTime = 0
            audioRecorder = nil
            print("recording deleted")
        } catch {
            print("failed to delete recording: \(error)")
        }
    }
    
    //reset state for new rec
    func resetForNewRecording() {
        if isRecording {
            stopRecording()
        }
        
        //clean up previous rec
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        recordingURL = nil
        hasRecording = false
        recordingTime = 0
        audioRecorder = nil
        
        //reset audio session
        setupAudioSession()
    }
    
    // get url of recorded file
    func getRecordingURL() -> URL? {
        return recordingURL
    }
}

//  MARK: - avaudiorecorderdelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
        } else {
            print("Recording failed")
            hasRecording = false
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Recording encode error: \(error)")
        }
    }
}
