import SwiftUI

struct SettingsView: View {
    @AppStorage("analysisMode") private var analysisMode = "http"
    @AppStorage("serverURL") private var serverURL = "http://192.168.68.121:8000"
    @State private var customURL = ""
    @State private var showingServerTest = false
    @State private var serverStatus = "Not tested"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Analysis Engine")) {
                    Picker("Mode", selection: $analysisMode) {
                        Text("HTTP Server").tag("http")
                        Text("CoreML (Local)").tag("coreml") 
                        Text("Simulation").tag("simulation")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if analysisMode == "http" {
                    Section(header: Text("Server Configuration")) {
                        HStack {
                            Text("Server URL:")
                            TextField("http://localhost:8000", text: $serverURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        HStack {
                            Button("Test Connection") {
                                testServerConnection()
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button("Reset URL") {
                                BasicPitchConfig.resetToDefaults()
                                serverURL = BasicPitchConfig.defaultServerURL
                                serverStatus = "Reset to default"
                            }
                            .foregroundColor(.orange)
                        }
                        
                        Text("Status: \(serverStatus)")
                            .font(.caption)
                            .foregroundColor(serverStatusColor)
                    }
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HTTP Server Mode")
                            .font(.headline)
                        Text("Uses Spotify's Basic Pitch Python implementation via a local server. Provides the most accurate transcription results.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("CoreML Mode")
                            .font(.headline)
                            .padding(.top)
                        Text("Uses a CoreML conversion of Basic Pitch for on-device processing. May have reduced accuracy compared to the Python version.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Simulation Mode")
                            .font(.headline)
                            .padding(.top)
                        Text("Generates realistic chord progressions for testing and development.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private var serverStatusColor: Color {
        switch serverStatus {
        case "Connected":
            return .green
        case "Failed":
            return .red
        default:
            return .secondary
        }
    }
    
    private func testServerConnection() {
        Task {
            await MainActor.run {
                serverStatus = "Testing..."
            }
            
            do {
                guard let url = URL(string: "\(serverURL)/health") else {
                    await MainActor.run {
                        serverStatus = "Invalid URL"
                    }
                    return
                }
                
                let (_, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    await MainActor.run {
                        serverStatus = "Connected"
                    }
                } else {
                    await MainActor.run {
                        serverStatus = "Failed"
                    }
                }
            } catch {
                await MainActor.run {
                    serverStatus = "Failed"
                }
            }
        }
    }
}