# 📸🐍 Scanimal

> **Fotografe. Identifique. Aja rápido.**

**Scanimal** é um aplicativo iOS desenvolvido durante o **HackaTruck MakerSpace 2026** na **Universidade Federal do Piauí (UFPI)** com o objetivo de auxiliar vítimas de acidentes envolvendo animais peçonhentos.

Utilizando Inteligência Artificial, geolocalização e informações de primeiros socorros, o aplicativo fornece suporte rápido para identificação de espécies, localização de atendimento médico e acesso a informações confiáveis em situações de emergência.

O projeto foi concebido para ser simples, acessível e imediato, eliminando etapas de cadastro e autenticação para garantir que o usuário tenha acesso aos recursos essenciais quando mais precisar.

---

## 🚨 O Problema

O Brasil registra milhares de acidentes com animais peçonhentos todos os anos, incluindo serpentes, escorpiões, aranhas, lagartas e himenópteros.

Durante uma emergência, é comum que a vítima:

* Não consiga identificar o animal responsável pelo acidente;
* Desconheça os procedimentos corretos de primeiros socorros;
* Tenha dificuldade para localizar rapidamente uma unidade de saúde próxima;
* Receba informações incorretas ou desencontradas na internet;
* Perca tempo valioso procurando ajuda.

Em acidentes desse tipo, a rapidez e a precisão das informações podem fazer toda a diferença.

---

## 💡 Nossa Solução

O **Scanimal** centraliza recursos essenciais em uma única plataforma móvel:

* 📸 Identificação assistida por Inteligência Artificial através de imagens;
* 📍 Localização de hospitais e unidades de atendimento próximas;
* 🗺️ Visualização de áreas com maior incidência de ocorrências;
* 📚 Guia de primeiros socorros acessível diretamente no aplicativo;
* 🔍 Catálogo de espécies peçonhentas com informações relevantes;
* 🤖 Assistente virtual para orientação inicial em situações emergenciais.

---

## ✨ Principais Funcionalidades

### 🗺️ Mapa de Risco

Visualização geográfica de áreas com registros de acidentes envolvendo animais peçonhentos.

**Recursos:**

* Geolocalização automática do usuário;
* Marcadores interativos no mapa;
* Visualização de áreas de maior incidência;
* Atualização dinâmica conforme a localização.

---

### 🔍 Pesquisa e Socorro

Ferramenta de busca rápida para obtenção de informações críticas.

**Permite:**

* Encontrar hospitais próximos;
* Consultar espécies peçonhentas;
* Obter informações relevantes para atendimento;
* Acessar conteúdo de forma simples e intuitiva.

---

### 🤖 Assistente Inteligente

Canal de suporte baseado em Inteligência Artificial.

**Funcionalidades:**

* Envio de mensagens de texto;
* Upload de imagens do animal;
* Identificação preliminar da espécie;
* Orientações básicas de primeiros socorros;
* Auxílio na coleta de informações para atendimento médico.

> ⚠️ O aplicativo não substitui avaliação médica profissional. Em caso de acidente, procure atendimento especializado imediatamente.

---

### 📚 Guia de Primeiros Socorros

Conteúdo acessível mesmo em situações de baixa conectividade.

**Inclui:**

* Procedimentos recomendados;
* Cuidados que devem ser evitados;
* Informações sobre transporte da vítima;
* Orientações para busca de atendimento.

---

### ⚙️ Configurações

Área destinada às preferências e informações do aplicativo.

**Disponível:**

* Modo Claro e Escuro;
* Informações da versão;
* Manual do usuário;
* Estrutura preparada para futuras expansões.

---

## 📱 Estrutura do Aplicativo

O Scanimal utiliza uma navegação baseada em `TabView`, organizada em quatro módulos principais:

```text
📍 Mapa
🔍 Pesquisa
🤖 Assistente IA
⚙️ Configurações
```

Essa organização prioriza rapidez de acesso e simplicidade de uso durante situações críticas.

---

## 🏗️ Arquitetura da Solução

```text
┌─────────────────┐
│   Scanimal iOS  │
│ Swift + SwiftUI │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Node-RED     │
│ API Gateway     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Gemini API    │
│ Inteligência IA │
└─────────────────┘
```

### Fluxo de Comunicação

1. O usuário envia texto ou imagem pelo aplicativo;
2. O Scanimal encaminha os dados para o Node-RED;
3. O Node-RED processa e encaminha a requisição para a IA;
4. A resposta é tratada e retornada ao aplicativo;
5. O usuário recebe orientações e informações relevantes.

---

## 🛠️ Tecnologias Utilizadas

### Mobile

* Swift
* SwiftUI
* MapKit
* CoreLocation
* PhotosUI

### Backend e Integração

* Node-RED
* REST APIs
* Gemini API

### Recursos Utilizados

* Geolocalização em tempo real
* Processamento de imagens
* Inteligência Artificial Generativa
* Busca contextual
* Interface nativa iOS

---

## 🎨 Design e Experiência do Usuário

O Scanimal foi desenvolvido seguindo as **Human Interface Guidelines (HIG)** da Apple.

### Princípios adotados

* Simplicidade em momentos críticos;
* Baixa curva de aprendizado;
* Acessibilidade;
* Alto contraste para leitura rápida;
* Compatibilidade total com Dark Mode;
* Informações essenciais em destaque.

### Identidade Visual

A interface utiliza uma estética inspirada em aplicações de saúde e segurança:

* Tons de verde e azul associados à confiança e orientação;
* Destaques em vermelho e laranja para alertas;
* Componentes nativos do sistema;
* Layout limpo e objetivo.

---

## 👨‍💻 Equipe

### Desenvolvimento

* Franciélio Castro
* Gustavo Farias
* Gustavo Rubens
* Rafael Nogueira

### Instituição

Universidade Federal do Piauí (UFPI)

### Programa

HackaTruck MakerSpace 2026

---

## 🚀 Possíveis Evoluções

* Histórico de ocorrências;
* Compartilhamento de localização em tempo real;
* Funcionamento offline expandido;
* Integração com serviços de emergência;
* Base nacional de ocorrências;
* Notificações de áreas de risco;
* Suporte multilíngue;
* Dashboard analítico para órgãos de saúde.

---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos, educacionais e demonstrativos durante o HackaTruck MakerSpace 2026.

---

## ⚠️ Aviso Importante

O Scanimal tem caráter informativo e de apoio à tomada de decisão em situações emergenciais.

As informações fornecidas pelo aplicativo não substituem diagnóstico médico, orientação profissional ou atendimento especializado.

Em caso de acidente com animal peçonhento, procure imediatamente uma unidade de saúde.
