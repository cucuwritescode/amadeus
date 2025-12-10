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
                        Image(systemName: "moon.circle")
                            .foregroundColor(.indigo)
                        Text("Dark Mode")
                        Spacer()
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
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
                    
                    HStack {
                        Image(systemName: "waveform.circle")
                            .foregroundColor(.blue)
                        Text("Auto-Analyse on Import")
                        Spacer()
                        Toggle("", isOn: $autoAnalysis)
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
                    NavigationLink(destination: Text("Help & Tutorials")) {
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
                    
                    NavigationLink(destination: Text("Privacy Policy")) {
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