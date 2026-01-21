//
//  AnalysisLoadingView.swift
//  amadeus
//
//  created by facundo franchino on 10/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  animated loading view shown during audio analysis
//  displays orbiting dots animation with progress feedback
//
//  acknowledgements:
//  - animation pattern inspired by appleloginanimation repository
//  - orbital motion implementation based on swiftui animation patterns
//

import SwiftUI

// MARK: - Analysis Loading View

//animated loading indicator shown during audio analysis
//displays four orbiting dots with pulsing animations
struct AnalysisLoadingView: View {
    //main title text displayed below animation
    let title: String

    //subtitle text providing additional context
    let subtitle: String

    //current rotation angle in radians for orbital motion
    @State private var rotation: Double = 0

    //scale values for each dot's pulse animation
    @State private var dotScale: [Double] = [1.0, 1.0, 1.0, 1.0]

    //index of currently pulsing dot
    @State private var currentDot = 0

    var body: some View {
        VStack(spacing: 30) {
            //animated orbiting dots container
            ZStack {
                //outer reference ring (faded)
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

                //four orbiting dots positioned using trigonometry
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(gradientForDot(index))
                        .frame(width: 12, height: 12)
                        .scaleEffect(dotScale[index])
                        //calculate position on circular path
                        .position(
                            x: 60 + 50 * cos(rotation + Double(index) * .pi / 2),
                            y: 60 + 50 * sin(rotation + Double(index) * .pi / 2)
                        )
                }
            }
            .frame(width: 120, height: 120)
            //start animation when view appears
            .onAppear {
                startAnimation()
            }

            //text content below animation
            VStack(spacing: 12) {
                //main title
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                //subtitle with secondary styling
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
    }

    //returns unique gradient for each dot based on index
    private func gradientForDot(_ index: Int) -> LinearGradient {
        //colour pairs for each of the four dots
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

    //initiates both rotation and pulsing animations
    private func startAnimation() {
        //continuous rotation animation (one full circle every 3 seconds)
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotation = 2 * .pi
        }

        //start pulsing dot animation
        animateDots()
    }

    //recursive function animating dots in sequence
    private func animateDots() {
        let duration: Double = 0.6

        //scale up current dot
        withAnimation(.easeInOut(duration: duration)) {
            dotScale[currentDot] = 1.5
        }

        //after pulse, scale down and move to next dot
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: duration / 2)) {
                dotScale[currentDot] = 1.0
            }

            //advance to next dot (wrapping around)
            currentDot = (currentDot + 1) % 4

            //continue animation loop
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