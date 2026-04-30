import Foundation

struct DiscordWebhookRequest: Sendable {
    let content: String
}

extension DiscordWebhookRequest: Encodable {
    enum CodingKeys: String, CodingKey {
        case content
    }
}
