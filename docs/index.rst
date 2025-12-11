.. Amadeus documentation master file

=====================================================
Amadeus - Automatic Chord Recognition in iOS
=====================================================

.. raw:: html

   <div style="text-align: center; margin: 2em 0;">
      <img src="_static/amadeuslogo.png" alt="Amadeus Logo" style="max-width: 200px; height: auto;">
   </div>

.. image:: https://img.shields.io/badge/iOS-18.0+-blue.svg
   :target: https://developer.apple.com/ios/
   :alt: iOS Version

.. image:: https://img.shields.io/badge/Swift-5.0-orange.svg
   :target: https://swift.org/
   :alt: Swift Version

.. image:: https://img.shields.io/badge/Python-3.8+-green.svg
   :target: https://www.python.org/
   :alt: Python Version

.. important::
   **Amadeus** is an iOS application designed for musicians to analyse recorded or uploaded audio, retrieve chord progressions, estimate musical keys, and explore a comprehensive music theory library. The system combines a SwiftUI frontend with a Python analysis server utilising DSP and machine learning techniques for chord recognition.

.. note::
   **Development Timeline:** Started early August 2025 • Current Version: December 2025 • Future Roadmap: 2026+

.. toctree::
   :maxdepth: 2
   :caption: Overview
   :hidden:

   overview
   quickstart
   installation

.. toctree::
   :maxdepth: 2
   :caption: System Architecture
   :hidden:

   architecture
   design_rationale
   technical_background

.. toctree::
   :maxdepth: 2
   :caption: iOS Application
   :hidden:

   ios/structure

.. toctree::
   :maxdepth: 2
   :caption: Python Server
   :hidden:

   server/api

.. toctree::
   :maxdepth: 2
   :caption: Analysis Pipeline
   :hidden:

   pipeline/chord_detection

.. toctree::
   :maxdepth: 2
   :caption: Music Theory Library
   :hidden:

   theory/chord_dictionary

.. toctree::
   :maxdepth: 2
   :caption: Future Work
   :hidden:

   future/roadmap

.. toctree::
   :maxdepth: 1
   :caption: Appendix
   :hidden:

   acknowledgements
   references

Key Features
============

User Features
-------------

* **Audio Analysis**: Load audio files or record up to 30 seconds for analysis
* **Chord Timeline**: Visual timeline with chord progressions, smoothing, and confidence metrics
* **Key Estimation**: Automatic detection of musical key and mode
* **Transposition**: Transform detected chords to different keys
* **Music Theory Library**: Comprehensive chord types, scales, and progressions
* **Export Options**: Share analysis results and export to MIDI (planned)

Technical Features
------------------

* **Hybrid Architecture**: SwiftUI iOS app with Python FastAPI backend
* **ML-Based Analysis**: Leverages Spotify's Basic Pitch model for note detection
* **Chord Assembly**: Sophisticated algorithm for deriving chords from note events
* **Confidence Scoring**: Weighted confidence metrics for detected chords
* **Smoothing Filters**: Temporal smoothing for stable chord detection

Quick Links
===========

* :doc:`quickstart` - Get started with Amadeus
* :doc:`architecture` - System architecture overview
* :doc:`ios/structure` - iOS app documentation
* :doc:`server/api` - Server API reference
* :doc:`future/roadmap` - Development roadmap

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`