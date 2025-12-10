import SwiftUI

struct AnalysisCompletionView: View {
    let title: String
    let subtitle: String
    let onComplete: () -> Void
    
    @State private var isCompleted = false
    @State private var checkmarkScale: Double = 0
    @State private var backgroundScale: Double = 0
    @State private var textOffset: Double = 30
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Animated success indicator
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(backgroundScale)
                
                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(checkmarkScale)
            }
            
            // Text content
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
            }
        }
        .padding(.horizontal, 40)
        .onAppear {
            animateCompletion()
        }
    }
    
    private func animateCompletion() {
        // Background circle animation
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundScale = 1.0
        }
        
        // Checkmark animation with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.bouncy(duration: 0.5)) {
                checkmarkScale = 1.0
            }
        }
        
        // Text animation with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                textOffset = 0
                textOpacity = 1.0
            }
        }
        
        // Complete after all animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }
}

#Preview {
    AnalysisCompletionView(
        title: "Analysis Complete!",
        subtitle: "Found chord progression and key signature"
    ) {
        print("Completion animation finished")
    }
}