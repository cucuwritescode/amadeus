//
//  ScaleDictionaryView.swift
//  amadeus
//
//  created by facundo franchino on 18/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  interactive scale encyclopedia with search and categorisation
//  displays scales by category with visual keyboard representations
//
//  acknowledgements:
//  - scale data structured using music theory conventions
//  - ui patterns based on ios human interface guidelines
//

import SwiftUI

// MARK: - Main Scale Dictionary View

//browsable scale dictionary organised by category with search functionality
//serves as the entry point for exploring all available scales in the app
struct ScaleDictionaryView: View {
    //search query entered by the user, filters results in real-time
    @State private var searchText = ""

    //shared singleton containing all scale definitions
    private let scaleDictionary = ScaleDictionary.shared

    //category definitions with display name, sf symbol icon, and theme colour
    //tuple format: (category name, icon name, accent colour)
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
            //search bar at top for filtering scales by name or keyword
            ScaleSearchBar(text: $searchText)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    //conditional display: show search results or category browser
                    if !searchText.isEmpty {
                        //user is searching, show filtered results
                        ScaleSearchResultsView(searchText: searchText)
                    } else {
                        //default view: category grid and essential scales

                        //category selection grid with colour-coded icons
                        VStack(alignment: .leading) {
                            Text("Scale Categories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            //adaptive grid layout adjusts columns based on screen width
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                                ForEach(scaleCategories, id: \.0) { category, icon, color in
                                    //each category links to its dedicated list view
                                    NavigationLink(destination: ScaleCategoryView(category: category)) {
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

                        //featured scales section showing the most commonly used scales
                        VStack(alignment: .leading) {
                            Text("Essential Scales")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            //curated list of fundamental scales every musician should know
                            let essentialScales = [
                                scaleDictionary.scales.first { $0.name.contains("Major Scale") }!,
                                scaleDictionary.scales.first { $0.name.contains("Natural Minor") }!,
                                scaleDictionary.scales.first { $0.name.contains("Minor Pentatonic") }!,
                                scaleDictionary.scales.first { $0.name.contains("Blues") }!
                            ]

                            //display each essential scale as a tappable row
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

// MARK: - Search Bar Component

//custom search bar with magnifying glass icon and clear button
//provides real-time filtering as user types
struct ScaleSearchBar: View {
    //two-way binding to parent's search text state
    @Binding var text: String

    var body: some View {
        HStack {
            //search icon on the left
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            //text input field with placeholder
            TextField("Search scales...", text: $text)
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

//displays filtered scale results based on search query
//shows empty state with helpful message when no matches found
struct ScaleSearchResultsView: View {
    //search query passed from parent view
    let searchText: String

    //shared scale dictionary for searching
    private let scaleDictionary = ScaleDictionary.shared

    //computed property that filters scales matching the search text
    var searchResults: [ScaleDefinition] {
        scaleDictionary.searchScales(searchText)
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
                //lazy loading list for performance with many results
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { scale in
                        //each result links to the scale's detail view
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

// MARK: - Scale Row View

//compact row displaying scale summary for use in lists
//shows icon, name, formula, example notes, and brief description
struct ScaleRowView: View {
    //scale definition to display
    let scale: ScaleDefinition

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            //circular icon badge colour-coded by category
            VStack {
                Image(systemName: getCategoryIcon())
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(getCategoryColor())
                    .frame(width: 60, height: 60)
                    .background(getCategoryColor().opacity(0.1))
                    .clipShape(Circle())
            }

            //scale information stack
            VStack(alignment: .leading, spacing: 4) {
                //scale name as primary label
                Text(scale.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                //interval formula showing step pattern
                Text("Formula: \(scale.formula)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                //concrete example in key of c for reference
                Text("Example (C): \(scale.cExample)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                //truncated usage description as preview
                Text(String(scale.usage.prefix(100)) + (scale.usage.count > 100 ? "..." : ""))
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

    //returns sf symbol name based on scale category
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

    //returns theme colour based on scale category
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

// MARK: - Scale Category View

//lists all scales within a specific category
//allows drilling down from category grid to individual scales
struct ScaleCategoryView: View {
    //category name passed from parent navigation
    let category: String

    //shared scale dictionary for data access
    private let scaleDictionary = ScaleDictionary.shared

    //computed property filtering scales by the selected category
    var scales: [ScaleDefinition] {
        return scaleDictionary.scalesByCategory[category] ?? []
    }

    var body: some View {
        List {
            //iterate through all scales in this category
            ForEach(scales) { scale in
                //each row links to the full scale detail view
                NavigationLink(destination: ScaleDetailView(scale: scale)) {
                    VStack(alignment: .leading, spacing: 4) {
                        //scale name as primary identifier
                        Text(scale.name)
                            .font(.headline)

                        //interval formula showing whole/half step pattern
                        Text("Formula: \(scale.formula)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        //scale degrees showing numeric positions
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

// MARK: - Scale Detail View

//comprehensive view showing all information about a specific scale
//includes interactive root note selector and piano visualisation
struct ScaleDetailView: View {
    //scale definition containing all data to display
    let scale: ScaleDefinition

    //currently selected root note, defaults to c
    @State private var selectedRoot: String = "C"

    //controls visibility of the coming soon alert for play button
    @State private var showPlayAlert = false

    //all twelve chromatic root notes with enharmonic equivalents
    let rootNotes = ["C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"]

    //shared dictionary for note name lookups
    private let scaleDictionary = ScaleDictionary.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                //header section with scale name and category badge
                VStack(spacing: 12) {
                    //scale name as large title
                    Text(scale.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    //category badge pill
                    Text(scale.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)

                    //root note picker allowing transposition to any key
                    VStack {
                        Text("Root Note")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        //segmented control for root selection
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

                //piano keyboard visualisation highlighting scale tones
                EnhancedPianoView(highlightedKeys: getHighlightedKeysForRoot())
                    .frame(height: 120)
                    .padding(.horizontal)

                //information cards showing scale properties
                VStack(spacing: 16) {
                    //interval formula card (e.g., w-w-h-w-w-w-h)
                    ScaleInfoCard(title: "Interval Formula", content: scale.formula, icon: "function", color: .blue)

                    //scale degrees card (e.g., 1-2-3-4-5-6-7)
                    ScaleInfoCard(title: "Scale Degrees", content: scale.degrees, icon: "number", color: .purple)

                    //actual note names in the currently selected key
                    ScaleInfoCard(title: "Notes in \(selectedRoot)", content: getNotesForRoot(), icon: "music.note", color: .green)
                }
                .padding(.horizontal)

                //usage description card explaining musical context
                VStack(alignment: .leading, spacing: 12) {
                    //card header with icon
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Musical Usage & Character")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Spacer()
                    }

                    //detailed description of when and how to use this scale
                    Text(scale.usage)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                //play button (audio playback not yet implemented)
                Button(action: { showPlayAlert = true }) {
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
        //alert shown when play button tapped
        .alert("Coming Soon", isPresented: $showPlayAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Audio playback will be available in a future update.")
        }
    }

    //calculates which piano keys to highlight based on selected root
    //transposes the scale's semitone offsets to the chosen key
    private func getHighlightedKeysForRoot() -> Set<Int> {
        //mapping from note name to semitone value (c = 0)
        let rootMap: [String: Int] = [
            "C": 0, "C#/Db": 1, "D": 2, "D#/Eb": 3, "E": 4, "F": 5,
            "F#/Gb": 6, "G": 7, "G#/Ab": 8, "A": 9, "A#/Bb": 10, "B": 11
        ]

        //get numeric value for selected root
        let rootNote = rootMap[selectedRoot] ?? 0

        //add root offset to each scale degree, wrap at octave
        let highlightedKeys = scale.semitoneOffsets.map { offset in
            (rootNote + offset) % 12
        }

        return Set(highlightedKeys)
    }

    //returns note names for the scale in the selected key
    private func getNotesForRoot() -> String {
        let scaleNotes = scaleDictionary.getScaleNotes(scale: scale, rootNote: selectedRoot)
        return scaleNotes.joined(separator: "–")
    }

    //placeholder for future audio playback functionality
    private func playScale() {
        print("Playing \(scale.name) in \(selectedRoot)")
    }
}

// MARK: - Scale Info Card

//reusable card component for displaying scale properties
//used for formula, degrees, and notes sections
struct ScaleInfoCard: View {
    //card title displayed in header
    let title: String

    //main content text to display
    let content: String

    //sf symbol name for header icon
    let icon: String

    //theme colour for header and background tint
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            //card header with icon and title
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
            }

            //content text below header
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

