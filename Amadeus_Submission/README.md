<div align="center">

# Amadeus

<img width="370" height="370" alt="amadeus_logo2" src="https://github.com/user-attachments/assets/173b5b60-8d66-43c6-a03f-e4c3298232d9" />

[![Documentation](https://img.shields.io/badge/docs-Read%20the%20Docs-blue)](https://amadeus-chordzart.readthedocs.io)
[![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/)

</div>

---


An iOS system for **multiple f₀ estimation**. The application receives audio from the device microphone or local files, performs polyphonic pitch analysis, and presents detected chords and key signature in a direct visual interface. It also features a music theory library and chord timeline visualisation, with slow/speed up control as well as transposition to all 12 keys. 

**Key Features:**
• Real-time chord recognition • Audio file analysis • Music theory library • Chord timeline visualisation • Slow/speed up control • Transposition to all 12 keys • Share the generated chords 

## running the app

1. open `amadeus/amadeus.xcodeproj` in xcode
2. select an ios 18+ simulator (e.g. iphone 16 pro)
3. press cmd+r to build and run

note: without the backend server, chord analysis will run in simulation mode. But, the server is NOT needed for succesful compilation of the app

if interested, the `server-source` folder contains the python backend code I wrote (for marking reference).

## folder structure

- `amadeus/` - ios app (xcode project)
- `server-source/` - backend chord analysis server (reference only)
- `Demo Video/` - app demonstration
- `Marketing/` - promotional materials

## documentation

full documentation is available at **[https://amadeus-chordzart.readthedocs.io](https://amadeus-chordzart.readthedocs.io)**
