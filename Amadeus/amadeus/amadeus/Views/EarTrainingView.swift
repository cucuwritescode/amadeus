//
//  EarTrainingView.swift
//  amadeus
//
//  created by facundo franchino on 25/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  placeholder view for upcoming ear training functionality
//  will include interval recognition and chord identification exercises
//

import SwiftUI

//ear training module placeholder (future implementation!)
struct EarTrainingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "ear")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Ear Training")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Coming Soon...")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Ear Training")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        EarTrainingView()
    }
}
