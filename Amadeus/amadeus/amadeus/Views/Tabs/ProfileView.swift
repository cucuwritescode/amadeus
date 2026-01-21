//
//  ProfileView.swift
//  amadeus
//
//  created by facundo franchino on 14/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  user profile and settings tab with learning statistics
//  includes app configuration, help resources, and about information
//
//  acknowledgements:
//  - settings patterns based on ios human interface guidelines
//  - statistics persistence using appstorage wrapper
//

import SwiftUI

// MARK: - Profile View

//profile tab displaying user stats, settings, and app information
//serves as the main hub for user preferences and learning progress
struct ProfileView: View {
    //dark mode preference persisted across app launches
    @AppStorage("isDarkMode") private var isDarkMode = false

    //notification toggle state
    @State private var notificationsEnabled = true

    //auto-analysis toggle for automatic processing
    @State private var autoAnalysis = false

    //currently selected audio input device
    @State private var selectedAudioInput = "Built-in Microphone"

    //learning statistics persisted to userdefaults
    @AppStorage("songsAnalysed") private var songsAnalysed = 0
    @AppStorage("chordsLearned") private var chordsLearned = 0
    @AppStorage("practiceHours") private var practiceHours = 0.0

    //available audio input options for the picker
    let audioInputs = ["Built-in Microphone", "External Microphone", "Audio Interface"]
    
    var body: some View {
        NavigationView {
            List {
                //profile header section displaying user avatar and level
                Section {
                    HStack {
                        //user avatar icon
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        //user info with name and skill level
                        VStack(alignment: .leading) {
                            Text("Music Learner")
                                .font(.headline)
                            Text("Intermediate Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                //app settings section for general preferences
                Section("App Settings") {
                    //notification toggle row
                    HStack {
                        Image(systemName: "bell.circle")
                            .foregroundColor(.orange)
                        Text("Notifications")
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                    }
                }

                //audio settings section for input device and analysis engine
                Section("Audio Settings") {
                    //audio input device selector
                    HStack {
                        Image(systemName: "mic.circle")
                            .foregroundColor(.red)
                        Text("Audio Input")
                        Spacer()
                        Picker("Audio Input", selection: $selectedAudioInput) {
                            ForEach(audioInputs, id: \.self) { input in
                                Text(input).tag(input)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    //navigation to analysis engine configuration
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gearshape.circle")
                                .foregroundColor(.purple)
                            Text("Analysis Engine")
                        }
                    }
                }

                //learning section with stats, achievements, and goals
                Section("Learning") {
                    //navigation to detailed learning statistics
                    NavigationLink(destination: LearningStatsView()) {
                        HStack {
                            Image(systemName: "chart.bar.circle")
                                .foregroundColor(.green)
                            Text("Learning Stats")
                        }
                    }

                    //navigation to achievements and badges
                    NavigationLink(destination: AchievementsView()) {
                        HStack {
                            Image(systemName: "star.circle")
                                .foregroundColor(.yellow)
                            Text("Achievements")
                        }
                    }

                    //navigation to practice goal settings
                    NavigationLink(destination: Text("Practice Goals")) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.orange)
                            Text("Practice Goals")
                        }
                    }
                }

                //support section with help, contact, and privacy
                Section("Support") {
                    //navigation to help documentation and tutorials
                    NavigationLink(destination: HelpTutorialsView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                            Text("Help & Tutorials")
                        }
                    }

                    //navigation to contact form (placeholder)
                    NavigationLink(destination: Text("Contact Us")) {
                        HStack {
                            Image(systemName: "envelope.circle")
                                .foregroundColor(.green)
                            Text("Contact Us")
                        }
                    }

                    //navigation to privacy policy
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "lock.circle")
                                .foregroundColor(.gray)
                            Text("Privacy Policy")
                        }
                    }
                }

                //about section with version info and credits
                Section("About") {
                    //app version display
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    //build date display
                    HStack {
                        Image(systemName: "hammer.circle")
                            .foregroundColor(.orange)
                        Text("Build")
                        Spacer()
                        Text("Dec 2025")
                            .foregroundColor(.secondary)
                    }

                    //navigation to credits and acknowledgements
                    NavigationLink(destination: CreditsView()) {
                        HStack {
                            Image(systemName: "heart.circle")
                                .foregroundColor(.pink)
                            Text("Credits & Acknowledgements")
                        }
                    }
                }

                //sign out section (placeholder for future auth)
                Section {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Learning Stats View

//displays user's learning progress with persisted statistics
//shows songs analysed, chords learned, practice hours, and accuracy
struct LearningStatsView: View {
    //persisted statistics from userdefaults
    @AppStorage("songsAnalysed") private var songsAnalysed = 0
    @AppStorage("chordsLearned") private var chordsLearned = 0
    @AppStorage("practiceHours") private var practiceHours = 0.0
    @AppStorage("accuracy") private var accuracy = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                //stat cards for each tracked metric
                StatCard(title: "Songs Analysed", value: "\(songsAnalysed)", icon: "music.note")
                StatCard(title: "Chords Learned", value: "\(chordsLearned)", icon: "music.note.list")
                StatCard(title: "Practice Hours", value: String(format: "%.1f", practiceHours), icon: "clock")
                StatCard(title: "Accuracy", value: "\(accuracy)%", icon: "target")
            }
            .padding()
        }
        .navigationTitle("Learning Stats")
    }
}

