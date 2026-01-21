//
//  ChordTimelineView.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  visual timeline displaying detected chords with playhead indicator
//  shows chord segments, confidence levels, and time markers
//
//  acknowledgements:
//  - timeline visualisation inspired by daw track layouts
//  - playhead scrubbing follows standard media player conventions
//

import SwiftUI

// MARK: - Chord Timeline View

//displays chord detections as coloured segments on a horizontal timeline
//provides visual overview of chord progression with playback position indicator
struct ChordTimelineView: View {
    //array of detected chord segments with timing and confidence data
    let detections: [ChordDetection]

    //current playback position in seconds
    let currentTime: Double

    //total duration of the audio file in seconds
    let duration: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                //timeline background track
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                //chord segment blocks positioned along the timeline
                ForEach(Array(detections.enumerated()), id: \.offset) { _, detection in
                    ChordSegmentView(
                        detection: detection,
                        totalDuration: duration,
                        totalWidth: geometry.size.width,
                        //determine if this chord is currently playing
                        isActive: currentTime >= detection.startTime && currentTime < detection.endTime
                    )
                }

                //red playhead line showing current position
                if duration > 0 {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        //position based on time ratio
                        .offset(x: (currentTime / duration) * geometry.size.width)
                }

                //time labels at start and end of timeline
                HStack {
                    //start time (always 0:00)
                    Text(formatTime(0))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    //end time showing total duration
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

    //converts seconds to mm:ss display format
    func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Chord Segment View

//individual chord segment block within the timeline
//shows chord name and confidence indicator with active/inactive styling
struct ChordSegmentView: View {
    //chord detection data containing timing and name
    let detection: ChordDetection

    //total audio duration for calculating position ratios
    let totalDuration: Double

    //total available width for positioning calculations
    let totalWidth: CGFloat

    //indicates whether this chord is currently playing
    let isActive: Bool

    //calculates horizontal position of segment start
    var xPosition: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return (detection.startTime / totalDuration) * totalWidth
    }

    //calculates width of segment based on chord duration
    var segmentWidth: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return ((detection.endTime - detection.startTime) / totalDuration) * totalWidth
    }

    //maps confidence value to opacity for visual feedback
    var confidenceOpacity: Double {
        Double(detection.confidence)
    }

    var body: some View {
        VStack(spacing: 2) {
            //chord name label with bold styling when active
            Text(detection.chordName)
                .font(.system(size: 14, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive ? .white : .primary)

            //confidence indicator bar below chord name
            Rectangle()
                .fill(Color.green.opacity(confidenceOpacity))
                .frame(height: 3)
        }
        //ensure minimum width for readability, subtract 2 for gap between segments
        .frame(width: max(segmentWidth - 2, 20))
        .padding(.vertical, 4)
        //segment background with different fill for active state
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isActive ? Color.blue : Color.blue.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                )
        )
        //position segment at calculated x position
        .offset(x: xPosition)
        //smooth transition when active state changes
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

// MARK: - Analysis Progress View

//modal progress indicator shown during audio analysis
//displays status message, circular spinner, and progress bar
struct AnalysisProgressView: View {
    //human-readable status message describing current analysis phase
    let status: String

    //analysis progress from 0.0 to 1.0
    let progress: Float

    var body: some View {
        VStack(spacing: 12) {
            //circular loading spinner
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)

            //status message describing current phase
            Text(status)
                .font(.headline)
                .foregroundColor(.primary)

            //linear progress bar showing completion percentage
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(width: 200)

            //percentage text below progress bar
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(30)
        //card background with shadow and border
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
