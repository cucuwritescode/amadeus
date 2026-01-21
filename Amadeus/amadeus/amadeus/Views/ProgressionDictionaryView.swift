//
//  ProgressionDictionaryView.swift
//  amadeus
//
//  created by facundo franchino on 22/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  chord progression encyclopedia organised by genre and style
//  includes common progressions from pop, jazz, blues, and more
//
//  acknowledgements:
//  - progression categorisation based on genre conventions
//  - roman numeral notation follows standard music theory
//

import SwiftUI

// MARK: - Progression Dictionary View

//browsable chord progression library with genre categories
//provides searchable encyclopedia of common chord progressions
struct ProgressionDictionaryView: View {
    //search query for filtering progressions
    @State private var searchText = ""

    //shared progression dictionary singleton for data access
    private let progressionDictionary = ProgressionDictionary.shared

    //progression category definitions with display name, sf symbol, and colour
    //tuple format: (category name, icon name, theme colour)
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
            //search bar at top of view
            ProgressionSearchBar(text: $searchText)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    //show search results when user is searching
                    if !searchText.isEmpty {
                        ProgressionSearchResultsView(searchText: searchText)
                    } else {
                        //progression categories grid section
                        VStack(alignment: .leading) {
                            Text("Progression Categories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            //adaptive grid adjusts columns based on screen width
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                                ForEach(progressionCategories, id: \.0) { category, icon, color in
                                    //each category links to filtered list view
                                    NavigationLink(destination: ProgressionCategoryView(category: category)) {
                                        VStack(spacing: 12) {
                                            //circular icon badge
                                            ZStack {
                                                Circle()
                                                    .fill(color.opacity(0.15))
                                                    .frame(width: 50, height: 50)
                                                Image(systemName: icon)
                                                    .font(.title2)
                                                    .foregroundColor(color)
                                            }
                                            //category name label
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

                        //featured essential progressions section
                        VStack(alignment: .leading) {
                            Text("Essential Progressions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            //curated list of the most common progressions
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

                        //complete list of all progressions
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

// MARK: - Progression Search Bar

//search input for filtering progressions by name, numerals, or song examples
struct ProgressionSearchBar: View {
    //two-way binding to parent's search text
    @Binding var text: String

    var body: some View {
        HStack {
            //search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            //text input field
            TextField("Search progressions...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            //clear button shown when there's text
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Progression Search Results View

//displays filtered progression results based on search query
struct ProgressionSearchResultsView: View {
    //search query from parent view
    let searchText: String

    //shared dictionary for searching
    private let progressionDictionary = ProgressionDictionary.shared

    //computed property that filters progressions matching search text
    var searchResults: [ChordProgression] {
        progressionDictionary.searchProgressions(searchText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            //results header with count
            Text("Search Results (\(searchResults.count))")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            //empty state or results list
            if searchResults.isEmpty {
                //empty state with helpful suggestion
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
                //lazy loading list for performance
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

// MARK: - Progression Row View

//compact row displaying progression summary for list views
//shows category icon, roman numerals, tempo, chord preview, and description
struct ProgressionRowView: View {
    //progression data to display
    let progression: ChordProgression

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            //category icon in circular badge
            VStack {
                Image(systemName: getCategoryIcon())
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(getCategoryColor())
                    .frame(width: 60, height: 60)
                    .background(getCategoryColor().opacity(0.1))
                    .clipShape(Circle())
            }

            //progression information stack
            VStack(alignment: .leading, spacing: 6) {
                //progression name as primary label
                Text(progression.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)

                //roman numeral notation for major and minor keys
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

                //typical tempo range for this progression
                Text(progression.tempoRange)
                    .font(.caption)
                    .foregroundColor(.secondary)

                //chord preview pills showing first 4 chords in c major
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

                //truncated description as preview
                Text(String(progression.description.prefix(100)) + (progression.description.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            //navigation chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    //returns sf symbol name based on progression's genre category
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

    //returns theme colour based on progression's genre category
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

    //determines genre category from progression nickname keywords
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

// MARK: - Progression Category View

//filtered list view showing progressions within a specific genre category
struct ProgressionCategoryView: View {
    //category name used for filtering and title
    let category: String

    //shared dictionary for data access
    private let progressionDictionary = ProgressionDictionary.shared

    //computed property filtering progressions by category keywords
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
                //each row links to detailed progression view
                NavigationLink(destination: EnhancedProgressionDetailView(progression: progression)) {
                    VStack(alignment: .leading, spacing: 4) {
                        //progression display name
                        Text(progression.displayName)
                            .font(.headline)

                        //roman numeral notation
                        HStack {
                            Text("Major: \(progression.romanNumeralsMajor)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text("• Minor: \(progression.romanNumeralsMinor)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }

                        //tempo range
                        Text(progression.tempoRange)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        //famous song examples
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
