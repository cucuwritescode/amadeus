========
Overview
========

What is Amadeus?
================

Amadeus is an iOS application designed to help musicians understand and practise harmony. It analyses audio to display chord progressions in time with the music, and offers accessible tools for playback, navigation, and transposition during practice. Alongside this, the app includes a harmony library containing chord types, scales, and common progressions, giving users a reference guide as they work.

Amadeus is a practice companion for musicians who want to understand the harmonic shape of the music they play and study. The app analyses an audio file supplied by the user or a short recording made inside the app and returns a chord timeline, key estimate, playback controls, and a library of harmony resources.

Core Capabilities
=================

Audio Input Methods
-------------------

1. **File Upload**: Support for common audio formats (WAV, MP3, M4A, AAC, FLAC)
2. **Live Recording**: Record audio directly in the app

Analysis Features
-----------------

**Chord Recognition**
   The app extracts note events from the audio and groups them into chord segments. These appear above the waveform so the harmonic changes can be followed as the track plays.

**Key Detection**
   A lightweight key-finding stage gives the user a starting point for understanding the tonal centre of the piece.

**Waveform Playback View**
   Users can play, pause, and seek through the recording. Skip-forwards and skip-backwards controls give fixed 5-second jumps for efficient practice.

**Transposition**
   Independent pitch transposition (±12 semitones) and speed control (0.5x-1.5x) using AudioKit's TimePitch and VariSpeed processors. Chords are automatically transposed to match the audio pitch shift.

Music Theory Library
--------------------

A structured reference section contains chord types, a repository of scales and modes, and popular chord progressions. This allows the user to connect the analysis to standard harmonic ideas. The Library uses structured Swift data models that specify the formula for each chord type, its symbol variants, a short explanatory text, and the exact piano keys to highlight.

Target Users
============

Amadeus is designed for instrumentalists, producers, and learners who benefit from a clear harmonic overview rather than relying on ear alone. It provides a tool that musicians can use in practice without requiring specialist hardware or prior knowledge of signal processing.

Technical Approach
==================

The system employs a multi-stage pipeline:

1. **Audio Preprocessing**: Normalisation, resampling, and format conversion
2. **Note Detection**: ML-based polyphonic pitch detection
3. **Chord Assembly**: Algorithm to derive chords from detected notes
4. **Post-processing**: Temporal smoothing and confidence weighting
5. **Visualisation**: Real-time display in the iOS interface

Design Philosophy
=================

Amadeus prioritises:

* **Accuracy**: Reliable chord detection across various musical styles
* **Usability**: Intuitive interface for musicians of all levels
* **Performance**: Responsive analysis with minimal latency
* **Education**: Comprehensive theory resources alongside analysis tools
* **Flexibility**: Support for various audio sources and formats

Development Status
==================

Amadeus development began in early August 2025 and this formative version sets out the core user experience, combining automatic analysis with beginner-friendly learning material, with room for later improvements in accuracy, interaction, and educational depth.

**Core Features Completed (December 2025):**

* ✅ iOS application with SwiftUI interface
* ✅ Python FastAPI server for audio analysis
* ✅ Three analysis modes: HTTP Server, CoreML Local, Simulation
* ✅ Basic Pitch integration for note transcription
* ✅ Advanced chord inference with key detection algorithms
* ✅ Chord detection pipeline with median filtering (window size 3)
* ✅ Comprehensive music theory library with Tonic integration
* ✅ Audio playback with AudioKit (speed and pitch control)
* ✅ File upload and recording capability
* ✅ Independent transposition and speed control
* ✅ Export options (text format, MIDI planned)

**Planned Developments (2026):** See :doc:`future/roadmap`