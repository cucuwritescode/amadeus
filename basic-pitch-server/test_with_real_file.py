#!/usr/bin/env python3
"""
Test script to reproduce the server error with actual audio files.

This will help debug the "zero-size array" error by testing the server
with the same type of files the iOS app is sending.
"""

import requests
import tempfile
import os
import numpy as np
import librosa
import soundfile as sf

def create_test_mono_wav(duration=5.0, sample_rate=44100):
    """Create a simple test mono WAV file similar to what iOS sends."""
    
    # Generate a simple chord (C major: C4, E4, G4)
    freqs = [261.63, 329.63, 392.00]  # C4, E4, G4
    t = np.linspace(0, duration, int(sample_rate * duration))
    
    # Create mono audio by summing sine waves
    audio = np.zeros_like(t)
    for freq in freqs:
        audio += 0.3 * np.sin(2 * np.pi * freq * t)
    
    # Add some decay
    envelope = np.exp(-t * 0.5)
    audio *= envelope
    
    # Save as mono WAV
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.wav')
    sf.write(temp_file.name, audio, sample_rate)
    temp_file.close()
    
    return temp_file.name, audio.shape[0]

def test_server_with_file(file_path, server_url="http://localhost:8000"):
    """Test the server with a specific audio file."""
    
    print(f"🧪 Testing server with: {file_path}")
    
    # Get file info
    file_size = os.path.getsize(file_path)
    print(f"📁 File size: {file_size:,} bytes ({file_size/1024/1024:.1f} MB)")
    
    # Test audio loading (same as server does)
    try:
        audio, sr = librosa.load(file_path, sr=None, mono=True)
        print(f"🎵 Audio info: {audio.shape} samples at {sr} Hz")
        print(f"⏱️  Duration: {len(audio) / sr:.2f} seconds")
        print(f"📊 Audio range: [{audio.min():.3f}, {audio.max():.3f}]")
        
        if len(audio) == 0:
            print("❌ Audio is empty!")
            return False
            
    except Exception as e:
        print(f"❌ Failed to load audio locally: {e}")
        return False
    
    # Test server endpoint
    try:
        print(f"\n🚀 Sending to server: {server_url}/analyze")
        
        with open(file_path, 'rb') as f:
            files = {'file': (os.path.basename(file_path), f, 'audio/wav')}
            response = requests.post(f"{server_url}/analyze", files=files, timeout=60)
        
        print(f"📡 Server response: HTTP {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            notes = data.get('notes', [])
            print(f"✅ Success! Received {len(notes)} note events")
            
            if notes:
                print("🎵 First 3 notes:")
                for i, note in enumerate(notes[:3]):
                    print(f"   {i+1}. MIDI {note['pitch']} at {note['onset']:.2f}s-{note['offset']:.2f}s (conf: {note['confidence']:.3f})")
            else:
                print("ℹ️  No notes detected (silent audio or below threshold)")
                
            return True
            
        else:
            print(f"❌ Server error: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Request failed: {e}")
        return False

def main():
    print("🎵 Basic Pitch Server Test")
    print("=" * 40)
    
    # Test 1: Simple synthetic audio
    print("\n1. Testing with synthetic mono WAV...")
    test_file, sample_count = create_test_mono_wav(duration=10.0, sample_rate=44100)
    
    try:
        success = test_server_with_file(test_file)
        if success:
            print("✅ Synthetic audio test passed!")
        else:
            print("❌ Synthetic audio test failed!")
    finally:
        os.unlink(test_file)
    
    # Test 2: Real audio file if available
    print("\n2. Testing with real audio file...")
    
    # Try to find an audio file in common locations
    test_paths = [
        "/System/Library/Sounds/Ping.aiff",  # macOS system sound
        "./test_audio.wav",  # Local test file
        "../chord_recordings/*.wav"  # User recordings
    ]
    
    for test_path in test_paths:
        if os.path.exists(test_path):
            print(f"Found test file: {test_path}")
            success = test_server_with_file(test_path)
            if success:
                print("✅ Real audio test passed!")
            else:
                print("❌ Real audio test failed!")
            break
    else:
        print("⚠️  No real audio files found for testing")
    
    print("\n" + "=" * 40)
    print("🏁 Test complete!")
    print("\n💡 If tests fail with 'zero-size array' error:")
    print("   - Check server logs for detailed error traces")
    print("   - The error is likely in Basic Pitch's internal processing")
    print("   - May need to adjust onset/frame thresholds or minimum note length")

if __name__ == "__main__":
    main()