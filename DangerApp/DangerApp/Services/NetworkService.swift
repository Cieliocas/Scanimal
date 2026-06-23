import Foundation

enum NetworkError: Error {
    case invalidURL
    case badStatus(Int)
}

final class NetworkService {
    static let shared = NetworkService()
    
    // URL do seu fluxo no IBM Node-RED
    var baseURL = URL(string: "http://192.168.128.33:1880")!
    private let session: URLSession = .shared
    private init() {}

    func get<T: Decodable>(_ path: String) async throws -> T {
        let request = URLRequest(url: baseURL.appendingPathComponent(path))
        return try await perform(request)
    }

    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    func sendChatMessage(text: String, imageBase64: String?) async throws -> String {
        let response: ChatResponse = try await post("/chat", body: ChatRequest(message: text, imageBase64: imageBase64))
        return response.reply
    }
    
    func fetchHospitais() async throws -> [Hospital] {
        return try await get("/hospitais")
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NetworkError.badStatus(http.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
