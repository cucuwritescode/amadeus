===================
Development Roadmap
===================

This roadmap outlines planned features and improvements for Amadeus, organised by priority and timeline.

Phase 1: Core Improvements (Q1 2026)
=====================================

Source Separation Integration
-----------------------------

**Goal**: Extract cleaner harmonic components before transcription

**Implementation**:

Testing showed that the system performs well on recordings with relatively sparse textures but struggles when several instruments mask one another. This motivates the introduction of a source separation stage that extracts a cleaner harmonic component before transcription.

* Replace unused Live Detection view with stem preview and selection interface
* Route isolated harmonic stem to chord recogniser
* Provide stems in app view for user selection

**Benefits**:

* Higher accuracy on mixed recordings
* Better handling of complex arrangements
* Fits naturally into current design since pipeline expects symbolic note events

Tempo Detection
---------------

**Goal**: Add BPM detection and beat tracking

**Implementation**:

* Use librosa's beat tracking: ``librosa.beat.beat_track()``
* Display BPM in analysis view
* Align chord changes to beat grid
* Enable quantised chord timing

**Features**:

* BPM display
* Time signature detection
* Beat-aligned chord grid
* Metronome sync option

Enhanced Chord Recognition
--------------------------

**Goal**: Improve chord detection algorithm

**Improvements**:

* Weighted root detection based on bass notes
* Context-aware prediction using HMM
* Genre-specific chord templates
* User-guided correction interface

Phase 2: User Experience (Q2 2026)
===================================

MIDI Export
-----------

**Goal**: Export analysis as MIDI files

**Features**:

* Chord progression as MIDI
* Detected melody as separate track
* Tempo and time signature metadata
* Compatible with DAWs

Collaboration Features
----------------------

**Goal**: Enable sharing and collaboration

**Features**:

* Share analysis via link
* Collaborative annotation
* Comments on timeline
* Version history

Practice Mode
-------------

**Goal**: Interactive learning features

**Features**:

* Play along with detected chords
* Loop sections for practice
* Slow down without pitch change
* Chord diagram overlays

Advanced Visualisation
----------------------

**Goal**: Richer analysis display

**Features**:

* Piano roll view
* Frequency spectrum display
* Chord progression graph
* Nashville number notation

Phase 3: Platform Expansion (Q3 2026)
======================================

On-Device Processing
--------------------

**Goal**: Remove server dependency

**Approach**:

* Convert models to CoreML
* Implement on-device inference
* Offline mode support
* Privacy-first architecture

**Challenges**:

* Model size optimisation
* Memory management
* Battery efficiency
* Performance tuning

Web Application
---------------

**Goal**: Browser-based version

**Features**:

* Progressive Web App (PWA)
* Cross-platform compatibility
* Cloud sync with iOS app
* Collaborative features

Android Application
-------------------

**Goal**: Android native app

**Implementation**:

* Kotlin/Jetpack Compose UI
* Shared server backend
* Feature parity with iOS
* Material Design 3

Desktop Applications
--------------------

**Goal**: Native desktop apps

**Platforms**:

* macOS (Catalyst or SwiftUI)
* Windows (React Native or Electron)
* Linux (Electron or Flutter)

Phase 4: Advanced Features (Q4 2026)
=====================================

Real-Time Mode
--------------

**Goal**: Live chord detection

**Requirements**:

* Low-latency processing
* Efficient buffering
* Noise-robust detection
* Visual feedback optimisation

**Use Cases**:

* Live performance analysis
* Jam session support
* Teaching applications
* Transcription assistance


Educational Content
-------------------

**Goal**: Integrated learning materials

**Content**:

* Interactive tutorials
* Music theory lessons
* Ear training exercises
* Video demonstrations

Phase 5: Professional Features (2027)
======================================


Batch Processing
----------------

**Goal**: Analyse multiple files

**Features**:

* Queue management
* Parallel processing
* Bulk export
* Playlist analysis

API Platform
------------

**Goal**: Developer ecosystem

**Features**:

* Public REST API
* WebSocket streaming
* SDKs for various languages
* Usage analytics

Advanced Music Theory
---------------------

**Goal**: Deeper analysis capabilities

**Features**:

* Roman numeral analysis
* Functional harmony detection
* Voice leading analysis
* Form analysis (verse, chorus, etc.)

Long-Term Vision
================

Research Initiatives
--------------------

* Custom neural networks for chord recognition
* Unsupervised learning from large music datasets
* Multi-modal analysis (audio + sheet music)
* Style transfer for chord progressions

Community Features
------------------

* User-contributed chord corrections
* Shared chord databases
* Community challenges
* Educational partnerships

Accessibility
-------------

* VoiceOver optimisation
* Haptic feedback for chords
* Visual impairment modes
* Simplified interfaces

Performance Targets
===================

By end of 2026:

* **Accuracy**: >85% on common genres
* **Speed**: <1 second per minute of audio
* **Platform**: iOS, Android, Web
* **Languages**: 5+ supported languages

Success Metrics
===============

* User retention rate
* Analysis accuracy scores
* Processing speed benchmarks
* User satisfaction ratings
* Community engagement levels

Technical Debt
==============

Items to address:

* Comprehensive test coverage
* Performance profiling
* Code documentation
* Security audit
* Accessibility audit

This roadmap is subject to changes. Based on user feedback, technical feasibility, and resource availability.