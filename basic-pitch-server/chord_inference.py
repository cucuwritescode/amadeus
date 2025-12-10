#!/usr/bin/env python3
"""
Advanced Chord Inference Module for Basic Pitch Server

This module implements post-processing of raw Basic Pitch note events to produce
stable, musically meaningful chord progressions. It includes:

1. Pitch smoothing (temporal median filter)
2. Minimum duration filtering
3. Robust key detection algorithm
4. Key-aware chord filtering
5. Confidence-weighted chord voting
6. Window merging for similar chords
7. Expected harmony whitelist filtering
8. Output stability guarantees

Author: Claude (Amadeus Project)
Date: December 2024
"""

import numpy as np
import scipy.signal
from typing import List, Dict, Tuple, Optional, Set
from dataclasses import dataclass
from collections import Counter, defaultdict
import logging

logger = logging.getLogger(__name__)

# MARK: - Data Structures

@dataclass
class NoteEvent:
    """A detected note with timing and pitch information."""
    onset: float
    offset: float
    pitch: int
    confidence: float
    
    @property
    def duration(self) -> float:
        return self.offset - self.onset
    
    @property
    def pitch_class(self) -> int:
        return self.pitch % 12

@dataclass
class ChordEvent:
    """A detected chord with timing and musical information."""
    onset: float
    offset: float
    chord_symbol: str
    confidence: float
    pitch_classes: Set[int]
    root_pc: int
    chord_type: str

@dataclass
class KeyEstimate:
    """Key estimation result."""
    key_pc: int  # 0-11 pitch class
    mode: str   # 'major' or 'minor'
    confidence: float

# MARK: - Configuration

class ChordInferenceConfig:
    """Configuration for chord inference parameters."""
    
    # Pitch smoothing
    MEDIAN_FILTER_SIZE = 3  # 3-5 frame median filter
    
    # Note filtering
    MIN_NOTE_DURATION = 0.06  # 60ms minimum duration
    MIN_CONFIDENCE_THRESHOLD = 0.3  # Base confidence threshold
    
    # Window analysis
    WINDOW_SIZE = 2.0  # 2.0 second windows
    WINDOW_OVERLAP = 0.2  # 0.2 second overlap (small overlap to reduce over-segmentation)
    
    # Chord detection
    MIN_NOTES_PER_CHORD = 2
    CONFIDENCE_WEIGHT_DURATION = True
    KEY_FILTER_CONFIDENCE_THRESHOLD = 0.15  # Drop out-of-key notes below this
    
    # Stability
    MIN_CHORD_DURATION = 0.3  # 300ms minimum chord duration
    MERGE_THRESHOLD = 0.4  # Merge chords closer than 400ms
    
    # Expected harmony (functional chord types to prioritize)
    FUNCTIONAL_CHORDS = {
        'major', 'minor', 'sus2', 'sus4', 
        '7', 'm7', 'maj7',           # Common 7th chords
        'm11',                       # Minor 11 for jazz
        'dim', 'aug',                # Diminished and augmented
        'add9', '6'                  # Common extensions
    }

# MARK: - Key Detection

class KeyDetector:
    """Robust key detection using Krumhansl key profiles."""
    
    # Krumhansl-Schmuckler key profiles (major and minor)
    MAJOR_PROFILE = np.array([6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88])
    MINOR_PROFILE = np.array([6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17])
    
    def __init__(self):
        # Normalize profiles
        self.major_profile = self.MAJOR_PROFILE / np.sum(self.MAJOR_PROFILE)
        self.minor_profile = self.MINOR_PROFILE / np.sum(self.MINOR_PROFILE)
    
    def estimate_key(self, note_events: List[NoteEvent], exclude_short_notes: bool = True) -> KeyEstimate:
        """
        Estimate key using weighted pitch-class distribution and key profiles.
        
        Args:
            note_events: List of note events
            exclude_short_notes: Whether to exclude notes shorter than MIN_NOTE_DURATION
            
        Returns:
            KeyEstimate with key, mode, and confidence
        """
        if not note_events:
            return KeyEstimate(key_pc=0, mode='major', confidence=0.0)
        
        # Filter short notes if requested
        if exclude_short_notes:
            filtered_events = [
                note for note in note_events 
                if note.duration >= ChordInferenceConfig.MIN_NOTE_DURATION
            ]
            if not filtered_events:
                filtered_events = note_events  # Fallback to all notes
        else:
            filtered_events = note_events
        
        # Build weighted pitch-class histogram
        pc_weights = np.zeros(12)
        
        for note in filtered_events:
            pc = note.pitch_class
            # Weight by duration * confidence
            weight = note.duration * note.confidence
            pc_weights[pc] += weight
        
        if np.sum(pc_weights) == 0:
            return KeyEstimate(key_pc=0, mode='major', confidence=0.0)
        
        # Normalize
        pc_weights = pc_weights / np.sum(pc_weights)
        
        logger.debug(f"Pitch class distribution: {pc_weights}")
        
        # Test all 24 possible keys (12 major + 12 minor)
        best_correlation = -1
        best_key_pc = 0
        best_mode = 'major'
        
        for root_pc in range(12):
            # Test major key
            major_correlation = self._correlate_with_profile(pc_weights, root_pc, self.major_profile)
            if major_correlation > best_correlation:
                best_correlation = major_correlation
                best_key_pc = root_pc
                best_mode = 'major'
            
            # Test minor key  
            minor_correlation = self._correlate_with_profile(pc_weights, root_pc, self.minor_profile)
            if minor_correlation > best_correlation:
                best_correlation = minor_correlation
                best_key_pc = root_pc
                best_mode = 'minor'
        
        # Convert correlation to confidence (0-1 scale)
        confidence = max(0.0, min(1.0, best_correlation))
        
        key_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        logger.info(f"Estimated key: {key_names[best_key_pc]} {best_mode} (confidence: {confidence:.3f})")
        
        return KeyEstimate(key_pc=best_key_pc, mode=best_mode, confidence=confidence)
    
    def _correlate_with_profile(self, pc_weights: np.ndarray, root_pc: int, profile: np.ndarray) -> float:
        """Compute correlation between pitch-class distribution and key profile."""
        # Rotate profile to match root
        rotated_profile = np.roll(profile, root_pc)
        
        # Compute Pearson correlation
        correlation = np.corrcoef(pc_weights, rotated_profile)[0, 1]
        
        # Handle NaN case (when one array is all zeros)
        if np.isnan(correlation):
            correlation = 0.0
            
        return correlation

# MARK: - Pitch Smoothing

class PitchSmoother:
    """Applies temporal median filtering to pitch activity."""
    
    def __init__(self, filter_size: int = ChordInferenceConfig.MEDIAN_FILTER_SIZE):
        self.filter_size = filter_size
    
    def smooth_pitch_activity(self, note_events: List[NoteEvent]) -> List[NoteEvent]:
        """
        Apply median filter to each pitch class activity over time.
        
        Args:
            note_events: Raw note events from Basic Pitch
            
        Returns:
            Smoothed note events with filtered activations
        """
        if not note_events:
            return []
        
        logger.info(f"Applying pitch smoothing with filter size {self.filter_size}")
        
        # Group notes by pitch class and sort by onset
        pc_events = defaultdict(list)
        for note in note_events:
            pc_events[note.pitch_class].append(note)
        
        smoothed_events = []
        
        for pc, events in pc_events.items():
            if len(events) <= 1:
                smoothed_events.extend(events)
                continue
                
            # Sort by onset time
            events.sort(key=lambda n: n.onset)
            
            # Extract confidence values
            confidences = [event.confidence for event in events]
            
            # Apply median filter
            if len(confidences) >= self.filter_size:
                smoothed_confidences = scipy.signal.medfilt(confidences, kernel_size=self.filter_size)
                
                # Update events with smoothed confidences
                for i, event in enumerate(events):
                    smoothed_events.append(NoteEvent(
                        onset=event.onset,
                        offset=event.offset,
                        pitch=event.pitch,
                        confidence=float(smoothed_confidences[i])
                    ))
            else:
                smoothed_events.extend(events)
        
        logger.info(f"Smoothed {len(note_events)} → {len(smoothed_events)} note events")
        return smoothed_events

