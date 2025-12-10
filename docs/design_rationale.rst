=================
Design Rationale
=================

Project Evolution
=================

Amadeus has undergone significant architectural changes and experimentation since the start of the project in early August.
This page documents the key design decisions and their rationales.

Early Experiments - NMF, CQT and an Initial Plan for Live Detection
===============================================================================

The project began with an ambition to detect chords in real time. The first prototypes used non-negative matrix factorisation on short windows of audio. The method worked in simple cases but broke down as soon as the texture increased. It often produced incomplete or unstable decompositions and was too unpredictable to form the core of an application intended for musicians.

I then tested a constant Q transform front end that produced chroma features. This was more stable but still struggled with dense mixes and did not recover the clarity required for reliable chord identification. These experiments made clear that real time multi-pitch tracking is difficult to do well, especially on mobile devices, and that most musicians gain more from analysing recorded material than from attempting to track harmony while playing.

Later Shift to File-Based Analysis
=====================================

At this stage the project shifted to a file-based system with a clean separation between transcription and harmonic analysis. This choice allowed evaluation of different transcription methods without disturbing the rest of the codebase.

The decision to move away from real-time detection was based on several factors:

* **Technical Complexity**: Real-time polyphonic tracking proved difficult to implement reliably, especially on mobile devices
* **User Needs**: Most musicians gain more from analysing recorded material than from attempting to track harmony while playing
* **System Stability**: File-based processing allows for more robust analysis and better user experience

Stage 3: Incorporating a Lightweight Transcription Model
========================================================

For the present submission the app uses Basic Pitch by Spotify which is a compact convolutional architecture designed to perform automatic music transcription in low resource settings. The model operates on a constant Q transform with three bins per semitone and forms an approximation of a harmonic CQT by vertically shifting the spectrogram to align harmonically related frequencies.

This gives the model access to local patterns that reflect the structure of pitched sound. It produces three time-frequency maps that indicate onsets, sustained notes and multi-pitch activity. Onset peaks are extracted and matched to sustained activity by a post-processing procedure. Notes shorter than roughly one hundred and twenty milliseconds are removed. The output is a set of note events defined by onset time, pitch and duration.

**Important Note on Temporary Implementation**

It is important to stress that this is a temporary solution used only for this stage of development. The architecture of Amadeus does not depend on Basic Pitch itself but on the fact that it produces symbolic note events in a consistent format. This makes it possible to replace the transcription layer with a custom model or a more advanced method when time and resources allow.


Chord Assembly Algorithm
========================

Custom Post-Processing
----------------------

Rather than using Basic Pitch's chord detection, we developed custom logic:

**Rationale:**

1. **Domain Control**: Fine-tune for our use cases
2. **Transparency**: Understandable algorithm
3. **Flexibility**: Easy to modify rules
4. **Integration**: Better iOS integration

**Algorithm Features:**

* Pitch class histograms
* Confidence weighting
* Temporal smoothing
* Root note detection
* Chord quality inference

Music Theory Library
====================

Standalone Feature
------------------

The theory library operates independently of ML:

**Benefits:**

1. **Educational Value**: Learning resource
2. **Offline Access**: No server required
3. **Reference Tool**: Quick lookups
4. **User Engagement**: Increases app value

**Implementation:**

* Static Swift data structures
* Programmatic chord generation
* Interactive visualizations
* Audio synthesis for playback

Future Development (2026)
=========================

Source Separation Integration
-----------------------------

Testing showed that the system performs well on recordings with relatively sparse textures but struggles when several instruments mask one another. This motivates the introduction of a source separation stage that extracts a cleaner harmonic component before transcription. This would replace the unused Live Detection view with a stem preview and selection interface.

Since the rest of the pipeline expects only symbolic note events, this addition fits naturally into the current design.

Architectural Foundation
------------------------

Amadeus is arranged as three independent layers:

1. **Transcription Layer**: Converts audio into symbolic events
2. **Analysis Layer**: Interprets these events as harmony  
3. **SwiftUI Views**: Present the results

This structure is a direct consequence of the failed spectral prototypes and now provides a stable foundation for future work.

Technical Foundations
=====================

Harmonic Analysis Pipeline
--------------------------

Once the symbolic events arrive from the server they are grouped into short time windows. Root candidates are tested, and the pitch classes are matched against templates for the chord types stored in the Dictionary. A small smoothing step removes brief fluctuations. Key estimation is performed on a pitch class profile aggregated over the piece.

Transposition is carried out by shifting the pitch classes modulo twelve before regenerating the labels. The pipeline is kept separate from the view layer so that any improvement in the transcription model automatically flows into the rest of the system.

Technical Debt
--------------

Areas for improvement:

* Error handling robustness
* Comprehensive test coverage
* Performance profiling
* Documentation completeness
* Accessibility features

Validation
==========

The current architecture has been validated through:

* Successful processing of diverse audio
* Positive user feedback on accuracy
* Reasonable response times (<5s)
* Stable operation across devices
* Clear upgrade path for enhancements