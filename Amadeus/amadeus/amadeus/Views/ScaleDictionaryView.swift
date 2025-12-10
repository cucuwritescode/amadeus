import SwiftUI

struct ScaleDictionaryView: View {
    @State private var searchText = ""
    private let scaleDictionary = ScaleDictionary.shared
    
    var scaleCategories: [(String, String, Color)] {
        return [
            ("Major/Minor", "music.note", Color.blue),
            ("Pentatonic", "5.circle", Color.green),
            ("Modes", "circle.grid.cross", Color.purple),
            ("Exotic", "sparkles", Color.orange),
            ("Diminished", "minus.circle", Color.red)
        ]
    }
    
    var body: some View {
        VStack {
            // Search Bar
            ScaleSearchBar(text: $searchText)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !searchText.isEmpty {
                        ScaleSearchResultsView(searchText: searchText)
                    } else {
                        // Scale Categories
                        VStack(alignment: .leading) {
                            Text("Scale Categories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                                ForEach(scaleCategories, id: \.0) { category, icon, color in
                                    NavigationLink(destination: ScaleCategoryView(category: category)) {
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
                        
                        // Featured Scales
                        VStack(alignment: .leading) {
                            Text("Essential Scales")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            let essentialScales = [
                                scaleDictionary.scales.first { $0.name.contains("Major Scale") }!,
                                scaleDictionary.scales.first { $0.name.contains("Natural Minor") }!,
                                scaleDictionary.scales.first { $0.name.contains("Minor Pentatonic") }!,
                                scaleDictionary.scales.first { $0.name.contains("Blues") }!
                            ]
                            
                            ForEach(essentialScales) { scale in
                                NavigationLink(destination: ScaleDetailView(scale: scale)) {
                                    ScaleRowView(scale: scale)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Scale Dictionary")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ScaleSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search scales...", text: $text)
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

struct ScaleSearchResultsView: View {
    let searchText: String
    private let scaleDictionary = ScaleDictionary.shared
    
    var searchResults: [ScaleDefinition] {
        scaleDictionary.searchScales(searchText)
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
                    Text("No scales found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try searching for scale names, modes, or musical styles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { scale in
                        NavigationLink(destination: ScaleDetailView(scale: scale)) {
                            ScaleRowView(scale: scale)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct ScaleRowView: View {
    let scale: ScaleDefinition
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Scale icon with category color
            VStack {
                Image(systemName: getCategoryIcon())
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(getCategoryColor())
                    .frame(width: 60, height: 60)
                    .background(getCategoryColor().opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Scale Information
            VStack(alignment: .leading, spacing: 4) {
                Text(scale.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Formula: \(scale.formula)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Example (C): \(scale.cExample)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(String(scale.usage.prefix(100)) + (scale.usage.count > 100 ? "..." : ""))
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
    
    private func getCategoryIcon() -> String {
        switch scale.category {
        case "Major/Minor": return "music.note"
        case "Pentatonic": return "5.circle"
        case "Modes": return "circle.grid.cross"
        case "Exotic": return "sparkles"
        case "Diminished": return "minus.circle"
        default: return "music.note"
        }
    }
    
    private func getCategoryColor() -> Color {
        switch scale.category {
        case "Major/Minor": return .blue
        case "Pentatonic": return .green
        case "Modes": return .purple
        case "Exotic": return .orange
        case "Diminished": return .red
        default: return .blue
        }
    }
}

struct ScaleCategoryView: View {
    let category: String
    private let scaleDictionary = ScaleDictionary.shared
    
    var scales: [ScaleDefinition] {
        return scaleDictionary.scalesByCategory[category] ?? []
    }
    
    var body: some View {
        List {
            ForEach(scales) { scale in
                NavigationLink(destination: ScaleDetailView(scale: scale)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(scale.name)
                            .font(.headline)
                        
                        Text("Formula: \(scale.formula)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Degrees: \(scale.degrees)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ScaleDetailView: View {
    let scale: ScaleDefinition
    @State private var selectedRoot: String = "C"
    
    let rootNotes = ["C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"]
    private let scaleDictionary = ScaleDictionary.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Scale Header
                VStack(spacing: 12) {
                    Text(scale.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(scale.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Root note selector
                    VStack {
                        Text("Root Note")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Root Note", selection: $selectedRoot) {
                            ForEach(rootNotes, id: \.self) { root in
                                Text(root).tag(root)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .scaleEffect(0.8)
                    }
                }
                .padding(.horizontal)
                
                // Piano Visualization
                EnhancedPianoView(highlightedKeys: getHighlightedKeysForRoot())
                    .frame(height: 120)
                    .padding(.horizontal)
                
                // Scale Information Cards
                VStack(spacing: 16) {
                    // Formula Card
                    ScaleInfoCard(title: "Interval Formula", content: scale.formula, icon: "function", color: .blue)
                    
                    // Degrees Card
                    ScaleInfoCard(title: "Scale Degrees", content: scale.degrees, icon: "number", color: .purple)
                    
                    // Notes in Selected Key
                    ScaleInfoCard(title: "Notes in \(selectedRoot)", content: getNotesForRoot(), icon: "music.note", color: .green)
                }
                .padding(.horizontal)
                
                // Usage Description
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Musical Usage & Character")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    
                    Text(scale.usage)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Play Button
                Button(action: playScale) {
                    Label("Play \(selectedRoot) \(scale.name)", systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(scale.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getHighlightedKeysForRoot() -> Set<Int> {
        let rootMap: [String: Int] = [
            "C": 0, "C#/Db": 1, "D": 2, "D#/Eb": 3, "E": 4, "F": 5,
            "F#/Gb": 6, "G": 7, "G#/Ab": 8, "A": 9, "A#/Bb": 10, "B": 11
        ]
        
        let rootNote = rootMap[selectedRoot] ?? 0
        
        let highlightedKeys = scale.semitoneOffsets.map { offset in
            (rootNote + offset) % 12
        }
        
        return Set(highlightedKeys)
    }
    
    private func getNotesForRoot() -> String {
        let scaleNotes = scaleDictionary.getScaleNotes(scale: scale, rootNote: selectedRoot)
        return scaleNotes.joined(separator: "–")
    }
    
    private func playScale() {
        print("Playing \(scale.name) in \(selectedRoot)")
    }
}

struct ScaleInfoCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

