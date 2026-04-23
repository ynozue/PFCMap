import Foundation

struct DiscordWebhookRequest: Encodable {
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case content
    }
}
