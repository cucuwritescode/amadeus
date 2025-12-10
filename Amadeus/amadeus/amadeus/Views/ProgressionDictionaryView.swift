import SwiftUI

struct ProgressionDictionaryView: View {
    @State private var searchText = ""
    private let progressionDictionary = ProgressionDictionary.shared
    
    var progressionCategories: [(String, String, Color)] {
        return [
            ("Pop/Rock", "music.note", Color.blue),
            ("Jazz", "music.note.list", Color.orange),
            ("Blues/Rock", "guitars", Color.purple),
            ("Classic/Vintage", "hifispeaker", Color.green),
            ("Modal/World", "globe", Color.red),
            ("Advanced/Jazz", "graduationcap", Color.indigo)
        ]
    }
    
    var body: some View {
        VStack {
            // Search Bar
            ProgressionSearchBar(text: $searchText)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !searchText.isEmpty {
                        ProgressionSearchResultsView(searchText: searchText)
                    } else {
                        // Progression Categories
                        VStack(alignment: .leading) {
                            Text("Progression Categories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                                ForEach(progressionCategories, id: \.0) { category, icon, color in
                                    NavigationLink(destination: ProgressionCategoryView(category: category)) {
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
                        
                        // Featured Progressions
                        VStack(alignment: .leading) {
                            Text("Essential Progressions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            let essentialProgressions = [
                                progressionDictionary.progressions.first { $0.name == "I–V–vi–IV" }!,
                                progressionDictionary.progressions.first { $0.name == "ii–V–I" }!,
                                progressionDictionary.progressions.first { $0.name == "I–IV–V" }!,
                                progressionDictionary.progressions.first { $0.name == "vi–IV–I–V" }!
                            ]
                            
                            ForEach(essentialProgressions) { progression in
                                NavigationLink(destination: EnhancedProgressionDetailView(progression: progression)) {
                                    ProgressionRowView(progression: progression)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        
                        // All Progressions List
                        VStack(alignment: .leading) {
                            Text("All Progressions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(progressionDictionary.progressions) { progression in
                                NavigationLink(destination: EnhancedProgressionDetailView(progression: progression)) {
                                    ProgressionRowView(progression: progression)
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
        .navigationTitle("Progression Dictionary")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ProgressionSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search progressions...", text: $text)
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

struct ProgressionSearchResultsView: View {
    let searchText: String
    private let progressionDictionary = ProgressionDictionary.shared
    
    var searchResults: [ChordProgression] {
        progressionDictionary.searchProgressions(searchText)
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
                    Text("No progressions found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try searching for Roman numerals, song names, or musical styles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { progression in
                        NavigationLink(destination: EnhancedProgressionDetailView(progression: progression)) {
                            ProgressionRowView(progression: progression)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct ProgressionRowView: View {
    let progression: ChordProgression
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Progression icon with category color
            VStack {
                Image(systemName: getCategoryIcon())
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(getCategoryColor())
                    .frame(width: 60, height: 60)
                    .background(getCategoryColor().opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Progression Information
            VStack(alignment: .leading, spacing: 6) {
                Text(progression.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("Major:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(progression.romanNumeralsMajor)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("• Minor:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(progression.romanNumeralsMinor)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Text(progression.tempoRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Chord preview
                HStack {
                    ForEach(progression.majorProgression.prefix(4)) { chord in
                        Text(chord.chord)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    Text("(in C)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(String(progression.description.prefix(100)) + (progression.description.count > 100 ? "..." : ""))
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
        let category = getProgressionCategory()
        switch category {
        case "Pop/Rock": return "music.note"
        case "Jazz": return "music.note.list"
        case "Blues/Rock": return "guitars"
        case "Classic/Vintage": return "hifispeaker"
        case "Modal/World": return "globe"
        case "Advanced/Jazz": return "graduationcap"
        default: return "music.note"
        }
    }
    
    private func getCategoryColor() -> Color {
        let category = getProgressionCategory()
        switch category {
        case "Pop/Rock": return .blue
        case "Jazz": return .orange
        case "Blues/Rock": return .purple
        case "Classic/Vintage": return .green
        case "Modal/World": return .red
        case "Advanced/Jazz": return .indigo
        default: return .blue
        }
    }
    
    private func getProgressionCategory() -> String {
        let nickname = progression.nickname.lowercased()
        
        if nickname.contains("pop") {
            return "Pop/Rock"
        } else if nickname.contains("jazz") {
            return "Jazz"
        } else if nickname.contains("blues") || nickname.contains("rock") {
            return "Blues/Rock"
        } else if nickname.contains("doo-wop") || nickname.contains("50s") {
            return "Classic/Vintage"
        } else if nickname.contains("andalusian") || nickname.contains("mixolydian") {
            return "Modal/World"
        } else if nickname.contains("circle") {
            return "Advanced/Jazz"
        }
        
        return "Other"
    }
}

struct ProgressionCategoryView: View {
    let category: String
    private let progressionDictionary = ProgressionDictionary.shared
    
    var progressions: [ChordProgression] {
        return progressionDictionary.progressions.filter { progression in
            let nickname = progression.nickname.lowercased()
            switch category {
            case "Pop/Rock":
                return nickname.contains("pop")
            case "Jazz":
                return nickname.contains("jazz")
            case "Blues/Rock":
                return nickname.contains("blues") || nickname.contains("rock")
            case "Classic/Vintage":
                return nickname.contains("doo-wop") || nickname.contains("50s")
            case "Modal/World":
                return nickname.contains("andalusian") || nickname.contains("mixolydian")
            case "Advanced/Jazz":
                return nickname.contains("circle")
            default:
                return false
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(progressions) { progression in
                NavigationLink(destination: EnhancedProgressionDetailView(progression: progression)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(progression.displayName)
                            .font(.headline)
                        
                        HStack {
                            Text("Major: \(progression.romanNumeralsMajor)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text("• Minor: \(progression.romanNumeralsMinor)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Text(progression.tempoRange)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Show some famous songs
                        if !progression.songExamples.isEmpty {
                            Text("Examples: \(progression.songExamples.prefix(2).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
    }
}