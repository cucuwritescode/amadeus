# Basic Pitch Model Setup

## Required Model
Place the `nmp.mlpackage` file (Core ML version of Spotify's Basic Pitch model) in this directory.

## Model Information
- **File**: `nmp.mlpackage`
- **Source**: Spotify's Basic Pitch model converted to Core ML
- **Input**: Audio waveform (22,050 Hz, mono, float32)
- **Outputs**: 
  - `onset`: Onset probability matrix [time, pitch]
  - `frame`: Frame probability matrix [time, pitch] 
  - `contour`: Pitch bend matrix [time, pitch] (optional)

## Fallback Behavior
If the model is not found, the app will fall back to the simulated chord detector for development purposes.

## Integration Steps
1. Convert Basic Pitch model to Core ML format
2. Place `nmp.mlpackage` in this directory
3. Add to Xcode project as a bundle resource
4. Enable "Add to Target" in Xcode project settings