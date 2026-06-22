
import Foundation
import Observation
import GoogleGenerativeAI // Importa o SDK oficial do Gemini

@Observable
final class ChatViewModel {

    /// Histórico da conversa (começa com a mensagem inicial do assistente).
    var messages: [ChatMessage] = [
        ChatMessage(role: .assistant,
                    text: "Olá, eu sou o Vitalis AI. Você teve contato com algum animal peçonhento ou precisa de identificação?",
                    imageData: nil)
    ]

    /// Texto sendo digitado no campo de mensagem.
    var draft: String = ""

    /// Imagem anexada (enviada diretamente como Data para o Gemini).
    var attachedImage: Data?

    /// Indica que aguardamos resposta do Gemini.
    var isLoading: Bool = false

    // 🔧 Inicializa o modelo configurando as instruções do sistema para respostas curtas e diretas.
    private let model = GenerativeModel(
        name: "gemini-2.5-flash",
        apiKey: "AQ.Ab8RN6I7jrW7P5NH2Lxnc-Ve1-Zbuwo7duvbwOU-XXbtUPXrrQ",
        systemInstruction: ModelContent(role: "system", parts: [
            .text("""
            Você é a 'Vitalis AI', um assistente de emergência focado em primeiros socorros para acidentes com animais peçonhentos.
            Siga estas REGRAS ESTRITAS em todas as respostas:
            1. Seja EXTREMAMENTE DIRETO, curto e sucinto. Nunca escreva textos longos ou parágrafos extensos.
            2. Forneça apenas as recomendações básicas e imediatas de primeiros socorros em formato de lista/tópicos curtos.
            3. Se uma foto for enviada, identifique o animal em apenas uma linha curta no início da resposta.
            4. Não dê explicações científicas, biológicas ou acadêmicas detalhadas. Foque apenas no que o usuário deve e não deve fazer imediatamente.
            5. Finalize sempre com um lembrete curto em uma única linha para buscar atendimento médico ou ligar para o 192 (SAMU).
            """)
        ])
    )

    /// Há conteúdo suficiente para enviar?
    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || attachedImage != nil
    }

    /// Prepara as mídias e dispara o envio assíncrono para a API do Gemini.
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

        do {
            let response: GenerateContentResponse
            
            // Envio direto usando os parâmetros do SDK do Gemini
            if let imageData = image {
                let imagePart = ModelContent.Part.jpeg(imageData)
                
                if !text.isEmpty {
                    // Caso 1: Enviando Imagem E Texto juntos
                    response = try await model.generateContent(imagePart, text)
                } else {
                    // Caso 2: Enviando APENAS Imagem
                    response = try await model.generateContent(imagePart)
                }
            } else {
                // Caso 3: Enviando APENAS Texto
                response = try await model.generateContent(text)
            }
            
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
        }
    }
}
