//
//  BasicPitchAnalyzer.swift
//  amadeus
//
//  created by facundo franchino on 09/11/2025.
//  copyright © 2025 facundo franchino. all rights reserved.
//
//  local analyser fallback when http server is unavailable
//  coreml mode falls back to simulation (model not bundled for distribution)
//
//  acknowledgements:
//  - basic pitch model by rachel bittner et al. (icassp 2022)
//

import Foundation
import AVFoundation

// MARK: - Basic Pitch Analyzer

//local chord analyser that uses simulation mode
//real analysis is performed server-side via BasicPitchHTTPClient
//coreml option visible in settings but uses simulation fallback
class BasicPitchAnalyzer: ChordAnalyzer {

    init() {
        print("BasicPitchAnalyzer initialized (simulation fallback)")
    }

    func analyze(audioBuffer: AVAudioPCMBuffer, sampleRate: Float) async -> [ChordDetection] {
        print("BasicPitchAnalyzer: CoreML model not bundled, using simulation")
        print("  Tip: Use HTTP Server mode for real chord analysis")
        return await SimulatedChordAnalyzer().analyze(audioBuffer: audioBuffer, sampleRate: sampleRate)
    }
}
