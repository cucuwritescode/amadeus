import SwiftUI

//main analysis view for audio file processing and chord detection
struct AnalyseView: View {
    //audio manager for playback and analysis
    @ObservedObject var audioManager: AudioManager
    //shows file picker sheet
    @State private var showFilePicker = false
    //shows recording view sheet
    @State private var showRecordingView = false
    //navigation flag for results
    @State private var navigateToResults = false
    
    //animation states
    @State private var logoScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 20
    @State private var buttonsOffset: CGFloat = 30
    @State private var buttonsOpacity: Double = 0
    
    //timeline entrance animation states
    @State private var timelineOpacity: Double = 0
    @State private var timelineOffset: CGFloat = 50
    
    var body: some View {
        NavigationView {
            ZStack {
                //background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if !audioManager.isFileLoaded {
                    //import screen
                    VStack(spacing: 40) {
                        Spacer()
                        
                        //logo/title with animations
                        VStack(spacing: 8) {
                            Image("amadeuslogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .scaleEffect(logoScale)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: logoScale)
                            
                            Text("Amadeus")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .opacity(titleOpacity)
                                .animation(.easeOut(duration: 0.5).delay(0.2), value: titleOpacity)
                            
                            Text("Harmonic Analysis & Learning")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .offset(y: subtitleOffset)
                                .opacity(titleOpacity)
                                .animation(.easeOut(duration: 0.5).delay(0.3), value: subtitleOffset)
                        }
                        
                        Spacer()
                        
                        //main actions
                        VStack(spacing: 16) {
                            //import audio button
                            Button(action: { showFilePicker = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.title2)
                                    Text("Import Audio File")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            
                            //record audio button
                            Button(action: { showRecordingView = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "mic.circle")
                                        .font(.title2)
                                    Text("Record New")
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding(.horizontal, 40)
                        .offset(y: buttonsOffset)
                        .opacity(buttonsOpacity)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: buttonsOffset)
                        
                        Spacer()
                        
                        // Status
                        Text(audioManager.statusMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    }
                } else {
                    // Navigate to Timeline View with entrance animation
                    TimelineView(audioManager: audioManager)
                        .opacity(timelineOpacity)
                        .offset(y: timelineOffset)
                        .animation(.easeOut(duration: 0.6), value: timelineOpacity)
                        .onAppear {
                            // Only animate in if analysis is not currently running
                            if !audioManager.showAnalysisLoading && !audioManager.analysisManager.isAnalyzing {
                                withAnimation(.easeOut(duration: 0.6)) {
                                    timelineOpacity = 1.0
                                    timelineOffset = 0
                                }
                            }
                        }
                }
                
                // Analysis Loading Overlay
                if audioManager.showAnalysisLoading {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        AnalysisLoadingView(
                            title: "Chord Analysis...",
                            subtitle: audioManager.analysisManager.analysisStatus
                        )
                    }
                    .transition(.opacity)
                }
                
                // Analysis Completion Overlay
                if audioManager.showAnalysisComplete {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        AnalysisCompletionView(
                            title: "Analysis Complete!",
                            subtitle: "Key: \(audioManager.originalKey) • \(audioManager.analysisManager.chordDetections.count) chords detected"
                        ) {
                            audioManager.showAnalysisComplete = false
                            
                            // Trigger timeline entrance animation after completion
                            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                                timelineOpacity = 1.0
                                timelineOffset = 0
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
            .navigationBarHidden(!audioManager.isFileLoaded)
            .sheet(isPresented: $showFilePicker) {
                DocumentPicker { url in
                    audioManager.loadFile(url)
                }
            }
            .sheet(isPresented: $showRecordingView) {
                RecordingView(audioManager: audioManager)
            }
            .onAppear {
                // Trigger entrance animations
                withAnimation {
                    logoScale = 1.0
                    titleOpacity = 1.0
                    subtitleOffset = 0
                    buttonsOffset = 0
                    buttonsOpacity = 1.0
                }
            }
            .onChange(of: audioManager.showAnalysisLoading) { isLoading in
                if isLoading {
                    //reset timeline animation when analysis starts
                    timelineOpacity = 0
                    timelineOffset = 50
                }
            }
            .onChange(of: audioManager.isFileLoaded) { isLoaded in
                if !isLoaded {
                    //cleanup analysis state when file is unloaded
                    audioManager.analysisManager.reset()
                    audioManager.showAnalysisLoading = false
                    audioManager.showAnalysisComplete = false
                    
                    //reset timeline animation state
                    timelineOpacity = 0
                    timelineOffset = 50
                }
            }
        }
    }
}
