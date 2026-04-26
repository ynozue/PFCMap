import Foundation
import SwiftData
import NZData

actor ImageRepositoryImpl {
    private let dataOperator: DataOperator
    private let urlSession: URLSession
    
    init(modelContainer: ModelContainer, urlSession: URLSession = .shared) {
        self.dataOperator = DataOperator(modelContainer: modelContainer)
        self.urlSession = urlSession
    }
}

extension ImageRepositoryImpl: ImageRepository {
    func fetchImage(url: URL) async throws -> Data {
        let urlString = url.absoluteString
        
        // 1. キャッシュを検索
        if let cached = try await dataOperator.fetchImageCache(url: urlString) {
            return cached.data
        }
        
        // 2. リモートから取得
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // 3. キャッシュに保存
        try await dataOperator.saveImageCache(url: urlString, data: data)
        
        return data
    }
}

private extension DataOperator {
    func fetchImageCache(url: String) async throws -> ImageCache? {
        let descriptor = FetchDescriptor<ImageCacheEntity>(
            predicate: #Predicate<ImageCacheEntity> { $0.url == url }
        )
        let entities = try modelContext.fetch(descriptor)
        return entities.first?.toDomain()
    }
    
    func saveImageCache(url: String, data: Data) async throws {
        try await withTransaction {
            let entity = ImageCacheEntity(url: url, data: data)
            try insert(entity)
        }
    }
}
