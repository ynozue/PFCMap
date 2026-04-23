import Foundation

protocol DiscordRemoteClient: Sendable {
    func sendNotification(content: String, imageData: Data?) async throws
}
