import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let aac = UTType(filenameExtension: "aac") ?? .audio
            let types: [UTType] = [
                .mp3,
                .wav,
                .mpeg4Audio, // M4A
                aac    // AAC
            ]
            
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
            picker.delegate = context.coordinator
            picker.allowsMultipleSelection = false
            return picker
        }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing security scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security scoped resource")
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                // Copy file to temporary location to avoid sandboxing issues
                let tempDir = FileManager.default.temporaryDirectory
                let tempURL = tempDir.appendingPathComponent(url.lastPathComponent)
                
                // Remove existing temp file if it exists
                try? FileManager.default.removeItem(at: tempURL)
                
                // Copy to temp location
                try FileManager.default.copyItem(at: url, to: tempURL)
                
                print("✅ File copied to temp location: \(tempURL.lastPathComponent)")
                
                // Use the temp URL
                parent.onPick(tempURL)
                
            } catch {
                print("❌ Failed to copy file: \(error.localizedDescription)")
                // Fall back to original URL
                parent.onPick(url)
            }
        }
    }
}
