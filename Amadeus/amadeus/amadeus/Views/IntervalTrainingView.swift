//
//  IntervalTrainingView.swift
//  amadeus
//
//  created by facundo franchino on 25/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  placeholder view for upcoming interval training functionality
//  will include melodic and harmonic interval recognition exercises
//

import SwiftUI

//interval training module placeholder (coming soon)
struct IntervalTrainingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "metronome")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Interval Training")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Coming Soon...")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Interval Training")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        IntervalTrainingView()
    }
}