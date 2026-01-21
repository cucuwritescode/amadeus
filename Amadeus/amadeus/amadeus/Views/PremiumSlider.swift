//
//  PremiumSlider.swift
//  amadeus
//
//  created by facundo franchino on 28/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  custom slider component with animated thumb and progress track
//  provides enhanced visual feedback during user interaction
//
//  acknowledgements:
//  - haptic feedback patterns based on ios guidelines
//  - gradient styling inspired by modern ios app designs
//

import SwiftUI

// MARK: - Premium Slider

//custom animated slider with visual feedback for speed and pitch controls
//provides gradient track, animated thumb, and haptic feedback on interaction
struct PremiumSlider: View {
    //two-way binding to the slider's current value
    @Binding var value: Double

    //allowable value range for the slider
    let range: ClosedRange<Double>

    //step increment for snapping values (0 for continuous)
    let step: Double

    //colour used for the filled track portion
    let trackColor: Color

    //colour used for the thumb circle
    let thumbColor: Color

    //tracks whether user is currently dragging the slider
    @State private var isDragging = false

    //scale factor for thumb animation during drag
    @State private var thumbScale: CGFloat = 1.0

    //track progress (0-1) for animation (calculated from value)
    @State private var trackProgress: CGFloat = 0.0

    //custom initialiser with default colours
    init(value: Binding<Double>,
         range: ClosedRange<Double>,
         step: Double = 1.0,
         trackColor: Color = .blue,
         thumbColor: Color = .blue) {
        self._value = value
        self.range = range
        self.step = step
        self.trackColor = trackColor
        self.thumbColor = thumbColor
    }

    //converts value to 0-1 range for positioning
    private var normalizedValue: CGFloat {
        let normalized = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
        return max(0, min(1, normalized))
    }

    var body: some View {
        GeometryReader { geometry in
            //calculate dimensions based on available width
            let trackWidth = geometry.size.width
            let thumbPosition = normalizedValue * trackWidth

            ZStack(alignment: .leading) {
                //background track (full width, faded)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                //active track showing filled portion with gradient
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [trackColor.opacity(0.8), trackColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: thumbPosition, height: 8)
                    .animation(.easeOut(duration: 0.2), value: normalizedValue)

                //circular thumb with radial gradient and shadow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [thumbColor, thumbColor.opacity(0.8)],
                            center: .center,
                            startRadius: 2,
                            endRadius: 12
                        )
                    )
                    .frame(width: 24, height: 24)
                    .scaleEffect(thumbScale)
                    //shadow expands when dragging
                    .shadow(
                        color: thumbColor.opacity(0.3),
                        radius: isDragging ? 8 : 4,
                        y: isDragging ? 4 : 2
                    )
                    .position(x: thumbPosition, y: geometry.size.height / 2)
                    .animation(.bouncy(duration: 0.3), value: thumbScale)

                //invisible overlay for expanded touch target
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { dragValue in
                                //start drag state on first move
                                if !isDragging {
                                    isDragging = true
                                    //scale up thumb with bounce
                                    withAnimation(.bouncy(duration: 0.2)) {
                                        thumbScale = 1.3
                                    }
                                    //initial haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }

                                //calculate new value from drag position
                                let dragRatio = dragValue.location.x / trackWidth
                                let clampedRatio = max(0, min(1, dragRatio))
                                let newValue = range.lowerBound + clampedRatio * (range.upperBound - range.lowerBound)

                                //apply step snapping if step > 0
                                let steppedValue = step > 0 ? round(newValue / step) * step : newValue
                                let finalValue = max(range.lowerBound, min(range.upperBound, steppedValue))

                                //only update if value changed (avoids redundant haptics)
                                if finalValue != value {
                                    value = finalValue
                                    //selection haptic on value snap
                                    let selectionFeedback = UISelectionFeedbackGenerator()
                                    selectionFeedback.selectionChanged()
                                }
                            }
                            .onEnded { _ in
                                //end drag state
                                isDragging = false
                                //return thumb to normal size
                                withAnimation(.bouncy(duration: 0.3)) {
                                    thumbScale = 1.0
                                }
                                //final haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                    )
            }
        }
        //larger touch target height for accessibility
        .frame(height: 44)
    }
}

#Preview {
    VStack(spacing: 40) {
        VStack {
            Text("Speed: 1.2x")
                .font(.headline)
            
            PremiumSlider(
                value: .constant(1.2),
                range: 0.5...1.5,
                step: 0.1,
                trackColor: .blue,
                thumbColor: .blue
            )
        }
        
        VStack {
            Text("Transpose: +3")
                .font(.headline)
            
            PremiumSlider(
                value: .constant(3),
                range: -12...12,
                step: 1,
                trackColor: .purple,
                thumbColor: .purple
            )
        }
    }
    .padding()
}
