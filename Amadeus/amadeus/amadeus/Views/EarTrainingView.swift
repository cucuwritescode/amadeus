import SwiftUI

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