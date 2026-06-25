//
//  NetworkService.swift
//  DangerApp / Vitalis
//
//  Responsável pelas requisições HTTP da aplicação conectando ao Node-RED.
//

import Foundation

/// Erros possíveis durante a requisição de rede
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A URL gerada é inválida."
        case .noData:
            return "Nenhum dado foi retornado pelo servidor."
        case .decodingError:
            return "Falha ao decodificar a resposta do servidor (JSON inválido)."
        case .serverError(let statusCode):
            return "O servidor respondeu com um erro. Status: \(statusCode)"
        }
    }
}

final class NetworkService {
    
    /// Instância compartilhada (Singleton)
    static let shared = NetworkService()
    
    /// IP do seu computador na rede local (visto na imagem do Node-RED)
    private let baseURL = "http://192.168.128.33:1880"
    
    private init() {}
    
    /// Realiza uma requisição GET assíncrona genérica
    /// - Parameter path: O caminho da rota (ex: "/getameacas?lat=...&lon=...")
    /// - Returns: O objeto decodificado mapeado a partir do JSON recebido
    func get<T: Decodable>(_ path: String) async throws -> T {
        
        // 1. Monta e valida a URL completa
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        // 2. Executa a chamada de rede usando a API nativa assíncrona do iOS
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Valida a resposta HTTP do servidor
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        // Verifica se o status está na faixa de sucesso (200 a 299)
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // 4. Converte o JSON recebido no modelo do Swift esperado
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Erro crítico de decodificação JSON no NetworkService: \(error)")
            throw NetworkError.decodingError
        }
    }
}
