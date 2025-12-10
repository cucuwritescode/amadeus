#!/usr/bin/env python3
"""
Basic Pitch Server for iOS Chord Recognition App

This server provides a single endpoint to accept audio files and return
note events using Spotify's Basic Pitch model. The iOS app sends audio
files via HTTP POST and receives JSON note events for chord assembly.
"""

import os
import tempfile
import traceback
import time
import shutil
import subprocess
from typing import List, Optional, Dict
import logging

import uvicorn
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import numpy as np
import basic_pitch
from basic_pitch import ICASSP_2022_MODEL_PATH
from basic_pitch.inference import predict
import librosa
import soundfile as sf

# Import our new chord inference module
from chord_inference import process_note_events

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
MAX_FILE_SIZE_MB = 50  # 50MB limit
SUPPORTED_FORMATS = {'.wav', '.mp3', '.m4a', '.aac', '.flac', '.ogg'}

app = FastAPI(
    title="Basic Pitch Server",
    description="Audio-to-MIDI transcription service for chord recognition",
    version="1.0.0"
)

# Add CORS middleware for web client compatibility
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class NoteEvent(BaseModel):
    """A detected note with timing and pitch information."""
    onset: float
    offset: float
    pitch: int
    confidence: float

class ChordEvent(BaseModel):
    """A detected chord with timing and musical information."""
    onset: float
    offset: float
    chord: str
    confidence: float
    pitch_classes: List[int]

class KeyInfo(BaseModel):
    """Key estimation information."""
    key: str
    mode: str
    confidence: float

class AnalysisResponse(BaseModel):
    """Response containing detected note events and chord progression."""
    notes: List[NoteEvent]
    chords: List[ChordEvent]
    key: KeyInfo

@app.get("/")
async def root():
    """Health check endpoint."""
    return {"message": "Basic Pitch Server is running", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    """Detailed health check with model status."""
    try:
        # Test that Basic Pitch can be imported and model path exists
        model_available = os.path.exists(ICASSP_2022_MODEL_PATH)
        return {
            "status": "healthy",
            "model_available": model_available,
            "model_path": ICASSP_2022_MODEL_PATH
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e)
        }

