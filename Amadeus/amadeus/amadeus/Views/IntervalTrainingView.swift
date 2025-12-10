import SwiftUI

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