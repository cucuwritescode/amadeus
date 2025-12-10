import SwiftUI

struct AnalysisLoadingView: View {
    let title: String
    let subtitle: String
    
    @State private var rotation: Double = 0
    @State private var dotScale: [Double] = [1.0, 1.0, 1.0, 1.0]
    @State private var currentDot = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Animated orbiting dots
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 120, height: 120)
                    .opacity(0.3)
                
                // Orbiting dots
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(gradientForDot(index))
                        .frame(width: 12, height: 12)
                        .scaleEffect(dotScale[index])
                        .position(
                            x: 60 + 50 * cos(rotation + Double(index) * .pi / 2),
                            y: 60 + 50 * sin(rotation + Double(index) * .pi / 2)
                        )
                }
            }
            .frame(width: 120, height: 120)
            .onAppear {
                startAnimation()
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func gradientForDot(_ index: Int) -> LinearGradient {
        let colors: [[Color]] = [
            [.purple, .pink],
            [.blue, .cyan],
            [.green, .mint],
            [.orange, .yellow]
        ]
        
        return LinearGradient(
            colors: colors[index],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func startAnimation() {
        // Continuous rotation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotation = 2 * .pi
        }
        
        // Pulsing dots
        animateDots()
    }
    
    private func animateDots() {
        let duration: Double = 0.6
        
        withAnimation(.easeInOut(duration: duration)) {
            dotScale[currentDot] = 1.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: duration / 2)) {
                dotScale[currentDot] = 1.0
            }
            
            currentDot = (currentDot + 1) % 4
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateDots()
            }
        }
    }
}

#Preview {
    AnalysisLoadingView(
        title: "Analyzing Audio",
        subtitle: "Detecting chords and musical structure..."
    )
}