@app.post("/analyze", response_model=AnalysisResponse)
async def analyze_audio(file: UploadFile = File(...)):
    """
    Analyze an audio file and return note events.
    
    Args:
        file: Audio file (WAV, MP3, M4A, AAC, FLAC, OGG)
        
    Returns:
        JSON containing list of note events with onset, offset, pitch, and confidence
    """
    logger.info(f"Received file: {file.filename}, size: {file.size} bytes")
    
    # Validate file
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided")
    
    # Check file size
    if file.size and file.size > MAX_FILE_SIZE_MB * 1024 * 1024:
        raise HTTPException(
            status_code=413, 
            detail=f"File too large. Maximum size: {MAX_FILE_SIZE_MB}MB"
        )
    
    # Check file extension
    file_ext = os.path.splitext(file.filename.lower())[1]
    if file_ext not in SUPPORTED_FORMATS:
        raise HTTPException(
            status_code=415,
            detail=f"Unsupported format. Supported: {', '.join(SUPPORTED_FORMATS)}"
        )
    
    temp_input = None
    temp_wav = None
    
    try:
        # Save uploaded file temporarily
        temp_input = tempfile.NamedTemporaryFile(delete=False, suffix=file_ext)
        try:
            content = await file.read()
            temp_input.write(content)
            temp_input.flush()
            os.fsync(temp_input.fileno())  # Force write to disk
            temp_input_path = temp_input.name
        finally:
            temp_input.close()  # Ensure file is properly closed before reading
        
        logger.info(f"Saved to temp file: {temp_input_path}")
        
        # 🔍 DEBUGGING: Save a copy of the uploaded file for inspection
        debug_filename = f"received_from_ios_{int(time.time())}.wav"
        debug_path = os.path.join(os.path.dirname(temp_input_path), debug_filename)
        try:
            import shutil
            shutil.copy2(temp_input_path, debug_path)
            logger.info(f"📁 DEBUG: Saved uploaded file copy to: {debug_path}")
            logger.info(f"   You can inspect this file manually to check format compatibility")
        except Exception as e:
            logger.warning(f"Could not save debug copy: {e}")
        
        # Convert to WAV format if needed
        if file_ext != '.wav':
            temp_wav = tempfile.NamedTemporaryFile(delete=False, suffix='.wav')
            temp_wav_path = temp_wav.name
            temp_wav.close()  # Close handle so we can write to it
            
            logger.info(f"Converting {file_ext} to WAV")
            audio, sr = librosa.load(temp_input_path, sr=None, mono=True)
            sf.write(temp_wav_path, audio, sr)
            audio_path = temp_wav_path
        else:
            audio_path = temp_input_path
        
        logger.info("Running Basic Pitch inference...")
        
        # Load and inspect audio with multiple robust fallback methods
        audio = None
        sr = None
        
        # Method 1: Try librosa (standard approach)
        try:
            logger.info("🔵 Method 1: Loading audio with librosa...")
            audio, sr = librosa.load(audio_path, sr=None, mono=True)
            logger.info(f"   Librosa result: shape={audio.shape}, dtype={audio.dtype}, sr={sr}")
            
            if audio.size == 0:
                logger.warning("   ⚠️ Librosa returned empty array")
                audio = None
            else:
                logger.info(f"   ✅ Librosa success: {len(audio)} samples, duration={len(audio) / sr:.2f}s")
                logger.info(f"   Audio range: [{audio.min():.3f}, {audio.max():.3f}]")
                
        except Exception as e:
            logger.warning(f"   ❌ Librosa failed: {e}")
            audio = None

        # Method 2: Try soundfile directly
        if audio is None or audio.size == 0:
            try:
                logger.info("🟡 Method 2: Loading audio with soundfile...")
                audio, sr = sf.read(audio_path, dtype='float32')
                if audio.ndim > 1:
                    audio = audio.mean(axis=1)  # Convert stereo to mono
                logger.info(f"   Soundfile result: shape={audio.shape}, dtype={audio.dtype}, sr={sr}")
                
                if audio.size == 0:
                    logger.warning("   ⚠️ Soundfile returned empty array")
                    audio = None
                else:
                    logger.info(f"   ✅ Soundfile success: {len(audio)} samples")
                    logger.info(f"   Audio range: [{audio.min():.3f}, {audio.max():.3f}]")
                    
            except Exception as e:
                logger.warning(f"   ❌ Soundfile failed: {e}")
                audio = None

        # Method 3: Try ffmpeg conversion + librosa
        if audio is None or audio.size == 0:
            try:
                logger.info("🟠 Method 3: Converting with ffmpeg then loading...")
                
                # Use ffmpeg to convert to a standard format
                converted_path = audio_path.replace('.wav', '_ffmpeg.wav')
                cmd = [
                    'ffmpeg', '-y', '-i', audio_path,
                    '-ar', '44100',  # 44.1kHz
                    '-ac', '1',      # Mono
                    '-c:a', 'pcm_s16le',  # 16-bit PCM
                    converted_path
                ]
                
                result = subprocess.run(cmd, capture_output=True, text=True)
                if result.returncode == 0:
                    logger.info(f"   ✅ ffmpeg conversion successful")
                    
                    # Now try librosa on the converted file
                    audio, sr = librosa.load(converted_path, sr=None, mono=True)
                    logger.info(f"   FFmpeg+librosa result: shape={audio.shape}, dtype={audio.dtype}, sr={sr}")
                    
                    if audio.size > 0:
                        logger.info(f"   ✅ FFmpeg method success: {len(audio)} samples")
                        logger.info(f"   Audio range: [{audio.min():.3f}, {audio.max():.3f}]")
                    else:
                        logger.warning("   ⚠️ FFmpeg conversion produced empty array")
                        audio = None
                        
                    # Clean up converted file
                    try:
                        os.unlink(converted_path)
                    except:
                        pass
                else:
                    logger.warning(f"   ❌ ffmpeg failed: {result.stderr}")
                    audio = None
                    
            except Exception as e:
                logger.warning(f"   ❌ FFmpeg method failed: {e}")
                audio = None

        # Method 4: Try pydub as last resort
        if audio is None or audio.size == 0:
            try:
                logger.info("🔴 Method 4: Loading audio with pydub...")
                from pydub import AudioSegment
                
                audio_segment = AudioSegment.from_file(audio_path)
                if audio_segment.channels > 1:
                    audio_segment = audio_segment.set_channels(1)
                    
                # Convert to numpy array
                audio = np.array(audio_segment.get_array_of_samples(), dtype=np.float32)
                audio = audio / (2**15)  # Normalize 16-bit to [-1, 1]
                sr = audio_segment.frame_rate
                
                logger.info(f"   Pydub result: shape={audio.shape}, dtype={audio.dtype}, sr={sr}")
                
                if audio.size == 0:
                    logger.warning("   ⚠️ Pydub returned empty array")
                    audio = None
                else:
                    logger.info(f"   ✅ Pydub success: {len(audio)} samples")
                    logger.info(f"   Audio range: [{audio.min():.3f}, {audio.max():.3f}]")
                    
            except ImportError:
                logger.error("   ❌ Pydub not installed")
                audio = None
            except Exception as e:
                logger.warning(f"   ❌ Pydub failed: {e}")
                audio = None

        # Final validation
        if audio is None or audio.size == 0:
            logger.error("🚨 ALL AUDIO LOADING METHODS FAILED")
            logger.error(f"   File exists: {os.path.exists(audio_path)}")
            logger.error(f"   File size: {os.path.getsize(audio_path) if os.path.exists(audio_path) else 'N/A'} bytes")
            logger.error(f"   Debug copy saved to: {debug_path}")
            logger.error("   Please inspect the debug copy manually to determine the exact format issue")
            
            # Return empty notes instead of crashing
            logger.info("   Returning empty note list instead of crashing")
            return AnalysisResponse(
                notes=[],
                chords=[],
                key=KeyInfo(key="C", mode="major", confidence=0.0)
            )

        logger.info(f"✅ Audio successfully loaded: {len(audio)} samples at {sr} Hz, duration={len(audio) / sr:.2f}s")
        
        # 🔧 FIX 1: Pad audio to minimum length to prevent Basic Pitch onset array crashes
        MIN_LEN = int(3 * sr)  # 3 seconds minimum
        original_length = len(audio)
        
        if len(audio) < MIN_LEN:
            logger.info(f"📏 Audio too short ({len(audio)} < {MIN_LEN} samples), padding to 3 seconds...")
            padded = np.zeros(MIN_LEN, dtype=np.float32)
            padded[:len(audio)] = audio
            audio = padded
            logger.info(f"   ✅ Padded from {original_length} to {len(audio)} samples")
        
        # Save padded audio to a temporary file for Basic Pitch
        padded_path = audio_path.replace('.wav', '_padded.wav')
        sf.write(padded_path, audio, int(sr))
        
        # Run Basic Pitch prediction with error handling
        try:
            logger.info("🎵 Running Basic Pitch inference on padded audio...")
            
            # 🔧 FIX 2: Catch Basic Pitch internal zero-size array crashes
            model_output, midi_data, note_events = predict(
                padded_path,
                onset_threshold=0.5,
                frame_threshold=0.3,
                minimum_note_length=0.127,  # ~1/8 second minimum note
                minimum_frequency=None,
                maximum_frequency=None,
                multiple_pitch_bends=False,
                melodia_trick=True,
                midi_tempo=120
            )
            
            logger.info(f"✅ Basic Pitch completed successfully")
            logger.info(f"   Model output shapes: {[arr.shape if hasattr(arr, 'shape') else type(arr) for arr in model_output] if model_output else 'None'}")
            logger.info(f"   Note events: {len(note_events) if hasattr(note_events, '__len__') else 'unknown'} events detected")
            
        except ValueError as e:
            # 🔧 FIX 2: Handle Basic Pitch's internal "zero-size array" crashes gracefully
            if "zero-size array" in str(e) or "minimum" in str(e) or "maximum" in str(e):
                logger.warning(f"⚠️ Basic Pitch internal error (likely empty onset array): {e}")
                logger.info("   Returning empty notes list instead of crashing")
                return AnalysisResponse(
                    notes=[],
                    chords=[],
                    key=KeyInfo(key="C", mode="major", confidence=0.0)
                )
            else:
                logger.error(f"Basic Pitch ValueError: {e}")
                raise
                
        except Exception as e:
            logger.error(f"Basic Pitch prediction failed: {e}")
            logger.error(f"Error type: {type(e)}")
            raise
        
        finally:
            # Clean up padded audio file
            try:
                if 'padded_path' in locals() and os.path.exists(padded_path):
                    os.unlink(padded_path)
            except:
                pass
        
        # Convert note events to our JSON format
        json_notes = []
        
        # Handle case where note_events might be empty or None
        if note_events is None or len(note_events) == 0:
            logger.info("📝 No note events detected by Basic Pitch")
            return AnalysisResponse(
                notes=[],
                chords=[],
                key=KeyInfo(key="C", mode="major", confidence=0.0)
            )
        
        logger.info(f"📝 Processing {len(note_events)} note events...")
        
        # Calculate original audio duration for filtering padded notes
        original_duration = original_length / sr
        logger.info(f"   Original audio duration: {original_duration:.2f}s, filtering notes beyond this time")
        
        filtered_count = 0
        for i, note in enumerate(note_events):
            try:
                if len(note) < 4:
                    logger.warning(f"Note {i} has insufficient data: {note}")
                    continue
                
                onset_time = float(note[0])
                offset_time = float(note[1])
                
                # Skip notes that start after the original audio ended (from padding)
                if onset_time >= original_duration:
                    filtered_count += 1
                    continue
                
                # Clip notes that extend beyond original audio
                if offset_time > original_duration:
                    offset_time = original_duration
                    
                json_notes.append(NoteEvent(
                    onset=onset_time,         # Start time in seconds
                    offset=offset_time,       # End time in seconds  
                    pitch=int(note[2]),       # MIDI pitch number
                    confidence=float(note[3]) # Confidence score
                ))
            except (IndexError, ValueError, TypeError) as e:
                logger.warning(f"Failed to process note {i}: {note}, error: {e}")
                continue
        
        if filtered_count > 0:
            logger.info(f"   🔄 Filtered out {filtered_count} notes from padded region")
        
        logger.info(f"Successfully converted {len(json_notes)} JSON note events")
        
        # NEW: Run advanced chord inference on the note events
        try:
            logger.info("🎼 Running advanced chord inference...")
            
            # Convert note events to the format expected by chord inference
            note_dicts = []
            for note in json_notes:
                note_dicts.append({
                    'onset': note.onset,
                    'offset': note.offset,
                    'pitch': note.pitch,
                    'confidence': note.confidence
                })
            
            # Process with advanced chord inference
            chord_events, key_info = process_note_events(note_dicts)
            
            logger.info(f"✅ Chord inference complete: {len(chord_events)} chords detected")
            logger.info(f"   Estimated key: {key_info['key']} {key_info['mode']} "
                       f"(confidence: {key_info['confidence']:.3f})")
            
            # Convert to response format
            chord_responses = []
            for chord_dict in chord_events:
                chord_responses.append(ChordEvent(
                    onset=chord_dict['onset'],
                    offset=chord_dict['offset'],
                    chord=chord_dict['chord'],
                    confidence=chord_dict['confidence'],
                    pitch_classes=chord_dict['pitch_classes']
                ))
            
            key_response = KeyInfo(
                key=key_info['key'],
                mode=key_info['mode'],
                confidence=key_info['confidence']
            )
            
        except Exception as e:
            logger.error(f"Chord inference failed: {e}")
            logger.error(traceback.format_exc())
            # Return empty chord progression on failure
            chord_responses = []
            key_response = KeyInfo(key="C", mode="major", confidence=0.0)
        
        return AnalysisResponse(
            notes=json_notes,
            chords=chord_responses,
            key=key_response
        )
        
    except Exception as e:
        logger.error(f"Analysis failed: {str(e)}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")
        
    finally:
        # Clean up temporary files
        try:
            if temp_input_path and os.path.exists(temp_input_path):
                os.unlink(temp_input_path)
                logger.info("Cleaned up input temp file")
        except Exception as e:
            logger.warning(f"Failed to clean up input temp file: {e}")
            
        try:
            if temp_wav and hasattr(temp_wav, 'name') and os.path.exists(temp_wav.name):
                os.unlink(temp_wav.name)
                logger.info("Cleaned up WAV temp file")
        except Exception as e:
            logger.warning(f"Failed to clean up WAV temp file: {e}")

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )