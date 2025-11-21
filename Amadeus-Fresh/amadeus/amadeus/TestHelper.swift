import Foundation

struct TestHelper {
    static func listBundledAudioFiles() -> [String] {
        var files: [String] = []
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                for item in items {
                    if item.hasSuffix(".mp3") || item.hasSuffix(".wav") || item.hasSuffix(".m4a") {
                        files.append(item)
                        print("Found audio file: \(item)")
                    }
                }
            } catch {
                print("Error listing files: \(error)")
            }
        }
        return files
    }
}