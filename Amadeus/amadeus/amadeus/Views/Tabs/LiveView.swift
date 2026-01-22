//
//  LiveView.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  dense mix mode placeholder view for future source separation feature
//  provides ui preview for cloud-based stem separation functionality
//

import SwiftUI

// MARK: - Live View (Dense Mix Mode)

//source separation placeholder tab with stem controls
//displays future pro feature for cloud-based audio stem separation
struct LiveView: View {
    //volume levels for each stem (0.0 to 1.0)
    @State private var vocalsLevel: Double = 0.5
    @State private var drumsLevel: Double = 0.25
    @State private var bassLevel: Double = 0.6
    @State private var pianoLevel: Double = 0.7
    @State private var otherLevel: Double = 0.8

    //alert state for coming soon popup
    @State private var showComingSoonAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 28) {

                        //header section with icon and description
                        VStack(spacing: 12) {
                            //waveform icon with gradient
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)

                                Image(systemName: "waveform.path.ecg")
                                    .font(.system(size: 36))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .padding(.top, 8)

                            //subtitle description
                            Text("Cloud source separation for your tracks")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 4)

                        //stem mixer section
                        VStack(spacing: 16) {
                            StemSliderRow(
                                icon: "mic.fill",
                                level: $vocalsLevel,
                                accentColor: .blue
                            )

                            StemSliderRow(
                                icon: "circle.grid.2x2.fill",
                                level: $drumsLevel,
                                accentColor: .blue
                            )

                            StemSliderRow(
                                icon: "speaker.wave.2.fill",
                                level: $bassLevel,
                                accentColor: .blue
                            )

                            StemSliderRow(
                                icon: "pianokeys",
                                level: $pianoLevel,
                                accentColor: .blue
                            )

                            StemSliderRow(
                                icon: "music.note",
                                level: $otherLevel,
                                accentColor: .blue
                            )
                        }
                        .padding(.horizontal)

                        //run separation button
                        Button(action: {
                            showComingSoonAlert = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Run Separation")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, y: 4)
                        }
                        .padding(.horizontal)

                        //reset button
                        Button(action: {
                            resetLevels()
                        }) {
                            Text("Reset")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }

                        //pro feature preview tag
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("Pro feature preview")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(20)

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Separate any track")
        }
        .alert("Coming Soon", isPresented: $showComingSoonAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Cloud source separation will be available in a future update.")
        }
    }

    //resets all stem levels to default (0.5)
    private func resetLevels() {
        withAnimation(.easeInOut(duration: 0.3)) {
            vocalsLevel = 0.5
            drumsLevel = 0.5
            bassLevel = 0.5
            pianoLevel = 0.5
            otherLevel = 0.5
        }
    }
}

// MARK: - Stem Slider Row Component

//individual stem control row with slider
struct StemSliderRow: View {
    let icon: String
    @Binding var level: Double
    let accentColor: Color

    var body: some View {
        HStack(spacing: 16) {
            //stem icon in circle
            ZStack {
                Circle()
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }

            //custom styled slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    //track background
                    Capsule()
                        .fill(Color(UIColor.tertiarySystemBackground))
                        .frame(height: 6)

                    //filled portion
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.7), accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * level), height: 6)

                    //thumb
                    Circle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(accentColor, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
                        .offset(x: max(0, min(geometry.size.width - 22, (geometry.size.width - 22) * level)))
                }
                .frame(height: 48)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newLevel = max(0, min(1, value.location.x / geometry.size.width))
                            level = newLevel
                        }
                )
            }
            .frame(height: 48)
        }
    }
}

#Preview {
    LiveView()
}
