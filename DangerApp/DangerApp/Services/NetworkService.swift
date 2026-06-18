//
//  NetworkService.swift
//  DangerApp / Vitalis
//
//  Camada de rede simples (URLSession) para conversar com a API construída
//  no IBM Node-RED. O app NÃO chama o Gemini diretamente: todas as chamadas
//  de dados e IA passam por estes endpoints REST do Node-RED.
//

import Foundation

// MARK: - Payloads do Chat (texto + imagem em Base64)

struct ChatRequest: Encodable {
    let message: String
    let imageBase64: String?
}

struct ChatResponse: Decodable {
    let reply: String
}

// MARK: - Serviço

enum NetworkError: Error {
    case invalidURL
    case badStatus(Int)
}

final class NetworkService {

    static let shared = NetworkService()

    /// 🔧 PONTO DE INJEÇÃO: troque pela URL base do seu fluxo no IBM Node-RED.
    /// Ex.: "https://seu-app.mybluemix.net" ou "http://SEU-IP:1880".
    var baseURL = URL(string: "https://SEU-NODE-RED.exemplo.com")!

    private let session: URLSession = .shared

    private init() {}

    // MARK: GET genérico

    /// Faz um GET e decodifica a resposta JSON em `T`.
    /// - Parameter path: caminho do endpoint no Node-RED (ex.: "/hospitais").
    func get<T: Decodable>(_ path: String) async throws -> T {
        let request = URLRequest(url: baseURL.appendingPathComponent(path))
        return try await perform(request)
    }

    // MARK: POST genérico

    /// Faz um POST com corpo JSON e decodifica a resposta em `T`.
    /// - Parameters:
    ///   - path: caminho do endpoint no Node-RED (ex.: "/chat").
    ///   - body: payload `Encodable` enviado no corpo da requisição.
    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    // MARK: Chamadas específicas do Vitalis

    /// Envia uma mensagem (texto + imagem opcional em Base64) para o fluxo de IA.
    /// O Node-RED é quem encaminha o conteúdo para o Gemini e devolve a resposta.
    func sendChatMessage(text: String, imageBase64: String?) async throws -> String {
        // 🔧 PONTO DE INJEÇÃO: ajuste o path "/chat" para o endpoint real do Node-RED.
        let response: ChatResponse = try await post(
            "/chat",
            body: ChatRequest(message: text, imageBase64: imageBase64)
        )
        return response.reply
    }

    // MARK: Núcleo

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NetworkError.badStatus(http.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
