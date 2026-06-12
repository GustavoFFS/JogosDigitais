# 🌀 Lost & Loopy

> *"Um jogo de plataforma onde você nunca controla o personagem da mesma forma duas vezes."*

---

## 📖 Sobre o Jogo

**Lost & Loopy** é um jogo de plataforma 2D com elementos de puzzle leve, desenvolvido em **Godot** para a **web**. O diferencial central é um sistema de **Movimento Variável**: a cada fase, o comportamento do personagem muda, forçando o jogador a se adaptar constantemente.

A história acompanha **Rob** e **Bog**, dois amigos que precisam seguir **Loopy** — que, após tomar um chá misterioso, saiu andando de forma desorientada sem destino claro. O jogador controla Rob e Bog na tentativa de alcançar Loopy antes que ele desapareça de cada área.

---

## 🎮 Mecânicas Principais

- **Movimento Variável por Fase** — velocidade, pulo, aderência e precisão mudam a cada nível.
- **Troca de Personagens** — alterne entre Rob e Bog conforme a situação exige.
- **Sem inimigos tradicionais** — o desafio vem do ambiente e do próprio controle.
- **Sistema de Caçada Visual** — Loopy aparece no fim de cada fase como objetivo visual.
- **Elementos Interativos do Ambiente** — interações dinâmicas que enriquecem o gameplay:
  - **Zonas de Gravidade Invertida**: Campos de força roxos pulsantes com setas indicativas flutuantes que informam a direção e a força da alteração gravitacional antes mesmo de entrar neles.
  - **Blocos Empurráveis**: Obstáculos pesados identificados com o nome "BOG" que apenas o personagem Bog consegue mover.
  - **Molas (Jump Pads) e Aceleradores (Speed Pads)**: Itens de impulso rápido espalhados pelas fases.
  - **Botões e Portões**: Mecanismos de puzzle simples que exigem ativação por peso para liberar passagens.

### Personagens

| Personagem | Perfil | Habilidade |
|---|---|---|
| **Rob** | Ágil, impulsivo, veloz | Dash frontal |
| **Bog** | Robusto, calmo, estável | Dash no chão / queda com impacto no ar |
| **Loopy** | Desorientado, distraído | NPC — objetivo narrativo |

---

## 🕹️ Controles

| Ação | Tecla |
|---|---|
| Mover | `A` / `D` ou `←` / `→` |
| Pular | `Espaço` |
| Trocar personagem | `TAB` |
| Usar habilidade | `Z` |

---

## 🗺️ Estrutura das Fases

Cada fase representa um trecho da cidade e introduz um novo desafio de movimentação:

1. **Início** — Aprendizado dos controles básicos (movimento padrão)
2. **Meio** — Introdução de obstáculos (buracos, plataformas, timing)
3. **Final** — Visualização de Loopy; chegada ao objetivo

O jogador **perde** ao cair em buracos ou áreas de perigo, retornando ao último checkpoint. O jogador **vence** ao alcançar onde Loopy foi visto por último.

---

## 🏙️ Cenário e Estilo Visual

- Cidade moderna estilizada com ruas, calçadas, praças e estruturas urbanas simples
- Estilo **cartunesco minimalista**, colorido e de fácil leitura
- Paleta vibrante: **verde, azul e amarelo**
- Tom **leve, descontraído e levemente humorístico**

---

## 🔧 Tecnologia

| Item | Detalhe |
|---|---|
| **Engine** | Godot |
| **Plataforma** | Web (navegador) |
| **Gênero** | Plataforma 2D + Puzzle Leve |
| **Público-alvo** | Jogadores casuais, 10–25 anos |
| **Classificação** | Livre |

---

## 👥 Equipe

- 3 Programadores
- 2 Designers

---

## ⚠️ Riscos Mapeados

| Risco | Solução |
|---|---|
| Mecânica de movimento mal calibrada | Testes e ajustes constantes |
| Falta de feedback ao jogador | Sons e respostas visuais claras |
| Escopo muito grande | Manter o jogo simples e focado |

---

## 🚀 Como Rodar Localmente

```bash
# Clone o repositório
git clone https://github.com/GutavoFFS/JogosDigitais.git

# Abra o projeto no Godot
# Arquivo > Abrir Projeto > selecione a pasta clonada
```

> Requer **Godot 4.x** instalado. Download em [godotengine.org](https://godotengine.org).

---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos.