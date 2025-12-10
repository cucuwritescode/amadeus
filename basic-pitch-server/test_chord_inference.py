#!/usr/bin/env python3
"""
Test script for the new chord inference module.

Tests the chord inference pipeline with simulated Basic Pitch output
to verify all the post-processing features work correctly.
"""

import sys
import logging
from chord_inference import process_note_events, NoteEvent

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def create_test_note_events():
    """Create test note events for a simple I-vi-IV-V progression in C major."""
    
    # C major chord (C-E-G) from 0-2 seconds
    c_major = [
        {'onset': 0.0, 'offset': 2.0, 'pitch': 60, 'confidence': 0.9},  # C
        {'onset': 0.0, 'offset': 2.0, 'pitch': 64, 'confidence': 0.8},  # E
        {'onset': 0.0, 'offset': 2.0, 'pitch': 67, 'confidence': 0.85}, # G
        # Add some noise/transients that should be filtered
        {'onset': 0.1, 'offset': 0.12, 'pitch': 50, 'confidence': 0.1}, # Low noise
        {'onset': 0.5, 'offset': 0.53, 'pitch': 75, 'confidence': 0.05}, # High transient
    ]
    
    # A minor chord (A-C-E) from 2-4 seconds  
    a_minor = [
        {'onset': 2.0, 'offset': 4.0, 'pitch': 57, 'confidence': 0.85}, # A
        {'onset': 2.0, 'offset': 4.0, 'pitch': 60, 'confidence': 0.9},  # C
        {'onset': 2.0, 'offset': 4.0, 'pitch': 64, 'confidence': 0.8},  # E
        # Out-of-key note with low confidence (should be filtered)
        {'onset': 2.2, 'offset': 2.8, 'pitch': 63, 'confidence': 0.1},  # D# (low conf)
    ]
    
    # F major chord (F-A-C) from 4-6 seconds
    f_major = [
        {'onset': 4.0, 'offset': 6.0, 'pitch': 53, 'confidence': 0.9},  # F
        {'onset': 4.0, 'offset': 6.0, 'pitch': 57, 'confidence': 0.85}, # A
        {'onset': 4.0, 'offset': 6.0, 'pitch': 60, 'confidence': 0.8},  # C
    ]
    
    # G major chord (G-B-D) from 6-8 seconds
    g_major = [
        {'onset': 6.0, 'offset': 8.0, 'pitch': 55, 'confidence': 0.9},  # G
        {'onset': 6.0, 'offset': 8.0, 'pitch': 59, 'confidence': 0.8},  # B
        {'onset': 6.0, 'offset': 8.0, 'pitch': 62, 'confidence': 0.85}, # D
    ]
    
    return c_major + a_minor + f_major + g_major

def test_chord_inference():
    """Test the complete chord inference pipeline."""
    
    logger.info("🧪 Testing chord inference pipeline")
    logger.info("=" * 50)
    
    # Create test data
    raw_notes = create_test_note_events()
    logger.info(f"Created {len(raw_notes)} test note events")
    
    # Print input summary
    logger.info("Input note events:")
    for note in raw_notes:
        pitch_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        pc = note['pitch'] % 12
        octave = note['pitch'] // 12
        note_name = f"{pitch_names[pc]}{octave}"
        logger.info(f"  {note['onset']:4.1f}s - {note['offset']:4.1f}s: "
                   f"{note_name:3s} (MIDI {note['pitch']:3d}) "
                   f"conf={note['confidence']:.2f}")
    
    # Run chord inference
    logger.info("\n🎼 Running chord inference...")
    chord_events, key_info = process_note_events(raw_notes)
    
    # Print results
    logger.info("\n📊 RESULTS:")
    logger.info("=" * 30)
    
    logger.info(f"🔑 Estimated Key: {key_info['key']} {key_info['mode']} "
               f"(confidence: {key_info['confidence']:.3f})")
    
    logger.info(f"\n🎵 Detected Chords ({len(chord_events)}):")
    for chord in chord_events:
        duration = chord['offset'] - chord['onset']
        pc_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        pcs = [pc_names[pc] for pc in sorted(chord['pitch_classes'])]
        logger.info(f"  {chord['onset']:4.1f}s - {chord['offset']:4.1f}s "
                   f"({duration:4.1f}s): {chord['chord']:>6s} "
                   f"conf={chord['confidence']:.3f} "
                   f"pcs=[{', '.join(pcs)}]")
    
    # Verify expectations
    logger.info("\n✅ VERIFICATION:")
    logger.info("=" * 20)
    
    expected_progression = ["C", "Am", "F", "G"]
    detected_chords = [chord['chord'] for chord in chord_events]
    
    if len(detected_chords) == 4:
        logger.info("✓ Correct number of chords detected (4)")
    else:
        logger.warning(f"✗ Expected 4 chords, got {len(detected_chords)}")
    
    if key_info['key'] == 'C' and key_info['mode'] == 'major':
        logger.info("✓ Correct key detected (C major)")
    else:
        logger.warning(f"✗ Expected C major, got {key_info['key']} {key_info['mode']}")
    
    # Check if progression matches expectation (allowing for variations)
    matches = 0
    for i, expected in enumerate(expected_progression):
        if i < len(detected_chords):
            detected = detected_chords[i]
            if detected == expected or (expected == "Am" and detected in ["Am", "A"]):
                matches += 1
                logger.info(f"✓ Chord {i+1}: {detected} (expected {expected})")
            else:
                logger.warning(f"✗ Chord {i+1}: {detected} (expected {expected})")
    
    success_rate = matches / len(expected_progression) if expected_progression else 0
    logger.info(f"\n🎯 Overall accuracy: {matches}/{len(expected_progression)} = {success_rate:.1%}")
    
    if success_rate >= 0.75:
        logger.info("🎉 TEST PASSED: Chord inference working correctly!")
        return True
    else:
        logger.error("❌ TEST FAILED: Chord inference needs improvement")
        return False

def test_edge_cases():
    """Test edge cases and error handling."""
    
    logger.info("\n🧪 Testing edge cases")
    logger.info("=" * 30)
    
    # Test empty input
    logger.info("Testing empty input...")
    chords, key = process_note_events([])
    assert len(chords) == 0, "Empty input should return no chords"
    assert key['confidence'] == 0.0, "Empty input should have zero key confidence"
    logger.info("✓ Empty input handled correctly")
    
    # Test single note
    logger.info("Testing single note...")
    single_note = [{'onset': 0.0, 'offset': 1.0, 'pitch': 60, 'confidence': 0.8}]
    chords, key = process_note_events(single_note)
    logger.info(f"  Single note result: {len(chords)} chords, key={key['key']} {key['mode']}")
    
    # Test very short notes (should be filtered)
    logger.info("Testing very short notes...")
    short_notes = [
        {'onset': 0.0, 'offset': 0.01, 'pitch': 60, 'confidence': 0.8},  # 10ms - too short
        {'onset': 0.1, 'offset': 0.2, 'pitch': 64, 'confidence': 0.8},   # 100ms - OK
        {'onset': 0.3, 'offset': 0.4, 'pitch': 67, 'confidence': 0.8},   # 100ms - OK
    ]
    chords, key = process_note_events(short_notes)
    logger.info(f"  Short notes result: {len(chords)} chords")
    
    # Test low confidence notes
    logger.info("Testing low confidence notes...")
    low_conf_notes = [
        {'onset': 0.0, 'offset': 1.0, 'pitch': 60, 'confidence': 0.05},  # Very low
        {'onset': 0.0, 'offset': 1.0, 'pitch': 64, 'confidence': 0.8},   # Good
        {'onset': 0.0, 'offset': 1.0, 'pitch': 67, 'confidence': 0.7},   # Good
    ]
    chords, key = process_note_events(low_conf_notes)
    logger.info(f"  Low confidence result: {len(chords)} chords")
    
    logger.info("✓ Edge cases completed")

if __name__ == "__main__":
    try:
        # Run main test
        success = test_chord_inference()
        
        # Run edge case tests
        test_edge_cases()
        
        # Exit with appropriate code
        sys.exit(0 if success else 1)
        
    except Exception as e:
        logger.error(f"Test failed with exception: {e}")
        import traceback
        logger.error(traceback.format_exc())
        sys.exit(1)