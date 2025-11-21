import SwiftUI

struct LibraryView: View {
    @State private var selectedCategory = "All"
    
    let chordCategories = [
        ("Major", "music.note", Color.blue),
        ("Minor", "music.note", Color.purple),
        ("7th", "7.circle", Color.orange),
        ("Diminished", "circle.slash", Color.red),
        ("Augmented", "plus.circle", Color.green),
        ("Suspended", "pause.circle", Color.cyan),
        ("Altered", "wand.and.stars", Color.pink)
    ]
    
    let progressions = [
        ("ii–V–I", "Jazz Standard", ["Dm7", "G7", "Cmaj7"]),
        ("I–V–vi–IV", "Pop Progression", ["C", "G", "Am", "F"]),
        ("I–vi–IV–V", "50s Progression", ["C", "Am", "F", "G"]),
        ("vi–IV–I–V", "Alternative", ["Am", "F", "C", "G"]),
        ("I–bVII–IV–I", "Rock", ["C", "Bb", "F", "C"]),
        ("i–bVII–bVI–V", "Andalusian", ["Am", "G", "F", "E"])
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Chord Types Section
                    VStack(alignment: .leading) {
                        Text("Chord Types")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                            ForEach(chordCategories, id: \.0) { category, icon, color in
                                NavigationLink(destination: ChordCategoryView(category: category)) {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(color.opacity(0.15))
                                                .frame(width: 50, height: 50)
                                            Image(systemName: icon)
                                                .font(.title2)
                                                .foregroundColor(color)
                                        }
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                }
                                .cardStyle()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Popular Progressions Section
                    VStack(alignment: .leading) {
                        Text("Popular Progressions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(progressions, id: \.0) { name, description, chords in
                            NavigationLink(destination: ProgressionDetailView(name: name, chords: chords)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        HStack {
                                            ForEach(chords, id: \.self) { chord in
                                                Text(chord)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.2))
                                                    .cornerRadius(4)
                                            }
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Theory Resources
                    VStack(alignment: .leading) {
                        Text("Theory Resources")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ResourceRow(title: "Circle of Fifths", icon: "circle", color: .orange)
                            ResourceRow(title: "Scale Dictionary", icon: "list.bullet", color: .green)
                            ResourceRow(title: "Interval Training", icon: "metronome", color: .purple)
                            ResourceRow(title: "Ear Training", icon: "ear", color: .blue)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Library")
        }
    }
}

struct ResourceRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}