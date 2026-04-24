import Foundation
import NZCore

actor DiscordRemoteClientImpl: DiscordRemoteClient {
    private let webhookUrl: URL

    init(webhookUrl: String) {
        guard let url = URL(string: webhookUrl) else {
            fatalError("Invalid Discord Webhook URL")
        }
        self.webhookUrl = url
    }

    // TODO: IFを変更し、他のアプリでも利用可能にする
    func sendNotification(content: String, imageData: Data?) async throws {
        var request = URLRequest(url: webhookUrl)
        request.httpMethod = "POST"
        
        if let imageData = imageData {
            // 画像がある場合は multipart/form-data で送信
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            // payload_json
            let payload = DiscordWebhookRequest(content: content)
            let jsonData = try await MainActor.run {
                try JSONEncoder().encode(payload)
            }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"payload_json\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(jsonData)
            body.append("\r\n".data(using: .utf8)!)
            
            // file
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[0]\"; filename=\"report.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
        } else {
            // 画像がない場合は通常の JSON で送信
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let payload = DiscordWebhookRequest(content: content)
            request.httpBody = try await MainActor.run {
                try JSONEncoder().encode(payload)
            }
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "DiscordRemoteClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Discord API Error"])
        }
    }
}