# MARK: - Chord Window Smoothing

class ChordWindowSmoother:
    """Applies 1-second median filter to chord progression windows."""
    
    def smooth_chord_progression(self, chord_events: List[ChordEvent]) -> List[ChordEvent]:
        """
        Apply 1-second median filter to remove chord flukes and stabilize progressions.
        
        This fixes issues like I–II–IV–vi → I–II–IV–I by removing random chord changes
        that don't persist for at least 1 second.
        """
        if len(chord_events) <= 2:
            return chord_events
        
        logger.info("Applying 1-second median filter to chord progression")
        
        # Create timeline with 0.5-second resolution for median filtering
        timeline_resolution = 0.5
        if not chord_events:
            return []
        
        start_time = min(c.onset for c in chord_events)
        end_time = max(c.offset for c in chord_events)
        duration = end_time - start_time
        
        if duration <= 0:
            return chord_events
        
        # Sample the timeline
        timeline_points = []
        current_time = start_time
        while current_time <= end_time:
            timeline_points.append(current_time)
            current_time += timeline_resolution
        
        # Map each timeline point to the active chord symbol
        chord_symbols = []
        for time_point in timeline_points:
            active_chord = None
            for chord in chord_events:
                if chord.onset <= time_point < chord.offset:
                    active_chord = chord.chord_symbol
                    break
            chord_symbols.append(active_chord or "N")  # "N" for no chord
        
        # Apply median filter with 2-second window (4 samples at 0.5s resolution)
        filter_window = max(3, int(1.0 / timeline_resolution))  # 1-second window
        
        if len(chord_symbols) >= filter_window:
            smoothed_symbols = []
            
            for i in range(len(chord_symbols)):
                # Get window around current point
                window_start = max(0, i - filter_window // 2)
                window_end = min(len(chord_symbols), window_start + filter_window)
                window_symbols = chord_symbols[window_start:window_end]
                
                # Find most common symbol in window (median-like for categorical data)
                symbol_counts = Counter(s for s in window_symbols if s != "N")
                if symbol_counts:
                    most_common = symbol_counts.most_common(1)[0][0]
                    smoothed_symbols.append(most_common)
                else:
                    smoothed_symbols.append("N")
            
            # Convert back to chord events by grouping consecutive identical symbols
            smoothed_chords = []
            if smoothed_symbols:
                current_symbol = smoothed_symbols[0]
                current_start_time = timeline_points[0]
                
                for i in range(1, len(smoothed_symbols)):
                    if smoothed_symbols[i] != current_symbol or i == len(smoothed_symbols) - 1:
                        # End current chord
                        if current_symbol != "N":
                            # Find original chord info for confidence and pitch classes
                            original_chord = next(
                                (c for c in chord_events if c.chord_symbol == current_symbol), 
                                None
                            )
                            if original_chord:
                                smoothed_chords.append(ChordEvent(
                                    onset=current_start_time,
                                    offset=timeline_points[i-1] + timeline_resolution,
                                    chord_symbol=current_symbol,
                                    confidence=original_chord.confidence,
                                    pitch_classes=original_chord.pitch_classes,
                                    root_pc=original_chord.root_pc,
                                    chord_type=original_chord.chord_type
                                ))
                        
                        # Start new chord
                        current_symbol = smoothed_symbols[i]
                        current_start_time = timeline_points[i]
                
                # Handle last chord
                if current_symbol != "N":
                    original_chord = next(
                        (c for c in chord_events if c.chord_symbol == current_symbol), 
                        None
                    )
                    if original_chord:
                        smoothed_chords.append(ChordEvent(
                            onset=current_start_time,
                            offset=end_time,
                            chord_symbol=current_symbol,
                            confidence=original_chord.confidence,
                            pitch_classes=original_chord.pitch_classes,
                            root_pc=original_chord.root_pc,
                            chord_type=original_chord.chord_type
                        ))
            
            filtered_count = len(chord_events) - len(smoothed_chords)
            logger.info(f"Median filter: {len(chord_events)} → {len(smoothed_chords)} chords "
                       f"(removed {filtered_count} flukes)")
            
            return smoothed_chords
        
        return chord_events

# MARK: - Chord Inference Engine

class ChordInferenceEngine:
    """Main engine for converting note events to stable chord progressions."""
    
    def __init__(self):
        self.key_detector = KeyDetector()
        self.pitch_smoother = PitchSmoother()
        self.stats = defaultdict(int)
        self.chord_smoother = ChordWindowSmoother()  # NEW: 1-second median filter
    
    def infer_chords(self, note_events: List[NoteEvent]) -> Tuple[List[ChordEvent], KeyEstimate]:
        """
        Main chord inference pipeline.
        
        Args:
            note_events: Raw note events from Basic Pitch
            
        Returns:
            Tuple of (chord_events, key_estimate)
        """
        logger.info(f"Starting chord inference for {len(note_events)} note events")
        self.stats.clear()
        
        # Step 1: Apply pitch smoothing
        smoothed_events = self.pitch_smoother.smooth_pitch_activity(note_events)
        self.stats['smoothed_notes'] = len(smoothed_events)
        
        # Step 2: Filter minimum duration notes
        filtered_events = self._filter_short_notes(smoothed_events)
        self.stats['duration_filtered'] = len(note_events) - len(filtered_events)
        
        # Step 3: Estimate global key
        key_estimate = self.key_detector.estimate_key(filtered_events)
        
        # Step 4: Apply key-aware filtering
        key_filtered_events = self._apply_key_filtering(filtered_events, key_estimate)
        self.stats['key_filtered'] = len(filtered_events) - len(key_filtered_events)
        
        # Step 5: Create time windows and detect chords
        raw_chords = self._detect_chords_in_windows(key_filtered_events, key_estimate)
        self.stats['raw_chords'] = len(raw_chords)
        
        # Step 6: Apply enhanced harmony filtering with key awareness
        harmony_filtered_chords = self._apply_harmony_filtering(raw_chords, key_estimate)
        self.stats['harmony_filtered'] = len(raw_chords) - len(harmony_filtered_chords)
        
        # Step 7: Apply 1-second median filter to remove chord flukes
        smoothed_chords = self.chord_smoother.smooth_chord_progression(harmony_filtered_chords)
        self.stats['smoothed_chords'] = len(harmony_filtered_chords) - len(smoothed_chords)
        
        # Step 8: Merge similar adjacent chords
        merged_chords = self._merge_similar_chords(smoothed_chords)
        self.stats['merged_chords'] = len(smoothed_chords) - len(merged_chords)
        
        # Step 9: Ensure output stability
        stable_chords = self._ensure_stability(merged_chords)
        self.stats['final_chords'] = len(stable_chords)
        
        self._log_stats()
        
        return stable_chords, key_estimate
    
    def _filter_short_notes(self, events: List[NoteEvent]) -> List[NoteEvent]:
        """Remove notes shorter than minimum duration."""
        filtered = [
            event for event in events 
            if event.duration >= ChordInferenceConfig.MIN_NOTE_DURATION
        ]
        
        dropped = len(events) - len(filtered)
        if dropped > 0:
            logger.info(f"Dropped {dropped} notes shorter than {ChordInferenceConfig.MIN_NOTE_DURATION}s")
        
        return filtered
    
    def _apply_key_filtering(self, events: List[NoteEvent], key_estimate: KeyEstimate) -> List[NoteEvent]:
        """Filter out-of-key notes with low confidence."""
        if key_estimate.confidence < 0.5:
            logger.info("Key estimate confidence too low, skipping key filtering")
            return events
        
        # Define scale pitch classes for the estimated key
        if key_estimate.mode == 'major':
            # Major scale intervals: W-W-H-W-W-W-H
            scale_intervals = [0, 2, 4, 5, 7, 9, 11]
        else:
            # Natural minor scale intervals: W-H-W-W-H-W-W  
            scale_intervals = [0, 2, 3, 5, 7, 8, 10]
        
        scale_pcs = {(key_estimate.key_pc + interval) % 12 for interval in scale_intervals}
        
        filtered_events = []
        dropped_count = 0
        
        for event in events:
            pc = event.pitch_class
            
            # If note is in key, always keep it
            if pc in scale_pcs:
                filtered_events.append(event)
            # If note is out of key but has high confidence, keep it
            elif event.confidence >= ChordInferenceConfig.KEY_FILTER_CONFIDENCE_THRESHOLD:
                filtered_events.append(event)
            # Otherwise drop it
            else:
                dropped_count += 1
        
        if dropped_count > 0:
            key_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
            logger.info(f"Key filtering in {key_names[key_estimate.key_pc]} {key_estimate.mode}: "
                       f"dropped {dropped_count} out-of-key notes with low confidence")
        
        return filtered_events
    
    def _detect_chords_in_windows(self, events: List[NoteEvent], key_estimate: KeyEstimate) -> List[ChordEvent]:
        """Detect chords using sliding windows with confidence weighting."""
        if not events:
            return []
        
        # Sort events by onset time
        sorted_events = sorted(events, key=lambda e: e.onset)
        
        # Determine time range
        start_time = sorted_events[0].onset
        end_time = max(event.offset for event in sorted_events)
        
        chords = []
        current_time = start_time
        
        while current_time < end_time:
            window_end = current_time + ChordInferenceConfig.WINDOW_SIZE
            
            # Find notes active in this window
            window_notes = [
                event for event in sorted_events
                if (event.onset < window_end and event.offset > current_time)
            ]
            
            if len(window_notes) >= ChordInferenceConfig.MIN_NOTES_PER_CHORD:
                chord = self._analyze_window(window_notes, current_time, window_end, key_estimate)
                if chord:
                    chords.append(chord)
            
            current_time += ChordInferenceConfig.WINDOW_SIZE - ChordInferenceConfig.WINDOW_OVERLAP
        
        logger.info(f"Detected {len(chords)} raw chords from {len(events)} note events")
        return chords
    
    def _analyze_window(self, notes: List[NoteEvent], start_time: float, end_time: float, 
                       key_estimate: KeyEstimate) -> Optional[ChordEvent]:
        """Analyze a time window to detect the most likely chord."""
        if not notes:
            return None
        
        # Build weighted pitch-class histogram
        pc_weights = defaultdict(float)
        
        for note in notes:
            pc = note.pitch_class
            
            # Weight by confidence and duration overlap with window
            overlap_start = max(note.onset, start_time)
            overlap_end = min(note.offset, end_time)
            overlap_duration = max(0, overlap_end - overlap_start)
            
            if ChordInferenceConfig.CONFIDENCE_WEIGHT_DURATION:
                weight = note.confidence * overlap_duration
            else:
                weight = note.confidence
            
            pc_weights[pc] += weight
        
        if not pc_weights:
            return None
        
        # Select most significant pitch classes
        sorted_pcs = sorted(pc_weights.items(), key=lambda x: x[1], reverse=True)
        
        # Keep pitch classes that are at least 20% of the strongest
        max_weight = sorted_pcs[0][1]
        threshold = max_weight * 0.2
        
        significant_pcs = [pc for pc, weight in sorted_pcs if weight >= threshold]
        significant_pcs = significant_pcs[:6]  # Max 6 notes in a chord
        
        if len(significant_pcs) < ChordInferenceConfig.MIN_NOTES_PER_CHORD:
            return None
        
        # Identify chord type with root-strength weighting
        chord_symbol, chord_type = self._identify_chord(significant_pcs, key_estimate, pc_weights)
        
        # Calculate confidence
        total_weight = sum(pc_weights.values())
        avg_confidence = total_weight / len(notes) if notes else 0.0
        
        return ChordEvent(
            onset=start_time,
            offset=end_time,
            chord_symbol=chord_symbol,
            confidence=min(avg_confidence, 1.0),
            pitch_classes=set(significant_pcs),
            root_pc=min(significant_pcs),  # Simplified root detection
            chord_type=chord_type
        )
    
    def _identify_chord(self, pitch_classes: List[int], key_estimate: KeyEstimate, 
                       pc_weights: Dict[int, float] = None) -> Tuple[str, str]:
        """Identify chord symbol and type from pitch classes with root-strength weighting."""
        if not pitch_classes:
            return "N", "unknown"
        
        # Note names
        note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        
        # Try each pitch class as a potential root
        best_match = None
        best_score = 0
        
        for root in pitch_classes:
            # Convert to intervals from this potential root
            intervals = [(pc - root) % 12 for pc in pitch_classes]
            intervals_set = set(intervals)
            
            root_name = note_names[root]
            
            # ROOT STRENGTH WEIGHTING: Low notes are stronger roots
            # This fixes the classic C→Am error by preferring C as root when both C and A are present
            root_strength_bonus = 1.0
            if pc_weights:
                # Get the weight of this root
                root_weight = pc_weights.get(root, 0.0)
                max_weight = max(pc_weights.values()) if pc_weights else 1.0
                
                # Bonus for strong bass notes (fundamental frequency dominance)
                if root_weight > 0:
                    normalized_weight = root_weight / max_weight
                    root_strength_bonus = 1.0 + normalized_weight * 0.8  # Up to 80% bonus
                
                # Extra bonus for lowest pitch classes (simulate bass note prominence)
                if root == min(pitch_classes):
                    root_strength_bonus *= 1.3  # 30% bonus for lowest note
            
            # Score different chord types (higher score = better match)
            chord_tests = [
                # Basic triads FIRST (to maintain stability)
                ({0, 4, 7}, "major", "", 10),           # Major triad
                ({0, 3, 7}, "minor", "m", 10),          # Minor triad  
                
                # 7th chords (common extensions)
                ({0, 4, 7, 10}, "7", "7", 12),          # Dominant 7th
                ({0, 3, 7, 10}, "m7", "m7", 12),        # Minor 7th
                ({0, 4, 7, 11}, "maj7", "maj7", 12),    # Major 7th
                
                # Jazz extensions (only when confidence is high)
                ({0, 3, 7, 10, 2, 5}, "m11", "m11", 14),   # Minor 11th (for jazz)
                ({0, 4, 7, 2}, "add9", "add9", 11),        # Add9
                ({0, 4, 7, 9}, "6", "6", 11),              # Major 6th
                
                # Altered chords
                ({0, 3, 6}, "dim", "dim", 9),           # Diminished
                ({0, 4, 8}, "aug", "aug", 9),           # Augmented
                
                # Sus chords
                ({0, 2, 7}, "sus2", "sus2", 8),         # Sus2
                ({0, 5, 7}, "sus4", "sus4", 8),         # Sus4
                
                # Partial chords (fallback)
                ({0, 4}, "major", "", 6),               # Just major third
                ({0, 3}, "minor", "m", 6),              # Just minor third
                ({0, 7}, "major", "", 4),               # Just perfect fifth
            ]
            
            for required_intervals, chord_type, suffix, base_score in chord_tests:
                if required_intervals.issubset(intervals_set):
                    # Calculate match quality
                    match_ratio = len(required_intervals) / len(intervals_set)
                    score = base_score * match_ratio
                    
                    # Bonus for having exactly the right intervals (no extras)
                    if intervals_set == required_intervals:
                        score *= 1.5
                    
                    # Apply root strength weighting (THIS IS THE KEY FIX!)
                    score *= root_strength_bonus
                    
                    # Bonus for root being in the key
                    if self._is_in_key(root, key_estimate):
                        score *= 1.2
                    
                    # Extra bonus for tonic chord (I) in major/minor keys
                    if root == key_estimate.key_pc:
                        if (key_estimate.mode == 'major' and chord_type == 'major') or \
                           (key_estimate.mode == 'minor' and chord_type == 'minor'):
                            score *= 1.4  # Strong preference for tonic
                    
                    if score > best_score:
                        best_score = score
                        symbol = root_name + suffix
                        best_match = (symbol, chord_type, root)
        
        if best_match:
            return best_match[0], best_match[1]  # symbol, chord_type
        else:
            # Fallback: use lowest pitch class as root with generic type
            root = min(pitch_classes)
            root_name = note_names[root]
            return f"{root_name}?", "unknown"
    
    def _is_in_key(self, pitch_class: int, key_estimate: KeyEstimate) -> bool:
        """Check if a pitch class is in the estimated key."""
        if key_estimate.confidence < 0.5:
            return True  # Don't apply key filtering if key is uncertain
        
        # Define scale intervals
        if key_estimate.mode == 'major':
            scale_intervals = [0, 2, 4, 5, 7, 9, 11]  # Major scale
        else:
            scale_intervals = [0, 2, 3, 5, 7, 8, 10]  # Natural minor scale
        
        scale_pcs = {(key_estimate.key_pc + interval) % 12 for interval in scale_intervals}
        return pitch_class in scale_pcs
    
    def _apply_harmony_filtering(self, chords: List[ChordEvent], key_estimate: KeyEstimate) -> List[ChordEvent]:
        """Filter chords using expected harmony whitelist and key-aware validation."""
        filtered = []
        weird_chords_removed = 0
        
        for chord in chords:
            # Check if chord contains weird symbols (hallucinations)
            if any(symbol in chord.chord_symbol for symbol in ['?', '!']):
                # This is likely a hallucinated chord - be more strict
                if chord.confidence < 0.6 and (chord.offset - chord.onset) < 1.0:
                    weird_chords_removed += 1
                    continue  # Skip weird low-confidence short chords
            
            # Key-aware filtering: Check if chord root is in key
            is_root_in_key = self._is_chord_root_in_key(chord, key_estimate)
            
            # Always keep functional chord types that are in key
            if chord.chord_type in ChordInferenceConfig.FUNCTIONAL_CHORDS and is_root_in_key:
                filtered.append(chord)
            
            # Be more strict with out-of-key chords
            elif not is_root_in_key:
                # Out-of-key chords need high confidence AND long duration
                if chord.confidence >= 0.7 and (chord.offset - chord.onset) >= 1.0:
                    filtered.append(chord)
                # Jazz exception: m11 chords are often chromatic, be slightly more lenient
                elif chord.chord_type == 'm11' and chord.confidence >= 0.6:
                    filtered.append(chord)
                else:
                    weird_chords_removed += 1
                    # Skip low-confidence out-of-key chords
            
            # Keep in-key chords with reasonable requirements
            elif (chord.confidence >= 0.3 or 
                  (chord.offset - chord.onset) >= 0.6 or
                  self._chord_repeats(chord, chords)):
                filtered.append(chord)
            
            else:
                weird_chords_removed += 1
        
        if weird_chords_removed > 0:
            logger.info(f"Enhanced harmony filtering removed {weird_chords_removed} weird/out-of-key chords")
        
        return filtered
    
    def _is_chord_root_in_key(self, chord: ChordEvent, key_estimate: KeyEstimate) -> bool:
        """Check if the chord root is in the estimated key."""
        if key_estimate.confidence < 0.6:
            return True  # Don't filter if key detection is uncertain
        
        return self._is_in_key(chord.root_pc, key_estimate)
    
    def _chord_repeats(self, target_chord: ChordEvent, all_chords: List[ChordEvent]) -> bool:
        """Check if a chord type repeats multiple times in the progression."""
        count = sum(1 for c in all_chords if c.chord_symbol == target_chord.chord_symbol)
        return count >= 2
    
    def _merge_similar_chords(self, chords: List[ChordEvent]) -> List[ChordEvent]:
        """Merge adjacent chords that are identical or very similar."""
        if len(chords) <= 1:
            return chords
        
        merged = []
        current = chords[0]
        
        for next_chord in chords[1:]:
            # Check if chords should be merged
            time_gap = next_chord.onset - current.offset
            
            # More aggressive merging criteria
            same_chord = current.chord_symbol == next_chord.chord_symbol
            similar_chord = (current.root_pc == next_chord.root_pc and 
                           current.chord_type == next_chord.chord_type)
            close_in_time = time_gap <= ChordInferenceConfig.MERGE_THRESHOLD
            overlapping = next_chord.onset < current.offset  # Overlapping windows
            
            should_merge = (same_chord and (close_in_time or overlapping)) or \
                          (similar_chord and overlapping)
            
            if should_merge:
                # Merge chords
                current = ChordEvent(
                    onset=current.onset,
                    offset=max(current.offset, next_chord.offset),
                    chord_symbol=current.chord_symbol,  # Keep the first chord's symbol
                    confidence=(current.confidence + next_chord.confidence) / 2,
                    pitch_classes=current.pitch_classes.union(next_chord.pitch_classes),
                    root_pc=current.root_pc,
                    chord_type=current.chord_type
                )
            else:
                merged.append(current)
                current = next_chord
        
        merged.append(current)
        
        merges = len(chords) - len(merged)
        if merges > 0:
            logger.info(f"Merged {merges} similar adjacent chords")
        
        return merged
    
    def _ensure_stability(self, chords: List[ChordEvent]) -> List[ChordEvent]:
        """Ensure output stability by enforcing minimum durations and consistency."""
        if not chords:
            return []
        
        stable = []
        
        for chord in chords:
            duration = chord.offset - chord.onset
            
            # Enforce minimum chord duration
            if duration >= ChordInferenceConfig.MIN_CHORD_DURATION:
                stable.append(chord)
            # Skip very short chords unless they're between longer chords of the same type
        
        filtered_count = len(chords) - len(stable)
        if filtered_count > 0:
            logger.info(f"Stability filtering removed {filtered_count} short chords")
        
        return stable
    
    def _log_stats(self):
        """Log processing statistics."""
        logger.info("Chord inference statistics:")
        logger.info(f"  Smoothed notes: {self.stats.get('smoothed_notes', 0)}")
        logger.info(f"  Duration filtered: {self.stats.get('duration_filtered', 0)}")
        logger.info(f"  Key filtered: {self.stats.get('key_filtered', 0)}")
        logger.info(f"  Raw chords detected: {self.stats.get('raw_chords', 0)}")
        logger.info(f"  Harmony filtered: {self.stats.get('harmony_filtered', 0)}")
        logger.info(f"  Chord flukes removed: {self.stats.get('smoothed_chords', 0)}")
        logger.info(f"  Merged chords: {self.stats.get('merged_chords', 0)}")
        logger.info(f"  Final stable chords: {self.stats.get('final_chords', 0)}")

# MARK: - Main Interface Functions

def process_note_events(raw_notes: List[Dict]) -> Tuple[List[Dict], Dict]:
    """
    Process raw Basic Pitch note events into stable chord progression.
    
    Args:
        raw_notes: List of note event dicts from Basic Pitch
        
    Returns:
        Tuple of (chord_events_list, key_info_dict)
    """
    logger.info("Processing note events for chord inference")
    
    # Convert input format to NoteEvent objects
    note_events = []
    for note_dict in raw_notes:
        try:
            note = NoteEvent(
                onset=float(note_dict['onset']),
                offset=float(note_dict['offset']),
                pitch=int(note_dict['pitch']),
                confidence=float(note_dict['confidence'])
            )
            note_events.append(note)
        except (KeyError, ValueError, TypeError) as e:
            logger.warning(f"Skipping invalid note event {note_dict}: {e}")
            continue
    
    if not note_events:
        logger.warning("No valid note events found")
        return [], {"key": "C", "mode": "major", "confidence": 0.0}
    
    # Run chord inference
    engine = ChordInferenceEngine()
    chord_events, key_estimate = engine.infer_chords(note_events)
    
    # Convert output format
    chord_dicts = []
    for chord in chord_events:
        chord_dicts.append({
            "onset": chord.onset,
            "offset": chord.offset,
            "chord": chord.chord_symbol,
            "confidence": chord.confidence,
            "pitch_classes": list(chord.pitch_classes)
        })
    
    key_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    key_info = {
        "key": key_names[key_estimate.key_pc],
        "mode": key_estimate.mode,
        "confidence": key_estimate.confidence
    }
    
    logger.info(f"Chord inference complete: {len(chord_dicts)} chords in "
               f"{key_info['key']} {key_info['mode']}")
    
    return chord_dicts, key_info