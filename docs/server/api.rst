=============
API Reference
=============

The Amadeus server provides RESTful endpoints for audio analysis.

Base URL
========

Development: ``http://localhost:8000``

Production: TBD (deployment planned for 2026)

Endpoints
=========

POST /analyze
-------------

Analyses an audio file using Basic Pitch model and returns chord progressions and note events.

**Request**

.. code-block:: http

    POST /analyze HTTP/1.1
    Content-Type: multipart/form-data

    audio_file: <binary audio data>

**Parameters**

* ``audio_file`` (required): Audio file in WAV, MP3, M4A, AAC, FLAC, or OGG format
* Maximum file size: 50MB
* Recording duration: Up to 30 seconds for in-app recording

**Response**

.. code-block:: json

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

**Status Codes**

* ``200 OK``: Successful analysis
* ``400 Bad Request``: Invalid request (no file, bad format)
* ``413 Payload Too Large``: File exceeds size limit
* ``415 Unsupported Media Type``: Unsupported audio format
* ``500 Internal Server Error``: Processing error

**Example Usage**

Python example:

.. code-block:: python

    import requests

    with open('song.mp3', 'rb') as f:
        files = {'file': ('song.mp3', f, 'audio/mpeg')}
        response = requests.post('http://localhost:8000/analyze', files=files)
        
    result = response.json()
    print(f"Detected {len(result['chords'])} chords")

Swift example:

.. code-block:: swift

    let url = URL(string: "http://localhost:8000/analyze")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", 
                     forHTTPHeaderField: "Content-Type")
    
    var data = Data()
    data.append("--\(boundary)\r\n")
    data.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n")
    data.append("Content-Type: audio/wav\r\n\r\n")
    data.append(audioData)
    data.append("\r\n--\(boundary)--\r\n")
    
    request.httpBody = data
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle response
    }
    task.resume()

GET /health
-----------

Health check endpoint for monitoring server status.

**Request**

.. code-block:: http

    GET /health HTTP/1.1

**Response**

.. code-block:: json

    {
      "status": "healthy",
      "model_available": true,
      "model_path": "/path/to/model",
      "version": "1.0.0"
    }

**Status Codes**

* ``200 OK``: Server is healthy
* ``503 Service Unavailable``: Server is unhealthy

GET /
-----

Root endpoint providing basic server information.

**Request**

.. code-block:: http

    GET / HTTP/1.1

**Response**

.. code-block:: json

    {
      "message": "Basic Pitch Server is running",
      "version": "1.0.0"
    }

Data Models
===========

NoteEvent
---------

Represents a single detected note.

.. code-block:: python

    class NoteEvent:
        onset: float        # Start time in seconds
        offset: float       # End time in seconds
        pitch: int         # MIDI pitch (0-127)
        confidence: float  # Detection confidence (0-1)

ChordEvent
----------

Represents a detected chord.

.. code-block:: python

    class ChordEvent:
        onset: float              # Start time in seconds
        offset: float             # End time in seconds
        chord: str               # Chord symbol (e.g., "Cmaj7")
        confidence: float        # Detection confidence (0-1)
        pitch_classes: List[int] # Pitch classes (0-11)

KeyInfo
-------

Key estimation information.

.. code-block:: python

    class KeyInfo:
        key: str          # Root note (C, D, E, etc.)
        mode: str         # "major" or "minor"
        confidence: float # Estimation confidence (0-1)

Error Responses
===============

All error responses follow this format:

.. code-block:: json

    {
      "detail": "Error description"
    }

Common error messages:

* ``"No filename provided"``: File upload missing filename
* ``"File too large. Maximum size: 50MB"``: File exceeds size limit
* ``"Unsupported format. Supported: .wav, .mp3, .m4a, .aac, .flac, .ogg"``: Invalid file format
* ``"Failed to process audio: [details]"``: Processing error

Rate Limiting
=============

Currently no rate limiting is implemented. Future versions will include:

* 100 requests per minute per IP
* 1000 requests per hour per IP
* Custom limits for authenticated users

Authentication
==============

Currently no authentication is required. Future versions will support:

* API key authentication
* JWT tokens for user sessions
* OAuth2 integration

CORS Policy
===========

The server allows CORS from all origins in development. Production configuration should restrict to:

* Amadeus iOS app
* Amadeus web app (if applicable)
* Trusted partner applications

WebSocket Support (Future)
===========================

Future versions will support WebSocket connections for:

* Real-time analysis updates
* Live mode streaming
* Progress notifications
* Collaborative sessions