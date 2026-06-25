//
//  ChatViewModel.swift
//  DangerApp / Vitalis
//
//  ViewModel do chat usado pela ChatView.
//

import Foundation
import Observation

@Observable
final class ChatViewModel {

    // Mensagens exibidas no chat
    var messages: [ChatMessage] = []

    // Texto digitado no campo de entrada
    var draft: String = ""

    // Indica se o assistente está “digitando”
    var isLoading: Bool = false

    // Dados da imagem anexada (PhotosPicker) para envio junto com a mensagem
    var attachedImage: Data? = nil

    // Pode enviar quando há texto não vazio ou uma imagem anexada
    var canSend: Bool {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty || attachedImage != nil
    }

    init() {
        // Mensagem inicial opcional do assistente
        messages.append(ChatMessage(text: "Olá! Sou a Vitalis. Como posso ajudar você hoje?", isUser: false))
    }

    // Envia a mensagem atual (texto e/ou imagem)
    func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || attachedImage != nil else { return }

        // Cria mensagem do usuário
        let userMessage = ChatMessage(text: trimmed, isUser: true, imageData: attachedImage)
        messages.append(userMessage)

        // Limpa rascunho e anexo
        draft = ""
        attachedImage = nil

        // Simula resposta do assistente
        isLoading = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000) // ~0.8s
            let replyText = "Entendi sua mensagem. Para casos de emergência, chame o 192. Posso analisar uma foto do animal se você anexar."
            messages.append(ChatMessage(text: replyText, isUser: false))
            isLoading = false
        }
    }
}

