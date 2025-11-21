import SwiftUI

struct ChordTimelineView: View {
    let detections: [ChordDetection]
    let currentTime: Double
    let duration: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                // Chord segments
                ForEach(Array(detections.enumerated()), id: \.offset) { _, detection in
                    ChordSegmentView(
                        detection: detection,
                        totalDuration: duration,
                        totalWidth: geometry.size.width,
                        isActive: currentTime >= detection.startTime && currentTime < detection.endTime
                    )
                }
                
                // Playhead
                if duration > 0 {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .offset(x: (currentTime / duration) * geometry.size.width)
                }
                
                // Time labels
                HStack {
                    Text(formatTime(0))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    if duration > 0 {
                        Text(formatTime(duration))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
        }
        .frame(height: 80)
    }
    
    func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct ChordSegmentView: View {
    let detection: ChordDetection
    let totalDuration: Double
    let totalWidth: CGFloat
    let isActive: Bool
    
    var xPosition: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return (detection.startTime / totalDuration) * totalWidth
    }
    
    var segmentWidth: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return ((detection.endTime - detection.startTime) / totalDuration) * totalWidth
    }
    
    var confidenceOpacity: Double {
        Double(detection.confidence)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Chord name
            Text(detection.chordName)
                .font(.system(size: 14, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive ? .white : .primary)
            
            // Confidence bar
            Rectangle()
                .fill(Color.green.opacity(confidenceOpacity))
                .frame(height: 3)
        }
        .frame(width: max(segmentWidth - 2, 20))
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isActive ? Color.blue : Color.blue.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                )
        )
        .offset(x: xPosition)
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

// Analysis Progress View
struct AnalysisProgressView: View {
    let status: String
    let progress: Float
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text(status)
                .font(.headline)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 200)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}