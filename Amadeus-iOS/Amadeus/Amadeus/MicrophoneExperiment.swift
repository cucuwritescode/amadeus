//
//  MicrophoneExperiment.swift
//  amadeus - iOS learning experiment number one
//
//  Created by Cucu on 18/08/2025.
//
//  this file tackles basic microphone input with AudioKit
//
//

// MARK: - Import statements
import SwiftUI
import AudioKit
import AVFoundation // apple's audio/video foundation low-level audio system access

// MARK: - The Microphone Monitor Class
// this class handles all the microphone logic
// @ObservableObject means SwiftUI will watch this and update the UI when values change
class MicrophoneMonitor: ObservableObject {
    
    // MARK: - Audio Engine Setup
    // think of AudioEngine as the "brain" that processes audio
    let engine = AudioEngine()
    
    // these will hold our audio processing components
    var mic: AudioEngine.InputNode?    // microphone input (optional until engine starts)
    var mixer: Mixer?                  // audio mixer (set it to 0 to avoid feedback)
    
    // MARK: - Published Properties
    // @Published means "tell the UI when these change"
    @Published var amplitude: Float = 0.0      // how loud the audio is (0 = silent, 1 = very loud)
    @Published var isRecording = false         // are we currently listening...?
    
    // this monitorx the audio levels
    var amplitudeTap: AmplitudeTap?
    
    // MARK: - Initialiser (Constructor)
    // this runs when we create a new MicrophoneMonitor
    init() {
        
        // first step is to configure the audio session
        // this tells iOS "we want to record and play audio"
        do {
            // .playAndRecord=we can both listen and speak
            // .defaultToSpeaker= send audio to the main speaker (not earpiece)
            try Settings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        } catch {
            // If something goes wrong, print an error message
            print("Couldn't set up audio session: \(error)")
        }
        
        // we'll set up the audio chain when start() is called
        // the engine needs to be started before we can access input
    }
    
    // MARK: - Start Recording
    // call this to begin listening to the microphone
    func start() {
        do {
            // first step is to get the microphone input (before starting engine)
            guard let input = engine.input else {
                print("No microphone input available")
                return
            }
            mic = input
            
            // second step is to set up the mixer
            mixer = Mixer(input)
            mixer?.volume = 0.0  // silent to prevent feedback
            
            // step three is to connect to engine output (MUST do this before starting)
            engine.output = mixer
            
            // step four; NOW we can start the audio engine
            try engine.start()
            
            // set up amplitude monitoring
            amplitudeTap = AmplitudeTap(input) { [weak self] amplitude in
                DispatchQueue.main.async {
                    self?.amplitude = amplitude
                }
            }
            
            // start monitoring levels
            amplitudeTap?.start()
            
            // tell the UI we're now recording
            isRecording = true
            
        } catch {
            print("Couldn't start audio engine: \(error)")
        }
    }
    
    // MARK: - Stop Recording
    // call this to stop listening
    func stop() {
        // stop monitoring levels
        amplitudeTap?.stop()
        
        // stop the audio engine
        engine.stop()
        
        // tell the UI we've stopped
        isRecording = false
    }
}

// MARK: - The User Interface
// this creates the visual interface that users see
struct MicrophoneExperimentView: View {
    
    // @StateObject creates and owns our MicrophoneMonitor
    // the UI will automatically update when the mic data changes
    @StateObject private var mic = MicrophoneMonitor()
    
    // the body property defines what appears on screen
    var body: some View {
        
        // VStack = vertical stack (things arranged top to bottom)
        VStack(spacing: 20) {
            
            // TITLE
            Text("🎤 Microphone Test")
                .font(.largeTitle)           // big text
                .padding()                   // add space around it
            
            // AMPLITUDE DISPLAY
            // shows the current volume level as a number
            Text("Volume: \(mic.amplitude, specifier: "%.3f")")
                .font(.title2)
                .foregroundColor(mic.amplitude > 0.5 ? .red : .primary)
            
            // VISUAL LEVEL METER
            // a bar that responds dynamically to audio levels
            GeometryReader { geometry in
                // GeometryReader lets us know how much space we have
                
                ZStack(alignment: .leading) {
                    // ZStack = things stacked on top of each other
                    // alignment: .leading = align to the left
                    
                    // background bar (grey)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    
                    // level bar that changes color based on volume
                    Rectangle()
                        .fill(mic.amplitude > 0.7 ? Color.red :      // very loud = red
                              mic.amplitude > 0.4 ? Color.yellow :   // medium = yellow
                              Color.green)                           // quiet = green
                        .frame(width: geometry.size.width * CGFloat(min(mic.amplitude, 1.0)))
                        // width depends on the amplitude (but never more than 100%)
                }
            }
            .frame(height: 50)              // make the meter 50 points tall
            .padding(.horizontal)           // add padding on left and right
            
            // START/STOP BUTTON
            Button(action: {
                // this code runs when the button is tapped
                if mic.isRecording {
                    mic.stop()              // if we're recording, stop
                } else {
                    mic.start()             // if we're not recording, start
                }
            }) {
                // this defines how the button looks
                Text(mic.isRecording ? "Stop" : "Start")
                    .font(.title)
                    .padding()
                    .background(mic.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)       // rounded corners
            }
            
            // STATUS INDICATOR
            if mic.isRecording {
                Text("🎤 Listening...")
                    .foregroundColor(.red)
                    .font(.headline)
            } else {
                Text("Tap Start to begin")
                    .foregroundColor(.gray)
            }
            
            // HELP TEXT
            Text("This experiment shows basic microphone input.\nSpeak or play music to see the level meter respond!")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
        }
        .padding()                          // add padding around everything
    }
}

// MARK: - Preview
// this lets you see the UI in Xcode's preview window
#Preview {
    MicrophoneExperimentView()
}
