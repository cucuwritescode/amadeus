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
    @State private var speedScale: CGFloat = 1.0
    @State private var transposeScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HStack {
                    Image(systemName: "speedometer")
                    Text("Speed: \(String(format: "%.1fx", audioManager.playbackSpeed))")
                    Spacer()
                }
                .font(.headline)
                .scaleEffect(speedScale)
                .animation(.bouncy(duration: 0.3), value: speedScale)
                
                PremiumSlider(
                    value: Binding(
                        get: { Double(audioManager.playbackSpeed) },
                        set: { newValue in
                            audioManager.playbackSpeed = Float(newValue)
                            // Trigger animation on change
                            speedScale = 1.1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                speedScale = 1.0
                            }
                        }
                    ),
                    range: 0.5...1.5,
                    step: 0.1,
                    trackColor: .blue,
                    thumbColor: .blue
                )
                
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
                .scaleEffect(transposeScale)
                .animation(.bouncy(duration: 0.3), value: transposeScale)
                
                PremiumSlider(
                    value: Binding(
                        get: { Double(audioManager.pitchShift) },
                        set: { newValue in
                            audioManager.pitchShift = Int(newValue)
                            // Trigger animation on change
                            transposeScale = 1.1
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                transposeScale = 1.0
                            }
                        }
                    ),
                    range: -12...12,
                    step: 1,
                    trackColor: .purple,
                    thumbColor: .purple
                )
                
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