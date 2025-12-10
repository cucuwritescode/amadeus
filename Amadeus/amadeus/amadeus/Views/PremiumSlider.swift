import SwiftUI

struct PremiumSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let trackColor: Color
    let thumbColor: Color
    
    @State private var isDragging = false
    @State private var thumbScale: CGFloat = 1.0
    @State private var trackProgress: CGFloat = 0.0
    
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
    
    private var normalizedValue: CGFloat {
        let normalized = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
        return max(0, min(1, normalized))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let thumbPosition = normalizedValue * trackWidth
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                // Active track (filled portion)
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
                
                // Thumb
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
                    .shadow(
                        color: thumbColor.opacity(0.3),
                        radius: isDragging ? 8 : 4,
                        y: isDragging ? 4 : 2
                    )
                    .position(x: thumbPosition, y: geometry.size.height / 2)
                    .animation(.bouncy(duration: 0.3), value: thumbScale)
                
                // Invisible drag area for better touch targets
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { dragValue in
                                if !isDragging {
                                    isDragging = true
                                    withAnimation(.bouncy(duration: 0.2)) {
                                        thumbScale = 1.3
                                    }
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                                
                                let dragRatio = dragValue.location.x / trackWidth
                                let clampedRatio = max(0, min(1, dragRatio))
                                let newValue = range.lowerBound + clampedRatio * (range.upperBound - range.lowerBound)
                                
                                // Apply step if specified
                                let steppedValue = step > 0 ? round(newValue / step) * step : newValue
                                let finalValue = max(range.lowerBound, min(range.upperBound, steppedValue))
                                
                                if finalValue != value {
                                    value = finalValue
                                    // Haptic feedback on value change
                                    let selectionFeedback = UISelectionFeedbackGenerator()
                                    selectionFeedback.selectionChanged()
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                                withAnimation(.bouncy(duration: 0.3)) {
                                    thumbScale = 1.0
                                }
                                // End haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                    )
            }
        }
        .frame(height: 44) // Larger touch target
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