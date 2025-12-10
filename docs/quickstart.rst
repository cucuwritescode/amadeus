==========
Quickstart
==========

This guide will help you get Amadeus up and running quickly.

.. tip::
   **Quick Setup:** Most users can be analysing audio within 15 minutes! Follow the steps below.

.. note::
   **Development Context:** Started early August 2025 • Current: December 2025 • Roadmap: 2026+

Prerequisites
=============

iOS App Requirements
--------------------

* macOS 13.0+ with Xcode 15.0+
* iOS device or simulator running iOS 18.0+
* Swift 5.0+
* Active Apple Developer account (for device testing)

Python Server Requirements
--------------------------

* Python 3.8+
* 4GB RAM minimum
* 1GB free disk space
* Unix-like OS (macOS, Linux) or WSL2 on Windows

Installation
============

Step 1: Clone the Repository
----------------------------

.. code-block:: bash

    git clone https://github.com/yourusername/amadeus.git
    cd amadeus

Step 2: Set Up Python Server
-----------------------------

**Create virtual environment:**

.. code-block:: bash

    cd basic-pitch-server
    python3 -m venv venv
    source venv/bin/activate  #on windows: venv\Scripts\activate

**Install dependencies:**

.. code-block:: bash

    pip install -r requirements.txt

**Start the server:**

.. code-block:: bash

    python main.py
    #or use the provided script:
    ./run_server.sh

The server will start on ``http://localhost:8000``

**Verify server is running:**

.. code-block:: bash

    curl http://localhost:8000/health

Expected response:

.. code-block:: json

    {
      "status": "healthy",
      "model_available": true,
      "model_path": "...",
      "version": "1.0.0"
    }

Step 3: Set Up iOS App
----------------------

**Open project in Xcode:**

.. code-block:: bash

    cd ../Amadeus-Fresh/amadeus
    open amadeus.xcodeproj

**Configure server endpoint:**

1. Open ``Models/BasicPitchHTTPClient.swift``
2. Update the server URL:

.. code-block:: swift

    private let serverURL = "http://localhost:8000/analyze"
    // For device testing, use your machine's IP:
    // private let serverURL = "http://192.168.1.100:8000/analyze"

**Build and run:**

1. Select target device/simulator
2. Press ``Cmd+R`` or click the Run button
3. The app should launch successfully

First Analysis
==============

Method 1: Recording Audio
--------------------------

1. Tap the microphone icon
2. Play music (up to 30 seconds)
3. Tap stop when finished
4. Tap "Analyse" to process

Method 2: Uploading a File
---------------------------

1. Tap "Upload File"
2. Select an audio file from your device
3. Supported formats: WAV, MP3, M4A, AAC, FLAC, OGG
4. Tap "Analyse"

Understanding Results
=====================

Chord Timeline
--------------

* **Horizontal bars**: Each bar represents a detected chord
* **Colors**: Different colors for chord types (major, minor, etc.)
* **Height**: Indicates confidence level
* **Tap**: Tap on a chord to see details
* **Scrub**: Drag the playhead to navigate

Playback Controls
-----------------

* **Play/Pause**: Start or stop playback
* **Seek**: Tap anywhere on timeline to jump
* **Skip**: ±5 second skip buttons
* **Speed**: Adjust playback rate (0.5x - 2.0x)

Chord Information
-----------------

Each detected chord shows:

* **Symbol**: Standard chord notation (C, Am, G7, etc.)
* **Duration**: How long the chord plays
* **Confidence**: Detection confidence (0-100%)
* **Root**: The fundamental note
* **Quality**: Major, minor, diminished, etc.

Music Theory Library
====================

Access the built-in theory reference:

Chord Dictionary
----------------

1. Tap "Library" tab
2. Select "Chords"
3. Browse chord types
4. Tap any chord to see:
   
   * Fingering diagram on piano
   * Note composition
   * Common uses
   * Audio playback

Scale Explorer
--------------

1. Select "Scales"
2. Choose a scale type
3. View scale degrees
4. Play scale audio
5. See common chord progressions

Troubleshooting
===============

Server Connection Issues
------------------------

**Problem**: "Failed to connect to server"

**Solutions**:

1. Verify server is running:

.. code-block:: bash

    ps aux | grep "python main.py"

2. Check firewall settings
3. For device testing, make sure both device and server are on the same network
4. Update server URL in iOS app to use correct IP address

Analysis Failures
-----------------

**Problem**: "Analysis failed"

**Solutions**:

1. Check file format (must be audio file)
2. Ideally work with file sizes (<50MB)
3. Make sure audio contains musical content :D
4. Check server logs for errors:

.. code-block:: bash

    # Server console will show detailed error messages

Poor Chord Detection
--------------------

**Problem**: Incorrect or missing chords

**Solutions**:

1. Use higher quality audio (higher bitrate)
2. Ideally work with clear harmonic content (not too much percussion)
3. Try analysing shorter sections
4. Avoid heavily processed or distorted audio

Performance Tips
================

For Best Results
----------------

* Use high-quality audio files (256kbps+ MP3 or WAV)
* Make sure harmonic content is clear (piano, guitar work well)
* Avoid sections with only drums or silence
* Songs with clear and relatively basic changes work best
* Pop, rock, and jazz typically work better than classical or electronic

Server Optimisation
-------------------

For production deployment:

.. code-block:: bash

    #use production server
    uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4

    # or with gunicorn
    gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker

Next Steps
==========

* Explore the :doc:`theory/chord_dictionary`
* Learn about :doc:`architecture`
* Contribute to development: :doc:`development/contributing`
* Check the :doc:`future/roadmap` for upcoming features