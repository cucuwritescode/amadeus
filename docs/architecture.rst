=====================
System Architecture
=====================

High-Level Overview
===================

Amadeus is arranged as three independent layers that provide clean separation between transcription and harmonic analysis:

.. code-block:: text

    ┌─────────────────────────────────────────────────────────┐
    │                   iOS Application (Swift)               │
    │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
    │  │   UI Layer   │  │   Managers   │  │    Models    │ │
    │  │   SwiftUI    │  │ AudioManager │  │ChordDetection│ │
    │  │    Views     │  │AnalysisMgr   │  │  Pipeline    │ │
    │  └──────────────┘  └──────────────┘  └──────────────┘ │
    └─────────────────────────┬───────────────────────────────┘
                              │ HTTPS
                              │ JSON
    ┌─────────────────────────▼───────────────────────────────┐
    │              Python Analysis Server (FastAPI)           │
    │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
    │  │   REST API   │  │ Basic Pitch  │  │Chord Inference│ │
    │  │  Endpoints   │  │    Model     │  │   Module     │ │
    │  └──────────────┘  └──────────────┘  └──────────────┘ │
    └──────────────────────────────────────────────────────────┘

Component Details
=================

iOS Application Layer
---------------------

The iOS application is built using Swift and SwiftUI, following MVVM architecture:

**Views Layer**
   * ``MainTabView``: Root navigation container
   * ``AnalyseView``: Audio analysis interface
   * ``LibraryView``: Music theory reference
   * ``LiveView``: Real-time detection (future)
   * ``ProfileView``: User settings and preferences

**Managers Layer**
   * ``AudioManager``: Handles playback, seeking, and audio session
   * ``AnalysisManager``: Coordinates analysis workflow
   * ``ChordDetectionPipeline``: Local chord assembly and post-processing

**Models Layer**
   * ``ChordDetection``: Chord data structure
   * ``NoteEvent``: Note representation
   * ``ChordDictionary``: Theory database
   * ``ScaleDictionary``: Scale definitions

**Network Layer**
   * ``BasicPitchHTTPClient``: Server communication
   * Multipart form data encoding
   * JSON response parsing

Python Server Layer
-------------------

The server uses FastAPI for high-performance async operations and integrates Spotify's Basic Pitch model:

**API Layer**
   * ``/analyze`` endpoint for audio processing
   * ``/health`` endpoint for status monitoring
   * CORS middleware for web compatibility

**Processing Pipeline**
   1. Audio file reception and validation
   2. Format conversion and normalisation
   3. Basic Pitch model inference (compact convolutional architecture)
   4. Note event extraction (onset time, pitch, duration)
   5. Chord inference from symbolic note events
   6. JSON response generation

**Core Modules**
   * ``main.py``: FastAPI application and endpoints
   * ``chord_inference.py``: Groups symbolic events into chord segments
   * Audio preprocessing handled by Basic Pitch model
   * Model produces time-frequency maps for onsets, sustained notes, and multi-pitch activity

Data Flow
=========

Request Flow
------------

.. code-block:: text

    1. User selects/records audio
         ↓
    2. iOS app encodes audio as WAV
         ↓
    3. HTTP POST to /analyze endpoint
         ↓
    4. Server processes audio
         ↓
    5. Basic Pitch generates note events
         ↓
    6. Chord inference from notes
         ↓
    7. JSON response to iOS app
         ↓
    8. Local smoothing and filtering
         ↓
    9. UI updates with results

Data Structures
---------------

**Audio Upload**::

    POST /analyze
    Content-Type: multipart/form-data
    
    audio_file: <binary WAV data>

**Server Response**::

    {
      "notes": [
        {
          "onset": 0.0,
          "offset": 0.5,
          "pitch": 60,
          "confidence": 0.95
        }
      ],
      "chords": [
        {
          "onset": 0.0,
          "offset": 2.0,
          "chord": "C",
          "confidence": 0.85,
          "pitch_classes": [0, 4, 7]
        }
      ],
      "key": {
        "key": "C",
        "mode": "major",
        "confidence": 0.75
      }
    }

Technology Stack
================

iOS Application
---------------

* **Language**: Swift 5.0+
* **UI Framework**: SwiftUI
* **Minimum iOS**: 18.0
* **Audio**: AVFoundation
* **Networking**: URLSession
* **ML**: CoreML (future)

Python Server
-------------

* **Language**: Python 3.8+
* **Web Framework**: FastAPI
* **ML Framework**: TensorFlow
* **Audio Processing**: librosa, soundfile
* **Model**: Spotify Basic Pitch
* **Server**: Uvicorn ASGI

Communication Protocol
----------------------

* **Protocol**: HTTPS
* **Data Format**: JSON
* **File Upload**: Multipart form data
* **Authentication**: Token-based (future)

Deployment Architecture
=======================

Development Environment
-----------------------

* iOS: Xcode with Swift Package Manager
* Server: Python virtual environment
* Local testing on same network

Production Environment
----------------------

* iOS: App Store distribution
* Server: Cloud deployment (AWS/GCP/Azure)
* CDN for static assets
* Load balancing for scalability

Security Considerations
=======================

* HTTPS encryption for all communication
* Input validation and sanitisation
* File size limits (50MB)
* Rate limiting (planned)
* Authentication tokens (planned)

Performance Optimisations
=========================

* Audio compression before upload
* Server-side caching of results
* Chunked processing for long files
* Parallel processing where possible
* CDN for model weights distribution

Scalability Design
==================

The architecture supports horizontal scaling:

* Stateless server design
* Queue-based processing (future)
* Microservice separation (future)
* Database for result storage (future)
* Container orchestration (future)