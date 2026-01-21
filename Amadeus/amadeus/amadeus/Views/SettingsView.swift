//
//  SettingsView.swift
//  amadeus
//
//  created by facundo franchino on 20/10/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  configuration view for analysis engine mode and server settings
//  allows switching between http, coreml, and simulation modes
//
//  acknowledgements:
//  - settings form follows ios human interface guidelines
//  - analysis modes correspond to basicpitchconfig options
//

import SwiftUI

// MARK: - Settings View

//settings interface for configuring analysis backend and preferences
//provides mode selection, server configuration, and mode descriptions
struct SettingsView: View {
    //persisted analysis mode selection (http, coreml, or simulation)
    @AppStorage("analysisMode") private var analysisMode = "http"

    //persisted server url for http mode
    @AppStorage("serverURL") private var serverURL = "http://192.168.68.121:8000"

    //temporary storage for custom url input (not currently used)
    @State private var customURL = ""

    //controls visibility of server test ui
    @State private var showingServerTest = false

    //current server connection status message
    @State private var serverStatus = "Not tested"

    var body: some View {
        NavigationView {
            Form {
                //analysis engine mode selection section
                Section(header: Text("Analysis Engine")) {
                    //segmented picker for choosing analysis backend
                    Picker("Mode", selection: $analysisMode) {
                        Text("HTTP Server").tag("http")
                        Text("CoreML (Local)").tag("coreml")
                        Text("Simulation").tag("simulation")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                //server configuration section (only shown in http mode)
                if analysisMode == "http" {
                    Section(header: Text("Server Configuration")) {
                        //server url input field
                        HStack {
                            Text("Server URL:")
                            TextField("http://localhost:8000", text: $serverURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }

                        //test and reset buttons row
                        HStack {
                            //test connection button
                            Button("Test Connection") {
                                testServerConnection()
                            }
                            .foregroundColor(.blue)

                            Spacer()

                            //reset url to default button
                            Button("Reset URL") {
                                BasicPitchConfig.resetToDefaults()
                                serverURL = BasicPitchConfig.defaultServerURL
                                serverStatus = "Reset to default"
                            }
                            .foregroundColor(.orange)
                        }

                        //connection status display
                        Text("Status: \(serverStatus)")
                            .font(.caption)
                            .foregroundColor(serverStatusColor)
                    }
                }

                //about section explaining each analysis mode
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        //http server mode description
                        Text("HTTP Server Mode")
                            .font(.headline)
                        Text("Uses Spotify's Basic Pitch Python implementation via a local server. Provides the most accurate transcription results.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        //coreml mode description
                        Text("CoreML Mode")
                            .font(.headline)
                            .padding(.top)
                        Text("Uses a CoreML conversion of Basic Pitch for on-device processing. May have reduced accuracy compared to the Python version.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        //simulation mode description
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

    //computed property returning colour based on connection status
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

    //tests server connection by hitting health endpoint
    private func testServerConnection() {
        Task {
            //show testing status immediately
            await MainActor.run {
                serverStatus = "Testing..."
            }

            do {
                //construct health check url
                guard let url = URL(string: "\(serverURL)/health") else {
                    await MainActor.run {
                        serverStatus = "Invalid URL"
                    }
                    return
                }

                //attempt to fetch health endpoint
                let (_, response) = try await URLSession.shared.data(from: url)

                //check for successful response
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
                //network error occurred
                await MainActor.run {
                    serverStatus = "Failed"
                }
            }
        }
    }
}