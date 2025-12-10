#!/usr/bin/env python3
"""
Test script for Basic Pitch Server

This script tests the server with a simple synthetic audio file.
Run this after starting the server to verify everything works.
"""

import requests
import numpy as np
import soundfile as sf
import tempfile
import os
from typing import List, Dict

def create_test_audio(duration: float = 2.0, sample_rate: int = 22050) -> str:
    """Create a simple test audio file with a C major chord."""
    
    # Create frequencies for C major chord (C4, E4, G4)
    freqs = [261.63, 329.63, 392.00]  # C4, E4, G4
    
    # Generate time array
    t = np.linspace(0, duration, int(sample_rate * duration))
    
    # Generate chord by adding sine waves
    audio = np.zeros_like(t)
    for freq in freqs:
        audio += 0.3 * np.sin(2 * np.pi * freq * t)
    
    # Add some decay
    envelope = np.exp(-t * 0.5)
    audio *= envelope
    
    # Save to temporary file
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.wav')
    sf.write(temp_file.name, audio, sample_rate)
    temp_file.close()
    
    return temp_file.name

def test_server(server_url: str = "http://localhost:8000"):
    """Test the Basic Pitch server."""
    
    print(f"🧪 Testing Basic Pitch server at {server_url}")
    
    # Test 1: Health check
    print("\n1. Testing health endpoint...")
    try:
        response = requests.get(f"{server_url}/health", timeout=10)
        if response.status_code == 200:
            health_data = response.json()
            print(f"   ✅ Health check passed")
            print(f"   📊 Status: {health_data.get('status')}")
            print(f"   🤖 Model available: {health_data.get('model_available')}")
        else:
            print(f"   ❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"   ❌ Health check failed: {e}")
        return False
    
    # Test 2: Audio analysis
    print("\n2. Testing audio analysis...")
    
    # Create test audio
    test_audio_path = create_test_audio()
    print(f"   📁 Created test audio: {test_audio_path}")
    
    try:
        # Upload test audio
        with open(test_audio_path, 'rb') as audio_file:
            files = {'file': ('test_chord.wav', audio_file, 'audio/wav')}
            response = requests.post(f"{server_url}/analyze", files=files, timeout=60)
        
        if response.status_code == 200:
            analysis_data = response.json()
            notes = analysis_data.get('notes', [])
            
            print(f"   ✅ Analysis completed successfully")
            print(f"   🎵 Found {len(notes)} note events")
            
            if notes:
                print("   📝 First few notes:")
                for i, note in enumerate(notes[:5]):
                    midi_pitch = note['pitch']
                    note_name = midi_to_note_name(midi_pitch)
                    print(f"      {i+1}. {note_name} (MIDI {midi_pitch}) at {note['onset']:.2f}s-{note['offset']:.2f}s")
            
            return True
        else:
            print(f"   ❌ Analysis failed: {response.status_code}")
            print(f"   📄 Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"   ❌ Analysis failed: {e}")
        return False
    
    finally:
        # Clean up test file
        try:
            os.unlink(test_audio_path)
        except:
            pass

def midi_to_note_name(midi_pitch: int) -> str:
    """Convert MIDI pitch to note name."""
    note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    octave = (midi_pitch // 12) - 1
    note = note_names[midi_pitch % 12]
    return f"{note}{octave}"

def main():
    """Run server tests."""
    print("🎵 Basic Pitch Server Test Suite")
    print("=" * 40)
    
    success = test_server()
    
    print("\n" + "=" * 40)
    if success:
        print("🎉 All tests passed! Server is working correctly.")
    else:
        print("❌ Tests failed. Check server status and logs.")
        
    print("\nTo start the server:")
    print("  python main.py")
    print("\nTo test with your own audio:")
    print("  curl -X POST -F 'file=@your_audio.wav' http://localhost:8000/analyze")

if __name__ == "__main__":
    main()