import Foundation
//created by Facundo Franchino
//configuration settings for basic pitch analysis system
struct BasicPitchConfig {
    
    // MARK: - analysis mode configuration
    
    //available analysis modes for chord detection
    enum AnalysisMode {
        case http(serverURL: String)
        case coreML
        case simulation
    }
    
    //default mode - can be changed based on user preference
    static var defaultMode: AnalysisMode {
        let userMode = UserDefaults.standard.string(forKey: "analysisMode") ?? "http"  //default to http
        var serverURL = UserDefaults.standard.string(forKey: "serverURL") ?? defaultServerURL
        
        //temporary: force update old ips to new ip
        if serverURL.contains("localhost") || serverURL.contains("127.0.0.1") || serverURL.contains("192.168.68.121") || serverURL.contains("192.168.0.29") {
            print("Migrating old URL (\(serverURL)) to new IP...")
            serverURL = defaultServerURL
            UserDefaults.standard.set(serverURL, forKey: "serverURL")
            UserDefaults.standard.synchronize()
        }
        
        print("BasicPitchConfig - User selected mode: '\(userMode)', Server URL: '\(serverURL)'")
        print("UserDefaults raw serverURL: '\(UserDefaults.standard.string(forKey: "serverURL") ?? "nil")'")
        
        switch userMode {
        case "http":
            print("Using HTTP Server mode")
            return .http(serverURL: serverURL)
        case "coreml":
            print("Using CoreML mode")
            return .coreML
        case "simulation":
            print("Using Simulation mode")
            return .simulation
        default:
            print("Unknown mode '\(userMode)', defaulting to HTTP")
            return .http(serverURL: serverURL)
        }
    }
    
    // MARK: - server configuration
    
    static let defaultServerURL = "http://192.168.1.111:8000"
    static let serverTimeout: TimeInterval = 120  //2 minutes
    
    //debug method to reset settings
    static func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: "serverURL")
        UserDefaults.standard.removeObject(forKey: "analysisMode")
        UserDefaults.standard.synchronize()
        print("Settings reset to defaults")
    }
    
    //force update to new server url
    static func forceUpdateServerURL() {
        UserDefaults.standard.removeObject(forKey: "analysisMode")
        UserDefaults.standard.removeObject(forKey: "serverURL")
        print("Reset all analysis settings to defaults")
    }
    
    //check if server is reachable (simplified check)
    static var isServerReachable: Bool {
        //for now, assume localhost server for development
        //in production, this would do actual network check
        return false  //set to true when running local server
    }
    
    // MARK: - coreml configuration (legacy)
    
    static let sampleRate: Double = 22050
    static let hopLength = 255  //exactly 43,844 / 172 ≈ 254.88 samples per frame
    static let frameSize = 2048  //not used by coreml model but kept for compatibility
    static let onsetThreshold: Float = 0.6  //raised to be more selective
    static let frameThreshold: Float = 0.7  //raised to be more selective  
    static let minimumNoteDuration: Double = 0.1  //require longer notes (100ms)
    static let maximumFrequency: Float = 2093.0  //c7
    static let minimumFrequency: Float = 27.5  //a0
    
    //audio chunk processing
    static let chunkSampleCount = 43844  //~2 seconds at 22.05khz
    static let targetSampleRate: Double = 22050
}
