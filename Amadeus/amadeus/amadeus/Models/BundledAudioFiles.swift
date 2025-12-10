import Foundation

// utility for managing bundled audio files
struct BundledAudioFiles {
    // copy bundled audio files to documents directory
    static func copyBundledFilesToDocuments() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // list your audio file names here
        let audioFiles = ["song1.mp3", "song2.mp3", "song3.mp3"] // UPDATE WITH YOUR ACTUAL FILE NAMES
        
        for fileName in audioFiles {
            if let bundleURL = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), 
                                                withExtension: "mp3") {
                let destinationURL = documentsURL.appendingPathComponent(fileName)
                
                // copy if doesn't exist
                if !fileManager.fileExists(atPath: destinationURL.path) {
                    try? fileManager.copyItem(at: bundleURL, to: destinationURL)
                    print("Copied \(fileName) to Documents")
                }
            }
        }
    }
    
    // get urls of bundled audio files
    static func getBundledFileURLs() -> [URL] {
        // return urls of files directly from bundle
        var urls: [URL] = []
        
        // add your file names here
        let audioFiles = ["song1", "song2", "song3"] // WITHOUT extension
        
        for fileName in audioFiles {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                urls.append(url)
            }
        }
        
        return urls
    }
}