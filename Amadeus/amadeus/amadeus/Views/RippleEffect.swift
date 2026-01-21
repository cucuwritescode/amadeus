//
//  RippleEffect.swift
//  amadeus
//
//  created by facundo franchino on 01/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  animated ripple effect view modifier for visual feedback
//  creates expanding circular waves with fading opacity
//
//  acknowledgements:
//  - ripple effect inspired by swiftuirippleeffect repository
//  - animation timing based on material design ripple patterns
//

import SwiftUI

// MARK: - Ripple Effect View Modifier

//view modifier adding animated ripple waves to any view
//creates two concentric expanding circles that fade out on tap
struct RippleEffect: ViewModifier {
    //controls animation state for inner ripple circle
    @State private var animateRipple: Bool = false

    //controls animation state for outer ripple circle
    @State private var animateRipple2: Bool = false

    func body(content: Content) -> some View {
        content
            //overlay ripple circles on top of content
            .overlay {
                ZStack {
                    //inner ripple circle (faster, smaller expansion)
                    Circle()
                        .stroke(.white.opacity(0.6), lineWidth: 2)
                        .scaleEffect(animateRipple ? 1.5 : 0.8)
                        .opacity(animateRipple ? 0 : 1)

                    //outer ripple circle (slower, larger expansion)
                    Circle()
                        .stroke(.white.opacity(0.4), lineWidth: 1)
                        .scaleEffect(animateRipple2 ? 2.0 : 0.8)
                        .opacity(animateRipple2 ? 0 : 1)
                }
                //animation configurations for each ripple
                .animation(.easeOut(duration: 0.6), value: animateRipple)
                .animation(.easeOut(duration: 0.8).delay(0.1), value: animateRipple2)
            }
            //tap gesture triggers the ripple animation
            .onTapGesture {
                //reset animations to starting state
                animateRipple = false
                animateRipple2 = false

                //trigger inner ripple immediately
                withAnimation {
                    animateRipple = true
                }

                //trigger outer ripple with slight delay for staggered effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        animateRipple2 = true
                    }
                }
            }
    }
}

// MARK: - View Extension

//convenience extension for applying ripple effect modifier
extension View {
    //adds tap-triggered ripple animation to any view
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
