import SwiftUI

struct ProfileView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var notificationsEnabled = true
    @State private var autoAnalysis = false
    @State private var selectedAudioInput = "Built-in Microphone"
    
    // Learning stats (persisted)
    @AppStorage("songsAnalysed") private var songsAnalysed = 0
    @AppStorage("chordsLearned") private var chordsLearned = 0
    @AppStorage("practiceHours") private var practiceHours = 0.0
    
    let audioInputs = ["Built-in Microphone", "External Microphone", "Audio Interface"]
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
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
                
                // App Settings
                Section("App Settings") {
                    HStack {
                        Image(systemName: "bell.circle")
                            .foregroundColor(.orange)
                        Text("Notifications")
                        Spacer()
                        Toggle("", isOn: $notificationsEnabled)
                    }
                }
                
                // Audio Settings
                Section("Audio Settings") {
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
                    
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gearshape.circle")
                                .foregroundColor(.purple)
                            Text("Analysis Engine")
                        }
                    }
                }
                
                // Learning Settings
                Section("Learning") {
                    NavigationLink(destination: LearningStatsView()) {
                        HStack {
                            Image(systemName: "chart.bar.circle")
                                .foregroundColor(.green)
                            Text("Learning Stats")
                        }
                    }
                    
                    NavigationLink(destination: AchievementsView()) {
                        HStack {
                            Image(systemName: "star.circle")
                                .foregroundColor(.yellow)
                            Text("Achievements")
                        }
                    }
                    
                    NavigationLink(destination: Text("Practice Goals")) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.orange)
                            Text("Practice Goals")
                        }
                    }
                }
                
                // Support
                Section("Support") {
                    NavigationLink(destination: HelpTutorialsView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                            Text("Help & Tutorials")
                        }
                    }
                    
                    NavigationLink(destination: Text("Contact Us")) {
                        HStack {
                            Image(systemName: "envelope.circle")
                                .foregroundColor(.green)
                            Text("Contact Us")
                        }
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "lock.circle")
                                .foregroundColor(.gray)
                            Text("Privacy Policy")
                        }
                    }
                }
                
                // App Info
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hammer.circle")
                            .foregroundColor(.orange)
                        Text("Build")
                        Spacer()
                        Text("Dec 2025")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Sign Out
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

// Placeholder views for navigation
struct LearningStatsView: View {
    @AppStorage("songsAnalysed") private var songsAnalysed = 0
    @AppStorage("chordsLearned") private var chordsLearned = 0
    @AppStorage("practiceHours") private var practiceHours = 0.0
    @AppStorage("accuracy") private var accuracy = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
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

struct HelpTutorialsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Documentation Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "book.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("Documentation")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Access the complete Amadeus documentation for detailed guides on chord analysis, music theory, and app features.")
                            .foregroundColor(.secondary)
                        
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
                
                // Quick Tips Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        Text("Quick Tips")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TipCard(icon: "mic.fill", title: "Recording Tips", description: "Record in a quiet environment for best chord detection accuracy.")
                        TipCard(icon: "waveform", title: "Audio Quality", description: "Use clear, well-recorded audio files for optimal analysis results.")
                        TipCard(icon: "music.note", title: "Chord Analysis", description: "The app works best with acoustic instruments and clear chord progressions.")
                    }
                }
                
                Divider()
                
                // Contact Section
                VStack(alignment: .leading, spacing: 16) {
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

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
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

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Last updated: December 2025")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
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

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 8)
    }
}

struct AchievementsView: View {
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
                    Image(systemName: unlocked ? "star.circle.fill" : "star.circle")
                        .foregroundColor(unlocked ? .yellow : .gray)
                        .font(.title2)
                    
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

#Preview {
    ProfileView()
}