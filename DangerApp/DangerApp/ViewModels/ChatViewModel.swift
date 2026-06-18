//
//  ChatViewModel.swift
//  DangerApp / Vitalis
//
//  Lógica da Tela 3 (Chat com IA). Monta o payload (texto + imagem em Base64)
//  e o envia via POST para o Node-RED, que encaminha para a IA.
//

import Foundation
import Observation

@Observable
final class ChatViewModel {

    /// Histórico da conversa (começa com a mensagem inicial do assistente).
    var messages: [ChatMessage] = [
        ChatMessage(role: .assistant,
                    text: "Olá, eu sou o Vitalis AI. Você teve contato com algum animal peçonhento ou precisa de identificação?")
    ]

    /// Texto sendo digitado no campo de mensagem.
    var draft: String = ""

    /// Imagem anexada (será convertida em Base64 no envio).
    var attachedImage: Data?

    /// Indica que aguardamos resposta do Node-RED (mostra os "três pontinhos").
    var isLoading: Bool = false

    private let network = NetworkService.shared

    /// Há conteúdo suficiente para enviar?
    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || attachedImage != nil
    }

    /// Monta o payload e dispara o envio para o Node-RED.
    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || attachedImage != nil else { return }

        let image = attachedImage
        messages.append(ChatMessage(role: .user, text: text, imageData: image))

        // Limpa o campo imediatamente para uma UX fluida.
        draft = ""
        attachedImage = nil

        Task { await deliver(text: text, image: image) }
    }

    private func deliver(text: String, image: Data?) async {
        isLoading = true
        defer { isLoading = false }

        // Imagem convertida para Base64 (parte do payload do POST).
        let imageBase64 = image?.base64EncodedString()

        do {
            let reply = try await network.sendChatMessage(text: text, imageBase64: imageBase64)
            messages.append(ChatMessage(role: .assistant, text: reply))
        } catch {
            // Sem backend configurado ainda: mostramos um aviso amigável.
            messages.append(ChatMessage(
                role: .assistant,
                text: "Não consegui me conectar ao servidor agora. Verifique a conexão e tente novamente. (Configure a URL do Node-RED em NetworkService.)"
            ))
        }
    }
}
