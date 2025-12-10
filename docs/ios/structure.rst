====================
iOS App Structure
====================

The Amadeus iOS application follows a clean MVVM (Model-View-ViewModel) architecture with clear separation of concerns.

Project Organisation
====================

.. code-block:: text

    Amadeus-Fresh/amadeus/
    ├── amadeusApp.swift           # App entry point
    ├── MainTabView.swift          # Root navigation
    ├── Models/                    # Data models and business logic
    │   ├── AudioManager.swift
    │   ├── AnalysisManager.swift
    │   ├── ChordDetectionPipeline.swift
    │   ├── BasicPitchHTTPClient.swift
    │   ├── ChordAssembler.swift
    │   ├── ChordDictionary.swift
    │   ├── ScaleDictionary.swift
    │   └── ...
    ├── Views/                     # SwiftUI views
    │   ├── Tabs/                  # Main tab views
    │   │   ├── AnalyseView.swift
    │   │   ├── LibraryView.swift
    │   │   ├── LiveView.swift
    │   │   └── ProfileView.swift
    │   ├── PlaybackView.swift
    │   ├── ChordTimelineView.swift
    │   ├── RecordingView.swift
    │   └── ...
    ├── Styles/                    # UI styling
    │   └── AppStyles.swift
    └── Assets.xcassets/           # Images and colors

App Entry Point
===============

amadeusApp.swift
----------------

The main application entry point configuring the SwiftUI app lifecycle:

.. code-block:: swift

    @main
    struct amadeusApp: App {
        @StateObject private var audioManager = AudioManager()
        @StateObject private var analysisManager = AnalysisManager()
        
        var body: some Scene {
            WindowGroup {
                MainTabView()
                    .environmentObject(audioManager)
                    .environmentObject(analysisManager)
            }
        }
    }

Navigation Structure
====================

MainTabView.swift
-----------------

The root navigation container implementing tab-based navigation:

.. code-block:: swift

    struct MainTabView: View {
        @State private var selectedTab = 0
        
        var body: some View {
            TabView(selection: $selectedTab) {
                AnalyseView()
                    .tabItem {
                        Label("Analyse", systemImage: "waveform")
                    }
                    .tag(0)
                
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
                    .tag(1)
                
                LiveView()
                    .tabItem {
                        Label("Live", systemImage: "mic.fill")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
        }
    }

Core Managers
=============

AudioManager
------------

Handles all audio playback and session management:

**Responsibilities:**

* Audio file loading and playback
* Seek and scrub operations
* Audio session configuration
* Volume and rate control
* Playback state management

**Key Methods:**

.. code-block:: swift

    class AudioManager: ObservableObject {
        @Published var isPlaying = false
        @Published var currentTime: TimeInterval = 0
        @Published var duration: TimeInterval = 0
        
        func loadAudio(from url: URL)
        func play()
        func pause()
        func seek(to time: TimeInterval)
        func skip(by seconds: TimeInterval)
    }

AnalysisManager
---------------

Coordinates the analysis workflow:

**Responsibilities:**

* Triggering server analysis
* Managing analysis state
* Caching results
* Error handling
* Progress tracking

**Key Properties:**

.. code-block:: swift

    class AnalysisManager: ObservableObject {
        @Published var isAnalyzing = false
        @Published var analysisProgress: Double = 0
        @Published var currentAnalysis: AnalysisResult?
        @Published var analysisError: Error?
        
        func analyzeAudio(at url: URL) async
        func cancelAnalysis()
    }

ChordDetectionPipeline
----------------------

Local chord processing and refinement:

**Features:**

* Post-processing server results
* Temporal smoothing
* Confidence calculation
* Key estimation refinement

View Components
===============

Tab Views
---------

**AnalyseView**
   Primary interface for audio analysis featuring:
   
   * File selection/recording
   * Analysis triggering
   * Results visualisation
   * Playback controls

**LibraryView**
   Music theory reference containing:
   
   * Chord dictionary
   * Scale explorer
   * Progression library
   * Circle of fifths

**LiveView**
   Real-time detection interface (future):
   
   * Microphone input
   * Live chord display
   * Tuner functionality

**ProfileView**
   User settings and preferences:
   
   * Account management
   * App settings
   * Export options
   * About section

Specialised Views
-----------------

**ChordTimelineView**
   Interactive chord progression visualisation:
   
   * Horizontal timeline
   * Color-coded chords
   * Confidence indicators
   * Tap-to-seek interaction

**PlaybackView**
   Audio control interface:
   
   * Play/pause button
   * Progress slider
   * Time display
   * Skip controls

**RecordingView**
   Audio recording interface with 30-second limit:
   
   * Record button
   * Level meters
   * 30-second duration limit
   * Save/discard options
   * Temporary storage before analysis

Data Models
===========

Core Structures
---------------

**ChordDetection**

.. code-block:: swift

    struct ChordDetection: Codable {
        let chord: String
        let startTime: TimeInterval
        let endTime: TimeInterval
        let confidence: Double
        let pitchClasses: Set<Int>
    }

**AnalysisResult**

.. code-block:: swift

    struct AnalysisResult {
        let chords: [ChordDetection]
        let key: String
        let mode: String
        let tempo: Double?
        let duration: TimeInterval
    }

**NoteEvent**

.. code-block:: swift

    struct NoteEvent {
        let pitch: Int
        let startTime: TimeInterval
        let endTime: TimeInterval
        let velocity: Float
        let confidence: Float
    }

Networking
==========

BasicPitchHTTPClient
--------------------

Handles server communication:

**Features:**

* Multipart form data encoding
* JSON response parsing
* Error handling
* Retry logic
* Progress tracking

**Key Methods:**

.. code-block:: swift

    class BasicPitchHTTPClient: ChordAnalyzer {
        func analyzeAudio(
            audioData: Data,
            sampleRate: Double
        ) async throws -> AnalysisResult
        
        private func encodeWAV(
            from audioData: Data,
            sampleRate: Double
        ) -> Data
    }

State Management
================

The app uses SwiftUI's state management system:

* ``@StateObject``: Manager lifecycle
* ``@EnvironmentObject``: Dependency injection
* ``@Published``: Observable properties
* ``@State``: View-local state
* ``@Binding``: Two-way data flow

Error Handling
==============

Comprehensive error handling throughout:

.. code-block:: swift

    enum AnalysisError: LocalizedError {
        case networkError(Error)
        case serverError(String)
        case invalidAudioFormat
        case fileTooLarge
        case analysisTimeout
        
        var errorDescription: String? {
            switch self {
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .serverError(let message):
                return "Server error: \(message)"
            case .invalidAudioFormat:
                return "Unsupported audio format"
            case .fileTooLarge:
                return "Audio file is too large"
            case .analysisTimeout:
                return "Analysis timed out"
            }
        }
    }

