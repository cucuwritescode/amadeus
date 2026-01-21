//
//  AnalysisCompletionView.swift
//  amadeus
//
//  created by facundo franchino on 10/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  success animation shown after analysis completion
//  displays checkmark with scaling animation and text transitions
//
//  acknowledgements:
//  - animation timing inspired by fuseapponboarding patterns
//  - success state animations based on ios design guidelines
//

import SwiftUI

// MARK: - Analysis Completion View

//success animation view shown after audio analysis completes
//displays animated checkmark with staggered text reveal
struct AnalysisCompletionView: View {
    //main title text (e.g., "analysis complete!")
    let title: String

    //subtitle providing additional info about results
    let subtitle: String

    //callback invoked after animation sequence finishes
    let onComplete: () -> Void

    //tracks overall completion state (not currently used but available)
    @State private var isCompleted = false

    //scale factor for checkmark pop animation
    @State private var checkmarkScale: Double = 0

    //scale factor for background circle grow animation
    @State private var backgroundScale: Double = 0

    //vertical offset for text slide-up animation
    @State private var textOffset: Double = 30

    //opacity for text fade-in animation
    @State private var textOpacity: Double = 0

    var body: some View {
        VStack(spacing: 30) {
            //animated success indicator container
            ZStack {
                //background circle with gradient fill
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

                //checkmark icon with scale animation
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(checkmarkScale)
            }

            //text content with slide and fade animations
            VStack(spacing: 12) {
                //main title with animation transforms
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .offset(y: textOffset)
                    .opacity(textOpacity)

                //subtitle with same animation transforms
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
            }
        }
        .padding(.horizontal, 40)
        //trigger animation sequence when view appears
        .onAppear {
            animateCompletion()
        }
    }

    //orchestrates the staggered animation sequence
    private func animateCompletion() {
        //first: grow background circle
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundScale = 1.0
        }

        //second: pop in checkmark with bounce (0.2s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.bouncy(duration: 0.5)) {
                checkmarkScale = 1.0
            }
        }

        //third: slide up and fade in text (0.5s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                textOffset = 0
                textOpacity = 1.0
            }
        }

        //finally: call completion handler after all animations (1.5s total)
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