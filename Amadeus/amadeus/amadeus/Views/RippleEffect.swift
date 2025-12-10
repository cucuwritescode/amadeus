import SwiftUI

struct RippleEffect: ViewModifier {
    @State private var animateRipple: Bool = false
    @State private var animateRipple2: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.6), lineWidth: 2)
                        .scaleEffect(animateRipple ? 1.5 : 0.8)
                        .opacity(animateRipple ? 0 : 1)
                    
                    Circle()
                        .stroke(.white.opacity(0.4), lineWidth: 1)
                        .scaleEffect(animateRipple2 ? 2.0 : 0.8)
                        .opacity(animateRipple2 ? 0 : 1)
                }
                .animation(.easeOut(duration: 0.6), value: animateRipple)
                .animation(.easeOut(duration: 0.8).delay(0.1), value: animateRipple2)
            }
            .onTapGesture {
                // Reset animations
                animateRipple = false
                animateRipple2 = false
                
                // Trigger ripple effect
                withAnimation {
                    animateRipple = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        animateRipple2 = true
                    }
                }
            }
    }
}

extension View {
    func rippleEffect() -> some View {
        self.modifier(RippleEffect())
    }
}

#Preview {
    Button("Tap me") {
        print("Button tapped!")
    }
    .buttonStyle(PrimaryButtonStyle())
    .rippleEffect()
    .padding()
}