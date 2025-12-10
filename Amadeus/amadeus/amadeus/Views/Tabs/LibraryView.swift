import SwiftUI

struct LibraryView: View {
    @State private var selectedCategory = "All"
    @State private var searchText = ""
    
    let chordDictionary = ChordDictionary.shared
    let progressionDictionary = ProgressionDictionary.shared
    
    var chordCategories: [(String, String, Color)] {
        return [
            ("Major", "music.note", Color.blue),
            ("Minor", "music.note", Color.purple),
            ("7th Chords", "7.circle", Color.orange),
            ("Diminished", "circle.slash", Color.red),
            ("Augmented", "plus.circle", Color.green),
            ("Suspended", "pause.circle", Color.cyan),
            ("6th Chords", "6.circle", Color.indigo),
            ("9th Chords", "9.circle", Color.mint),
            ("11th Chords", "11.circle", Color.yellow),
            ("13th Chords", "13.circle", Color.pink),
            ("Add Chords", "plus", Color.teal)
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Show search results if searching
                        if !searchText.isEmpty {
                            SearchResultsView(searchText: searchText)
                        } else {
                            // Chord Dictionary Section
                            VStack(alignment: .leading) {
                                Text("Chord Dictionary")
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
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 20)
                                        }
                                        .cardStyle()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Only show progressions and theory if not searching
                        if searchText.isEmpty {
                            // Popular Progressions Section (now as clickable card)
                            VStack(alignment: .leading) {
                                Text("Popular Progressions")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                NavigationLink(destination: ProgressionDictionaryView()) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Explore Chord Progressions")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 4) {
                                            Image(systemName: "music.note.list")
                                                .font(.system(size: 32))
                                                .foregroundColor(.blue)
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.05))
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Theory Resources
                            VStack(alignment: .leading) {
                                Text("Theory Resources")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    NavigationLink(destination: ScaleDictionaryView()) {
                                        ResourceRow(title: "Scale Dictionary", icon: "list.bullet", color: .green)
                                    }
                                    NavigationLink(destination: IntervalTrainingView()) {
                                        ResourceRow(title: "Interval Training", icon: "metronome", color: .purple)
                                    }
                                    NavigationLink(destination: EarTrainingView()) {
                                        ResourceRow(title: "Ear Training", icon: "ear", color: .blue)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Library")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search chords...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .foregroundColor(.blue)
            }
        }
    }
}

struct SearchResultsView: View {
    let searchText: String
    let chordDictionary = ChordDictionary.shared
    
    var searchResults: [ChordDefinition] {
        chordDictionary.searchChords(searchText)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search Results (\(searchResults.count))")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No chords found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try searching for chord names, symbols, or descriptions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { chord in
                        NavigationLink(destination: EnhancedChordDetailView(chord: chord)) {
                            ChordSearchResultRow(chord: chord)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct ChordSearchResultRow: View {
    let chord: ChordDefinition
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Chord Symbol
            VStack {
                Text(chord.primarySymbol)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Chord Information
            VStack(alignment: .leading, spacing: 4) {
                Text(chord.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Formula: \(chord.formula)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Example (C): \(chord.pitchClassesC)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(chord.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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

// Extension for card styling
extension View {
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}