// MARK: - Stat Card

//reusable card component for displaying individual statistics
//shows icon, title, and value in a horizontal layout
struct StatCard: View {
    //stat label displayed below the value
    let title: String

    //main statistic value to display
    let value: String

    //sf symbol name for the icon
    let icon: String

    var body: some View {
        HStack {
            //stat icon on the left
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            //title and value stack
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Help & Tutorials View

//help view with documentation links, tips, and support contact
//provides quick access to learning resources and troubleshooting
struct HelpTutorialsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                //documentation section with external link
                VStack(alignment: .leading, spacing: 16) {
                    //section header
                    HStack {
                        Image(systemName: "book.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("Documentation")
                            .font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        //description text
                        Text("Access the complete Amadeus documentation for detailed guides on chord analysis, music theory, and app features.")
                            .foregroundColor(.secondary)

                        //external documentation link button
                        Link(destination: URL(string: "https://amadeus-chordzart.readthedocs.io")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("View Documentation")
                            }
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }

                Divider()

                //quick tips section with helpful usage advice
                VStack(alignment: .leading, spacing: 16) {
                    //section header
                    HStack {
                        Image(systemName: "lightbulb.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        Text("Quick Tips")
                            .font(.headline)
                    }

                    //tip cards for common usage scenarios
                    VStack(alignment: .leading, spacing: 12) {
                        TipCard(icon: "mic.fill", title: "Recording Tips", description: "Record in a quiet environment for best chord detection accuracy.")
                        TipCard(icon: "waveform", title: "Audio Quality", description: "Use clear, well-recorded audio files for optimal analysis results.")
                        TipCard(icon: "music.note", title: "Chord Analysis", description: "The app works best with acoustic instruments and clear chord progressions.")
                    }
                }

                Divider()

                //contact section for additional support
                VStack(alignment: .leading, spacing: 16) {
                    //section header
                    HStack {
                        Image(systemName: "envelope.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        Text("Need More Help?")
                            .font(.headline)
                    }

                    Text("For additional support or feature requests, contact our team.")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Help & Tutorials")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Tip Card

//reusable card for displaying individual tips with icon and description
struct TipCard: View {
    //sf symbol name for the tip icon
    let icon: String

    //tip title displayed prominently
    let title: String

    //detailed tip description
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            //tip icon
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)

            //title and description stack
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Privacy Policy View

//displays the app's privacy policy with categorised sections
//explains data collection, processing, and user rights
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                //page title
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                //last updated date
                Text("Last updated: December 2025")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                //policy sections covering different data aspects
                VStack(alignment: .leading, spacing: 16) {
                    PolicySection(
                        title: "Information We Collect",
                        content: "Amadeus processes audio files locally on your device for chord analysis. We do not collect, store, or transmit your personal audio recordings. Usage statistics may be collected to improve app performance."
                    )

                    PolicySection(
                        title: "Data Processing",
                        content: "Audio analysis is performed using our secure server infrastructure. Audio data is processed temporarily and immediately deleted after analysis. No audio content is stored on our servers."
                    )

                    PolicySection(
                        title: "Local Storage",
                        content: "The app stores your analysis results, learning progress, and app preferences locally on your device. This data remains under your control and can be deleted by uninstalling the app."
                    )

                    PolicySection(
                        title: "Permissions",
                        content: "Amadeus requires microphone access for live recording features. Camera access may be requested for importing audio files. These permissions are used solely for app functionality."
                    )

                    PolicySection(
                        title: "Third-Party Services",
                        content: "We use industry-standard analytics tools to understand app usage and improve performance. These services collect only anonymous usage data and do not have access to your audio content."
                    )

                    PolicySection(
                        title: "Data Security",
                        content: "We implement appropriate security measures to protect your data. All network communications are encrypted, and we follow best practices for data handling and storage."
                    )

                    PolicySection(
                        title: "Contact Us",
                        content: "If you have questions about this privacy policy or our data practices, please contact us through the app's support channels or visit our documentation."
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Policy Section

//reusable component for privacy policy section with title and content
struct PolicySection: View {
    //section heading
    let title: String

    //section body text
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            //section title
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            //section content with proper text wrapping
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Achievements View

//displays user achievements as a list with unlock status
//motivates learning through gamification elements
struct AchievementsView: View {
    //achievement definitions: (name, description, unlocked status)
    let achievements = [
        ("First Analysis", "Complete your first song analysis", true),
        ("Chord Master", "Learn 50 different chords", false),
        ("Speed Demon", "Use 0.5x speed for practice", true),
        ("Transposer", "Transpose a song to 5 different keys", false),
        ("Library Explorer", "View 20 chord details", true)
    ]

    var body: some View {
        List {
            ForEach(achievements, id: \.0) { name, description, unlocked in
                HStack {
                    //achievement icon changes colour based on unlock status
                    Image(systemName: unlocked ? "star.circle.fill" : "star.circle")
                        .foregroundColor(unlocked ? .yellow : .gray)
                        .font(.title2)

                    //achievement name and description
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(unlocked ? .primary : .secondary)
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Achievements")
    }
}

// MARK: - Credits View

//credits and acknowledgements view displaying attributions for frameworks and assets
//provides transparency about third-party code and research used in the app
struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                //page header with title and introduction
                VStack(alignment: .leading, spacing: 8) {
                    Text("Credits & Acknowledgements")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Amadeus is built with the help of these amazing technologies and resources.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()

                //design credits section for visual assets
                CreditSection(
                    title: "Design",
                    icon: "paintbrush.fill",
                    iconColor: .purple,
                    credits: [
                        CreditItem(
                            name: "App Logo & Icon",
                            description: "Original design by Facundo Franchino"
                        ),
                        CreditItem(
                            name: "SF Symbols",
                            description: "Iconography by Apple Inc."
                        )
                    ]
                )

                Divider()

                //frameworks section for code dependencies
                CreditSection(
                    title: "Frameworks & Libraries",
                    icon: "shippingbox.fill",
                    iconColor: .blue,
                    credits: [
                        CreditItem(
                            name: "AudioKit",
                            description: "Audio synthesis and processing framework by Aurelius Prochazka et al. (audiokit.io)"
                        ),
                        CreditItem(
                            name: "Tonic",
                            description: "Music theory library for Swift by AudioKit"
                        ),
                        CreditItem(
                            name: "SwiftUI",
                            description: "User interface framework by Apple Inc."
                        ),
                        CreditItem(
                            name: "AVFoundation",
                            description: "Audio/video framework by Apple Inc."
                        ),
                        CreditItem(
                            name: "Accelerate",
                            description: "High-performance DSP framework by Apple Inc."
                        )
                    ]
                )

                Divider()

                //research section for academic and algorithmic references
                CreditSection(
                    title: "Research & Algorithms",
                    icon: "brain.head.profile",
                    iconColor: .green,
                    credits: [
                        CreditItem(
                            name: "Basic Pitch",
                            description: "Neural network for polyphonic pitch detection by Rachel Bittner et al. (Spotify/Magenta, ICASSP 2022)"
                        ),
                        CreditItem(
                            name: "Krumhansl-Schmuckler Algorithm",
                            description: "Key detection algorithm based on pitch class profiles"
                        )
                    ]
                )

                Divider()

                //developer information section
                VStack(alignment: .leading, spacing: 12) {
                    //section header
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Developer")
                            .font(.headline)
                    }

                    //developer details card
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Facundo Franchino")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("University of York")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("BEng Electronic Engineering with Music Technology Systems")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }

                Spacer(minLength: 40)

                //copyright footer
                Text("© 2025 Facundo Franchino. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Credit Section

//reusable section container for grouping related credits
//displays header with icon and list of credited items
struct CreditSection: View {
    //section title displayed in header
    let title: String

    //sf symbol name for the section icon
    let icon: String

    //colour for the section icon
    let iconColor: Color

    //array of individual credit items to display
    let credits: [CreditItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            //section header with icon and title
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }

            //list of credit items
            VStack(spacing: 8) {
                ForEach(credits, id: \.name) { credit in
                    HStack(alignment: .top, spacing: 12) {
                        //checkmark icon for each credit
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 2)

                        //credit name and description
                        VStack(alignment: .leading, spacing: 2) {
                            Text(credit.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(credit.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Credit Item

//data structure for individual credit attribution
struct CreditItem {
    //name of the credited item or technology
    let name: String

    //description or attribution details
    let description: String
}

#Preview {
    ProfileView()
}
