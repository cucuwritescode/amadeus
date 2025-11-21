import SwiftUI

struct PlaybackView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: audioManager.stop) {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                if audioManager.isPlaying {
                    audioManager.pause()
                } else {
                    audioManager.play()
                }
            }) {
                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

struct ChordDisplayView: View {
    let currentChord: String
    
    var body: some View {
        VStack {
            Text("Current Chord")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(currentChord)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ControlsView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Image(systemName: "speedometer")
                    Text("Speed: \(String(format: "%.1fx", audioManager.playbackSpeed))")
                    Spacer()
                }
                .font(.headline)
                
                Slider(value: $audioManager.playbackSpeed, in: 0.5...1.5, step: 0.1)
                
                HStack {
                    Text("0.5x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.0x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.5x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            
            VStack {
                HStack {
                    Image(systemName: "music.note")
                    Text("Transpose: \(audioManager.pitchShift > 0 ? "+" : "")\(audioManager.pitchShift)")
                    Spacer()
                }
                .font(.headline)
                
                Slider(value: Binding(
                    get: { Double(audioManager.pitchShift) },
                    set: { audioManager.pitchShift = Int($0) }
                ), in: -12...12, step: 1)
                
                HStack {
                    Text("-12")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("+12")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            
            Text("Key: \(audioManager.currentKey)")
                .font(.headline)
                .padding()
        }
        .padding(.horizontal)
    }
}