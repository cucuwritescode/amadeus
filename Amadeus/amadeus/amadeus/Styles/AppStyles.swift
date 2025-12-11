//
//  AppStyles.swift
//  amadeus
//
//  created by facundo franchino on 28/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  centralised styling and theming for consistent ui
//  defines button styles, colours, and reusable modifiers
//
//  acknowledgements:
//  - design patterns from swiftui best practices
//  - colour scheme inspired by music production software
//

import SwiftUI

// MARK: - Custom Colors
extension Color {
    static let amadeusBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let amadeusPurple = Color(red: 0.6, green: 0.3, blue: 0.8)
    static let amadeusBackground = Color(UIColor.systemBackground)
    static let amadeusSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let amadeusTertiaryBackground = Color(UIColor.tertiarySystemBackground)
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.amadeusBlue, Color.amadeusPurple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(color: Color.amadeusBlue.opacity(0.3), radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Color.amadeusSecondaryBackground
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: configuration.isPressed ? 1 : 4, y: configuration.isPressed ? 0 : 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card View Modifier
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.amadeusSecondaryBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        self.modifier(CardStyle(padding: padding))
    }
}

// MARK: - Glassmorphism Effect
struct GlassmorphicStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color.white.opacity(0.1)
                    VisualEffectBlur(blurStyle: .systemThinMaterial)
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}