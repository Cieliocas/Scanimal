//
//  ChatModels.swift
//  DangerApp / Scanimal
//
//  Payloads de rede e o modelo de mensagem da conversa com a IA.
//

import Foundation

// MARK: - Payloads da Rede (Chat)

struct ChatRequest: Encodable {
    let message: String
    let imageBase64: String?
}

struct ChatResponse: Decodable {
    let reply: String
}

// MARK: - Interface do Chat

/// Mensagem da conversa com a IA.
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let text: String
    var imageData: Data? = nil

    enum Role {
        case user
        case assistant
        /// Aviso interno do app (ex.: "contexto limpo"). Exibido na tela,
        /// mas nunca enviado como contexto para a IA.
        case system
    }
}
