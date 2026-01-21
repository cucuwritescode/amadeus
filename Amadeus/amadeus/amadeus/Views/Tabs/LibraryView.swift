//
//  LibraryView.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  music theory reference library with chords, scales, and progressions
//  central hub for exploring music theory concepts with interactive examples
//
//  acknowledgements:
//  - chord categorisation follows standard western music theory conventions
//  - ui patterns based on ios human interface guidelines
//

import SwiftUI

// MARK: - Main Library View

//main library tab providing access to chord, scale, and progression dictionaries
//serves as the central hub for music theory reference and exploration
struct LibraryView: View {
    //currently selected category filter (not actively used, reserved for future filtering)
    @State private var selectedCategory = "All"

    //search query entered by user for filtering chords
    @State private var searchText = ""

    //shared chord dictionary singleton for data access
    let chordDictionary = ChordDictionary.shared

    //shared progression dictionary singleton for progression data
    let progressionDictionary = ProgressionDictionary.shared

    //chord category definitions with display name, sf symbol icon, and theme colour
    //tuple format: (category name, icon name, accent colour)
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
                //search bar at top for filtering chords by name or keyword
                SearchBar(text: $searchText)
                    .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        //conditional display: show search results or category browser
                        if !searchText.isEmpty {
                            //user is searching, show filtered results
                            SearchResultsView(searchText: searchText)
                        } else {
                            //chord dictionary section with category grid
                            VStack(alignment: .leading) {
                                Text("Chord Dictionary")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)

                                //adaptive grid layout adjusts columns based on screen width
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                                    ForEach(chordCategories, id: \.0) { category, icon, color in
                                        //each category links to its dedicated chord list view
                                        NavigationLink(destination: ChordCategoryView(category: category)) {
                                            VStack(spacing: 12) {
                                                //circular icon badge with category colour
                                                ZStack {
                                                    Circle()
                                                        .fill(color.opacity(0.15))
                                                        .frame(width: 50, height: 50)
                                                    Image(systemName: icon)
                                                        .font(.title2)
                                                        .foregroundColor(color)
                                                }
                                                //category label beneath icon
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

                        //only show progressions and theory sections when not searching
                        if searchText.isEmpty {
                            //popular progressions section as clickable navigation card
                            VStack(alignment: .leading) {
                                Text("Popular Progressions")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)

                                //single card linking to full progression dictionary
                                NavigationLink(destination: ProgressionDictionaryView()) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Explore Chord Progressions")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                        }

                                        Spacer()

                                        //icon with navigation chevron
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

                            //theory resources section with navigation rows
                            VStack(alignment: .leading) {
                                Text("Theory Resources")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)

                                //list of learning resources
                                VStack(spacing: 12) {
                                    //scale dictionary for exploring scales and modes
                                    NavigationLink(destination: ScaleDictionaryView()) {
                                        ResourceRow(title: "Scale Dictionary", icon: "list.bullet", color: .green)
                                    }
                                    //interval training for ear development
                                    NavigationLink(destination: IntervalTrainingView()) {
                                        ResourceRow(title: "Interval Training", icon: "metronome", color: .purple)
                                    }
                                    //ear training for chord recognition practice
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

// MARK: - Search Bar Component

//custom search bar with magnifying glass icon and clear button
//provides real-time filtering as user types
struct SearchBar: View {
    //two-way binding to parent's search text state
    @Binding var text: String

    var body: some View {
        HStack {
            //search icon on the left
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            //text input field with placeholder
            TextField("Search chords...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            //clear button appears only when there's text to clear
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Search Results View

//displays filtered chord results based on search query
//shows empty state with helpful message when no matches found
struct SearchResultsView: View {
    //search query passed from parent view
    let searchText: String

    //shared chord dictionary for searching
    let chordDictionary = ChordDictionary.shared

    //computed property that filters chords matching the search text
    var searchResults: [ChordDefinition] {
        chordDictionary.searchChords(searchText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            //results header showing match count
            Text("Search Results (\(searchResults.count))")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            //conditional display based on whether results were found
            if searchResults.isEmpty {
                //empty state with icon and helpful suggestion
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
                //lazy loading list for performance with many results
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { chord in
                        //each result links to the chord's detail view
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

// MARK: - Chord Search Result Row

//compact row displaying chord summary for use in search results
//shows symbol, name, formula, example notes, and brief description
struct ChordSearchResultRow: View {
    //chord definition to display
    let chord: ChordDefinition

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            //chord symbol in circular badge
            VStack {
                Text(chord.primarySymbol)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }

            //chord information stack
            VStack(alignment: .leading, spacing: 4) {
                //chord name as primary label
                Text(chord.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                //interval formula showing chord construction
                Text("Formula: \(chord.formula)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                //concrete example in key of c for reference
                Text("Example (C): \(chord.pitchClassesC)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                //truncated description as preview
                Text(chord.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            //chevron indicating navigation available
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Resource Row

//reusable row component for theory resource navigation items
//displays icon, title, and navigation chevron with coloured background
struct ResourceRow: View {
    //display title for the resource
    let title: String

    //sf symbol name for the icon
    let icon: String

    //theme colour for icon and background tint
    let color: Color

    var body: some View {
        HStack {
            //resource icon in theme colour
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            //resource title
            Text(title)
                .font(.headline)

            Spacer()

            //navigation chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Card Style Extension

//view extension for consistent card styling across the library
extension View {
    //applies standard card appearance with background, corner radius, and shadow
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}