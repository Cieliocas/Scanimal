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
=======
    /// Mensagem de boas-vindas usada ao abrir e ao reiniciar o chat.
    private static let greeting = ChatMessage(
        role: .assistant,
        text: "Olá, eu sou o Scanimal AI. Você teve contato com algum animal peçonhento ou precisa de identificação?",
        imageData: nil
    )

    /// Histórico da conversa (começa com a mensagem inicial do assistente).
    var messages: [ChatMessage] = [greeting]
>>>>>>> 186f9bd006926be493cdb3e8eca0ddd338bda514

    // Texto digitado no campo de entrada
    var draft: String = ""

    // Indica se o assistente está “digitando”
    var isLoading: Bool = false

<<<<<<< HEAD
    // Dados da imagem anexada (PhotosPicker) para envio junto com a mensagem
    var attachedImage: Data? = nil
=======
    // MARK: - Gerenciamento da janela de contexto

    /// Tamanho máximo da janela de contexto enviada à IA (curta e focada no socorro).
    private let maxContextMessages = 8

    /// Quantas mensagens iniciais são SEMPRE preservadas (info crítica do acidente).
    private let pinnedInitialCount = 2

    /// Mensagens com índice abaixo deste valor são ignoradas pela IA (definido por "Limpar Contexto").
    private var contextStartIndex = 0

    // 🔧 Inicializa o modelo configurando as instruções do sistema para respostas curtas e diretas.
    private let model = GenerativeModel(
        name: "gemini-2.5-flash",
        apiKey: "AQ.Ab8RN6I7jrW7P5NH2Lxnc-Ve1-Zbuwo7duvbwOU-XXbtUPXrrQ",
        systemInstruction: ModelContent(role: "system", parts: [
            .text("""
            Você é a 'Scanimal AI', um assistente de emergência focado em primeiros socorros para acidentes com animais peçonhentos.
            Siga estas REGRAS ESTRITAS em todas as respostas:
            1. Seja EXTREMAMENTE DIRETO, curto e sucinto. Nunca escreva textos longos ou parágrafos extensos.
            2. Forneça apenas as recomendações básicas e imediatas de primeiros socorros em formato de lista/tópicos curtos.
            3. Se uma foto for enviada, identifique o animal em apenas uma linha curta no início da resposta.
            4. Não dê explicações científicas, biológicas ou acadêmicas detalhadas. Foque apenas no que o usuário deve e não deve fazer imediatamente.
            5. Finalize sempre com um lembrete curto em uma única linha para buscar atendimento médico ou ligar para o 192 (SAMU).
            """)
        ])
    )
>>>>>>> 186f9bd006926be493cdb3e8eca0ddd338bda514

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

<<<<<<< HEAD
        // Simula resposta do assistente
        isLoading = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000) // ~0.8s
            let replyText = "Entendi sua mensagem. Para casos de emergência, chame o 192. Posso analisar uma foto do animal se você anexar."
            messages.append(ChatMessage(text: replyText, isUser: false))
            isLoading = false
=======
        Task { await deliver() }
    }

    // MARK: - Controles de gerenciamento do chat

    /// Encerra a sessão atual, limpa o histórico e inicia uma conversa em branco.
    func restartChat() {
        messages = [Self.greeting]
        draft = ""
        attachedImage = nil
        isLoading = false
        contextStartIndex = 0
    }

    /// Apaga o contexto da IA mantendo a tela: a IA passa a analisar apenas as
    /// mensagens enviadas a partir deste ponto. O histórico visível é preservado.
    func clearContext() {
        contextStartIndex = messages.count
        messages.append(ChatMessage(
            role: .system,
            text: "Contexto da IA limpo. As próximas mensagens serão analisadas isoladamente.",
            imageData: nil
        ))
    }

    // MARK: - Envio

    private func deliver() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Monta a janela de contexto (histórico curto e focado) para enviar à IA.
            let contents = makeContextContents()
            let response = try await model.generateContent(contents)

            // Processa a resposta retornada pelo servidor do Google
            guard let reply = response.text else {
                messages.append(ChatMessage(
                    role: .assistant,
                    text: "Desculpe, recebi uma resposta vazia. Por favor, tente novamente.",
                    imageData: nil
                ))
                return
            }

            // Adiciona a resposta formatada da IA no histórico
            messages.append(ChatMessage(role: .assistant, text: reply, imageData: nil))

        } catch {
            // Tratamento de erro exibido na bolha de chat
            messages.append(ChatMessage(
                role: .assistant,
                text: "Não consegui obter uma resposta do Gemini. Verifique sua conexão.\nErro: \(error.localizedDescription)",
                imageData: nil
            ))
>>>>>>> 186f9bd006926be493cdb3e8eca0ddd338bda514
        }
    }

    /// Constrói o histórico enviado ao Gemini respeitando a janela de contexto:
    /// fixa as primeiras mensagens críticas do acidente e mantém as mais recentes,
    /// descartando as do meio para manter o contexto curto e focado no socorro.
    private func makeContextContents() -> [ModelContent] {
        // 1. Considera só o que está dentro do contexto ativo e ignora avisos do app (.system).
        var visible = messages
            .enumerated()
            .filter { $0.offset >= contextStartIndex && $0.element.role != .system }
            .map { $0.element }

        // 2. O histórico da IA precisa começar por uma mensagem do usuário.
        while let first = visible.first, first.role != .user {
            visible.removeFirst()
        }

        // 3. Janela de contexto: fixa as iniciais (info crítica) + mantém as recentes.
        let windowed: [ChatMessage]
        if visible.count > maxContextMessages {
            let pinned = Array(visible.prefix(pinnedInitialCount))
            let recent = Array(visible.suffix(maxContextMessages - pinnedInitialCount))
            windowed = pinned + recent
        } else {
            windowed = visible
        }

        // 4. Converte para o formato do SDK. A imagem só vai na última mensagem (a atual),
        //    evitando reenviar mídias antigas e inflar o contexto.
        return windowed.enumerated().compactMap { index, msg in
            var parts: [ModelContent.Part] = []
            if index == windowed.count - 1, let data = msg.imageData {
                parts.append(.jpeg(data))
            }
            if !msg.text.isEmpty {
                parts.append(.text(msg.text))
            }
            guard !parts.isEmpty else { return nil }
            return ModelContent(role: msg.role == .user ? "user" : "model", parts: parts)
        }
    }
}

