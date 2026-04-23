import Foundation

actor DiscordRemoteClientDummy: DiscordRemoteClient {
    func sendNotification(content: String, imageData: Data?) async throws {
        print("--- Discord Notification Dummy ---")
        print("Content: \(content)")
        if let data = imageData {
            print("Attachment: Image data (\(data.count) bytes)")
        } else {
            print("Attachment: None")
        }
        print("----------------------------------")
    }
}
