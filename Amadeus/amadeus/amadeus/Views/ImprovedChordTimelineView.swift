import SwiftUI

struct ImprovedChordTimelineView: View {
    let detections: [ChordDetection]
    let currentTime: Double
    let duration: Double
    var transposeSemitones: Int = 0
    @State private var selectedChord: ChordDetection? = nil
    @State private var dragLocation: CGPoint = .zero
    
    // Callback for tap-to-seek
    var onSeek: ((Double) -> Void)?
    
    // Transpose chord helper
    private func transposeChord(_ chord: String, semitones: Int) -> String {
        guard semitones != 0 else { return chord }
        
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let altNotes = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        
        // Handle common chord formats
        var rootNote = ""
        var suffix = ""
        
        if chord.count >= 2 && (chord.dropFirst().first == "#" || chord.dropFirst().first == "b") {
            rootNote = String(chord.prefix(2))
            suffix = String(chord.dropFirst(2))
        } else if chord.count >= 1 {
            rootNote = String(chord.prefix(1))
            suffix = String(chord.dropFirst(1))
        } else {
            return chord
        }
        
        let currentIndex = notes.firstIndex(of: rootNote) ?? altNotes.firstIndex(of: rootNote) ?? 0
        let newIndex = (currentIndex + semitones + 12) % 12
        let newRoot = notes[newIndex]
        
        return "\(newRoot)\(suffix)"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background with grid lines
                TimelineBackground(duration: duration)
                
                // Scrollable chord lane
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(detections.enumerated()), id: \.offset) { index, detection in
                            ImprovedChordSegment(
                                chordName: transposeChord(detection.chordName, semitones: transposeSemitones),
                                detection: detection,
                                totalDuration: duration,
                                isActive: currentTime >= detection.startTime && currentTime < detection.endTime,
                                minWidth: 60 // Minimum width to ensure readability
                            )
                            .onTapGesture {
                                // Just seek to the start of this chord, no popup
                                onSeek?(detection.startTime)
                            }
                        }
                    }
                    .frame(height: 60)
                }
                
                // Playhead indicator - positioned relative to the scroll content
                PlayheadIndicator(
                    currentTime: currentTime,
                    duration: duration,
                    totalScrollWidth: CGFloat(detections.count) * 60 // Match the scroll content width
                )
                
                // Time ruler at the bottom
                TimeRuler(duration: duration, width: geometry.size.width)
                    .frame(height: 20)
                    .offset(y: 60)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onEnded { value in
                        // Calculate time from final drag position
                        guard duration > 0 else { return }
                        let tapX = max(0, min(geometry.size.width, value.location.x))
                        let timeRatio = tapX / geometry.size.width
                        let seekTime = timeRatio * duration
                        print("🎯 Timeline drag seek: x=\(tapX), width=\(geometry.size.width), time=\(seekTime)")
                        onSeek?(seekTime)
                    }
            )
        }
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Timeline Background
struct TimelineBackground: View {
    let duration: Double
    
    var body: some View {
        GeometryReader { geometry in
            // Vertical grid lines at regular intervals
            ForEach(0..<Int(duration / 10) + 1, id: \.self) { index in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1)
                    .offset(x: CGFloat(index) * (geometry.size.width / CGFloat(duration / 10)))
            }
        }
    }
}

// MARK: - Improved Chord Segment
struct ImprovedChordSegment: View {
    let chordName: String  // Display name (potentially transposed)
    let detection: ChordDetection  // Original detection data
    let totalDuration: Double
    let isActive: Bool
    let minWidth: CGFloat
    
    private var segmentWidth: CGFloat {
        let durationRatio = (detection.endTime - detection.startTime) / totalDuration
        return max(durationRatio * 1000, minWidth) // Scale for scrollable view
    }
    
    private var backgroundColor: Color {
        if isActive {
            return Color.blue
        } else {
            return Color.blue.opacity(0.3 + Double(detection.confidence) * 0.3)
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Chord name (use the potentially transposed name)
            Text(chordName)
                .font(.system(size: 16, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive ? .white : Color(UIColor.label))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(width: segmentWidth, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.white : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - Playhead Indicator
struct PlayheadIndicator: View {
    let currentTime: Double
    let duration: Double
    let totalScrollWidth: CGFloat
    
    private var xPosition: CGFloat {
        guard duration > 0 else { return 0 }
        return (currentTime / duration) * totalScrollWidth
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.red)
            .frame(width: 3, height: 80)
            .overlay(
                // Playhead handle
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .offset(y: -40)
            )
            .offset(x: xPosition)
            .animation(.linear(duration: 0.3), value: xPosition)
    }
}

// MARK: - Time Ruler
struct TimeRuler: View {
    let duration: Double
    let width: CGFloat
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    var body: some View {
        HStack {
            Text(formatTime(0))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if duration > 30 {
                Text(formatTime(duration / 2))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Text(formatTime(duration))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Chord Tooltip
struct ChordTooltip: View {
    let detection: ChordDetection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(detection.chordName)
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                Text("Duration:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1fs", detection.endTime - detection.startTime))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 4)
        )
        .offset(y: -100)
        .transition(.scale.combined(with: .opacity))
    }
}