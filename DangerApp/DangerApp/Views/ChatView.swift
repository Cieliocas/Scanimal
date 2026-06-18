//
//  ChatView.swift
//  DangerApp / Vitalis
//
//  TELA 3 — Chat com IA. Bolhas de mensagem (estilo iMessage), banner de
//  emergência e campo de texto com anexo de imagem via PhotosPicker.
//

import SwiftUI
import PhotosUI

struct ChatView: View {

    @State private var viewModel = ChatViewModel()
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            VitalisHeader {
                Button {
                    // 🔧 Discar emergência (192).
                } label: {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(Theme.onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }

            emergencyBanner
            messagesList
            inputBar
        }
        .background(Theme.background)
        // Carrega a imagem escolhida e a converte em Data (para Base64 no envio).
        .onChange(of: pickerItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    viewModel.attachedImage = data
                }
                pickerItem = nil
            }
        }
    }

    // MARK: Banner de emergência

    private var emergencyBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.octagon.fill")
            Text("Em caso de picada grave, chame o 192 imediatamente")
                .font(.system(size: 15, weight: .semibold))
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Theme.danger)
    }

    // MARK: Lista de mensagens

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    Text("HOJE 14:32")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.onSurfaceVariant.opacity(0.6))
                        .padding(.vertical, 4)

                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }

                    // Card "Módulo de Visão" (abre o seletor de imagem = scanner).
                    ScannerCard(pickerItem: $pickerItem)
                        .padding(.top, 4)

                    if viewModel.isLoading {
                        TypingIndicator()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages) { _, _ in
                if let last = viewModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    // MARK: Campo de entrada (anexo + texto + enviar)

    private var inputBar: some View {
        VStack(spacing: 8) {
            // Prévia da imagem anexada antes do envio.
            if let data = viewModel.attachedImage, let image = UIImage(data: data) {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        Button {
                            viewModel.attachedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white, .black.opacity(0.5))
                        }
                        .offset(x: 6, y: -6)
                    }
                    Spacer()
                }
            }

            HStack(spacing: 12) {
                Button {
                    // 🔧 TODO: integrar câmera (UIImagePickerController/AVFoundation).
                } label: {
                    Image(systemName: "camera.fill").font(.system(size: 22))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Theme.primary)

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Image(systemName: "photo.on.rectangle").font(.system(size: 22))
                }
                .foregroundStyle(Theme.primary)

                HStack(spacing: 6) {
                    TextField("Mensagem", text: $viewModel.draft, axis: .vertical)
                        .lineLimit(1...4)
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.onSurface)

                    Button(action: viewModel.send) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.onPrimary)
                            .frame(width: 30, height: 30)
                            .background(viewModel.canSend ? Theme.primary : Theme.onSurfaceVariant.opacity(0.4),
                                        in: Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canSend)
                }
                .padding(.leading, 14)
                .padding(.trailing, 5)
                .padding(.vertical, 5)
                .background(Theme.field, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(.bar)
    }
}

// MARK: - Bolha de mensagem

private struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 50) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                if let data = message.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.system(size: 17))
                        .foregroundStyle(isUser ? Theme.onPrimary : Theme.onSurface)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            isUser ? AnyShapeStyle(Theme.primary) : AnyShapeStyle(Theme.field),
                            in: UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    topLeading: 18,
                                    bottomLeading: isUser ? 18 : 4,
                                    bottomTrailing: isUser ? 4 : 18,
                                    topTrailing: 18
                                ),
                                style: .continuous
                            )
                        )
                }
            }

            if !isUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Card "Módulo de Visão" / Scanner

private struct ScannerCard: View {
    @Binding var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(colors: [Theme.field, Theme.onSurfaceVariant.opacity(0.25)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 150)

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Abrir Scanner", systemImage: "camera.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.onPrimary)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Theme.primary, in: Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                }
            }

            Text("MÓDULO DE VISÃO VITALIS V2.0")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(Theme.onSurfaceVariant)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Theme.card)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.outlineVariant.opacity(0.5), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Indicador "digitando"

private struct TypingIndicator: View {
    @State private var bounce = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Theme.onSurfaceVariant)
                    .frame(width: 7, height: 7)
                    .offset(y: bounce ? -3 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(index) * 0.15),
                               value: bounce)
            }
        }
        .opacity(0.6)
        .onAppear { bounce = true }
    }
}

#Preview {
    ChatView()
}
