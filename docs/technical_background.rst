====================
Technical Background
====================

This section provides the technical foundation behind Amadeus, detailing the research and engineering decisions that inform the current implementation.

Automatic Chord Recognition Overview
=====================================

Automatic chord recognition (ACR) is a well-established field in music information retrieval that aims to identify chord symbols from audio signals. The task involves analysing complex polyphonic audio and reducing it to symbolic harmonic information that musicians can understand and use.

Historical Context
==================

Traditional Approaches
-----------------------

Early ACR systems typically followed a pattern recognition approach:

1. **Feature Extraction**: Convert audio to pitch class profiles (chromagrams)
2. **Template Matching**: Compare features against known chord templates  
3. **Post-processing**: Apply smoothing and context-aware corrections

These methods worked reasonably well for simple musical textures but struggled with:

* Dense polyphonic arrangements
* Overlapping harmonies
* Non-harmonic tones
* Varying timbres and dynamics

Machine Learning Era
--------------------

The introduction of machine learning, particularly deep learning, has significantly improved ACR performance. Modern systems can learn complex patterns from large datasets and generalise better across different musical styles and recording conditions.

Basic Pitch Model
=================

Architecture Overview
---------------------

Amadeus uses Spotify's Basic Pitch model, specifically chosen for its lightweight design and robust performance. The model is a compact convolutional architecture designed for automatic music transcription in resource-constrained settings.

**Key Characteristics:**

* **Convolutional Neural Network**: Optimised for time-frequency pattern recognition
* **Multi-task Learning**: Simultaneously detects onsets, frames, and velocity
* **Compact Design**: Suitable for deployment in mobile applications
* **Genre Agnostic**: Trained on diverse musical content

Technical Implementation
------------------------

**Constant-Q Transform Frontend**

The model operates on a constant-Q transform (CQT) with three bins per semitone. This provides:

* Logarithmic frequency spacing that matches musical perception
* High frequency resolution in lower registers
* Compact representation suitable for neural network processing

**Harmonic CQT Approximation**

Basic Pitch forms an approximation of a harmonic CQT by vertically shifting the spectrogram to align harmonically related frequencies. This technique:

* Emphasises harmonic relationships in the input representation
* Provides the model access to local patterns reflecting pitched sound structure
* Reduces the complexity of learning harmonic relationships

**Multi-Stream Output**

The model produces three time-frequency maps:

1. **Onset Map**: Indicates note beginnings
2. **Frame Map**: Shows sustained note activity  
3. **Velocity Map**: Estimates note intensities

**Post-Processing Pipeline**

* Onset peaks are extracted from the onset map
* Peaks are matched to sustained activity in the frame map
* Notes shorter than approximately 120ms are filtered out
* Output format: symbolic note events with onset time, pitch (MIDI), and duration

Why Basic Pitch for Amadeus?
=============================

Temporary Solution
------------------

It's crucial to understand that Basic Pitch integration represents a temporary solution for the current development phase. The choice was pragmatic rather than aspirational:

**Advantages for Rapid Prototyping:**

* **Proven Performance**: Extensively tested across diverse musical content
* **Ready Deployment**: Available as a Python package with minimal setup
* **Consistent Output**: Reliable symbolic note event format
* **Documentation**: Well-documented API and usage patterns

**Strategic Flexibility:**

The architecture of Amadeus deliberately separates transcription from harmonic analysis. This design choice means:

* The transcription layer can be replaced without affecting other components
* Different models can be A/B tested easily
* Custom models can be integrated when resources permit
* The system remains model-agnostic at the architectural level

Limitations and Future Directions
==================================

Current Limitations
-------------------

While Basic Pitch provides a solid foundation, it has known limitations:

* **Complex Textures**: Performance degrades with dense instrumental arrangements
* **Extreme Registers**: Less accurate in very high or low frequency ranges
* **Percussive Content**: Not optimised for non-pitched instruments
* **Real-time Constraints**: Not designed for low-latency applications

Research Directions (2026+)
---------------------------

**Custom Model Development**

Future development will focus on training custom models specifically for chord recognition:

* **Domain-Specific Training**: Models trained on chord-focused datasets
* **Multi-Task Learning**: Joint training on transcription and harmonic analysis
* **Efficient Architectures**: Mobile-optimised designs for on-device inference

**Source Separation Integration**

The planned source separation component addresses current texture complexity issues:

* **Harmonic Isolation**: Extract chord-carrying instruments from mixes
* **Stem-Based Analysis**: Analyse individual instrument groups separately
* **User Control**: Allow musicians to focus on specific harmonic content

Engineering Considerations
==========================

Mobile Deployment Challenges
-----------------------------

Deploying ACR on mobile devices presents unique constraints:

**Computational Limits**

* Limited processing power compared to servers
* Battery consumption considerations
* Memory constraints for model storage
* Real-time performance requirements

**Model Optimisation Techniques**

* **Quantisation**: Reduce model precision while maintaining accuracy
* **Pruning**: Remove unnecessary model parameters  
* **Knowledge Distillation**: Train smaller models from larger teachers
* **Hardware Acceleration**: Leverage GPU/NPU capabilities

**Current Server-Based Approach**

The decision to deploy Basic Pitch server-side rather than on-device was driven by:

* **Model Size**: Basic Pitch requires significant storage space
* **Consistency**: Ensure identical results across all devices
* **Flexibility**: Easy model updates without app store approval
* **Development Speed**: Faster iteration during research phase

Quality Assurance
=================

Evaluation Metrics
------------------

ACR systems are typically evaluated using:

**Chord-Level Metrics**

* **Chord Accuracy**: Percentage of correctly identified chords
* **Root Accuracy**: Accuracy of chord root identification
* **Quality Accuracy**: Accuracy of chord quality (major, minor, etc.)

**Time-Aware Metrics**

* **Weighted Chord Accuracy**: Accuracy weighted by chord duration
* **Segmentation Accuracy**: Correctness of chord boundary detection
* **Overlap Metrics**: Intersection over union for temporal segments

**Perceptual Evaluation**

* **Musician Studies**: Subjective evaluation by human experts
* **Practice Utility**: Effectiveness for musical practice and learning
* **Error Analysis**: Classification of failure modes and their impact

Performance Characteristics
===========================

Current System Performance
--------------------------

Based on informal testing with the current Basic Pitch implementation:

**Accuracy by Genre:**

* **Pop/Rock**: ~70-75% chord accuracy on clear recordings
* **Jazz Standards**: ~60-65% accuracy (complex harmony challenges)
* **Classical**: Variable (50-70% depending on texture complexity)
* **Folk/Acoustic**: ~75-80% accuracy (simpler arrangements)

**Temporal Resolution:**

* **Processing Speed**: ~2-5 seconds for 3-minute audio file
* **Latency**: Server round-trip typically <3 seconds
* **Chord Granularity**: Minimum chord duration ~0.5 seconds

**Known Failure Modes:**

* Dense orchestral arrangements
* Heavily distorted recordings
* Atonal or chromatic music
* Solo percussion

Future Research Integration
===========================

N8 CiR Collaboration
--------------------

The project benefits from upcoming research funding through N8 CiR (N8 Centre of Excellence in Computationally Intensive Research). This collaboration will enable:

* **Algorithm Development**: Custom ACR algorithms optimised for mobile deployment
* **Dataset Creation**: Curated training data for chord recognition tasks
* **Evaluation Framework**: Systematic testing across musical genres and recording conditions
* **Publication Pipeline**: Research contributions to the ACR field

This academic partnership ensures that Amadeus will evolve beyond the current prototype towards a research-informed, production-ready system that advances the state of the art in mobile music analysis.