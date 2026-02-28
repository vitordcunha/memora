# StoreLens — Fases de Desenvolvimento Detalhadas

**Produto:** StoreLens — macOS Storage Intelligence App  
**Plataforma:** macOS 13+  
**Linguagem:** Swift 5.9  
**Versão do Documento:** 1.0

---

## Visão Geral das Fases

| Fase   | Versão | Foco Principal                   | Prazo Estimado |
| ------ | ------ | -------------------------------- | -------------- |
| Fase 0 | —      | Fundação do Projeto              | Pré-MVP        |
| Fase 1 | 1.0    | MVP — Core do Produto            | Q3 2025        |
| Fase 2 | 1.5    | Expansão de Funcionalidades      | Q4 2025        |
| Fase 3 | 2.0    | Assistente com IA Conversacional | Q1 2026        |
| Fase 4 | 2.5    | Monitoramento Contínuo e Alertas | Q2 2026        |
| Fase 5 | 3.0    | Inteligência On-Device (Core ML) | Q3 2026        |

---

## Fase 0 — Fundação do Projeto

**Objetivo:** Preparar toda a infraestrutura técnica, estrutura do projeto e definições de arquitetura antes de iniciar o desenvolvimento de funcionalidades.

### 0.1 — Configuração do Projeto

- Criar o projeto Xcode como aplicação macOS nativa com target mínimo macOS 13 (Ventura)
- Definir a estrutura de pastas e módulos do projeto, seguindo a separação por camadas (ScanEngine, ClassificationEngine, RecommendationEngine, CleanupExecutor, UI)
- Configurar o sistema de gerenciamento de dependências (Swift Package Manager) e adicionar as bibliotecas externas necessárias: GRDB.swift para SQLite e Sentry SDK (opcional)
- Configurar esquemas de build para Debug, Release e Notarized
- Definir e versionar o arquivo de configuração do produto (bundle ID, versão, target)

### 0.2 — Arquitetura e Contratos entre Módulos

- Definir os protocolos e interfaces públicas de cada módulo (ScanEngine, ClassificationEngine, RecommendationEngine, CleanupExecutor, HistoryStore)
- Documentar os modelos de dados principais: FileMetadata, CategoryResult, CleanupRecommendation, CleanupOperation, HistoryEntry
- Definir o fluxo de dados entre os módulos, validando a sequência: FileSystem → ScanEngine → IndexStore → ClassificationEngine → RecommendationEngine → UI → CleanupExecutor → HistoryStore
- Estabelecer convenções de nomenclatura, estilo de código e documentação inline

### 0.3 — Infraestrutura de Banco de Dados Local

- Definir o schema do banco SQLite: tabelas de arquivos indexados, categorias, histórico de operações e preferências
- Planejar a estratégia de migração de schema para versões futuras do app
- Definir o diretório de dados locais do app em `~/Library/Application Support/StoreLens/`
- Definir o arquivo de log de operações em `~/.storelens/history.json`

### 0.4 — Permissões e Distribuição

- Configurar as entitlements necessárias no projeto: Full Disk Access, Automation (Finder), Notifications
- Planejar o fluxo de onboarding para solicitação de permissões ao usuário
- Configurar o processo de assinatura e notarização da Apple para distribuição direta (fora da App Store)
- Definir a estratégia de atualização automática do app para versões futuras

### 0.5 — Design System e Fundação de UI

- Definir a paleta de cores, tipografia e espaçamentos do design system do app
- Garantir suporte a Dark Mode e Light Mode desde o início
- Alinhar o design com as Human Interface Guidelines da Apple para macOS
- Criar os componentes reutilizáveis de UI que serão usados em todas as telas (botões, badges de risco, cards de categoria)
- Planejar a adaptação para macOS 26 (Liquid Glass) como camada visual futura

---

## Fase 1 — MVP v1.0

**Objetivo:** Entregar o produto funcional com as cinco funcionalidades core: Scanner, Classificação, Dashboard, Limpeza Guiada e Histórico.

---

### 1.1 — Módulo de Onboarding

**Descrição:** Primeira experiência do usuário ao abrir o app. Explica o propósito do StoreLens, solicita as permissões necessárias e prepara o ambiente para o primeiro scan.

**Tasks:**

- **1.1.1** Criar a tela de boas-vindas com a proposta de valor do app (o que o StoreLens faz e o que ele não faz)
- **1.1.2** Criar a tela de solicitação de Full Disk Access, com instruções visuais passo a passo para o usuário habilitar nas Preferências do Sistema
- **1.1.3** Implementar a detecção de status de permissão: verificar se a permissão já foi concedida e pular o onboarding em lançamentos subsequentes
- **1.1.4** Criar a tela de solicitação de permissão de Automação (Finder) para movimentação de arquivos para a Lixeira
- **1.1.5** Implementar a lógica de bloqueio do app caso as permissões obrigatórias não sejam concedidas, com mensagem orientativa
- **1.1.6** Exibir resumo final do onboarding antes de iniciar o primeiro scan automático

---

### 1.2 — ScanEngine — Motor de Varredura

**Descrição:** O coração do app. Responsável por percorrer o sistema de arquivos do Mac, coletar metadados de cada arquivo e alimentar o banco de dados local.

**Tasks:**

- **1.2.1 — FileSystemWalker:** Implementar o percurso recursivo de diretórios a partir do volume principal. O walker deve percorrer todos os diretórios acessíveis pelo usuário, ignorando diretórios protegidos pelo SIP (System Integrity Protection) sem permissão explícita
- **1.2.2 — Paralelismo com TaskGroup:** Configurar a varredura paralela usando Swift Concurrency (TaskGroup) para que múltiplos diretórios sejam percorridos simultaneamente, atingindo o objetivo de menos de 30 segundos para volumes de até 1 TB em Apple Silicon M1+
- **1.2.3 — Coleta de Metadados:** Para cada arquivo encontrado, coletar: nome, caminho completo, tamanho em bytes, tipo MIME, data de criação, data de modificação e data do último acesso
- **1.2.4 — SpotlightIndexer:** Integrar a consulta ao índice do Spotlight (MDQuery) para acelerar a busca por tipo de arquivo e atributos específicos, evitando percorrer fisicamente o disco sempre que possível
- **1.2.5 — IndexStore (SQLite):** Persistir todos os metadados coletados no banco de dados local SQLite via GRDB.swift. O índice local permite que scans subsequentes sejam até 10x mais rápidos (menos de 3 segundos), atualizando apenas o que mudou
- **1.2.6 — FSEventsMonitor:** Assinar o stream de eventos do sistema de arquivos (FSEvents) para detectar alterações em arquivos em tempo real, permitindo a manutenção incremental do índice em background sem necessidade de rescan completo
- **1.2.7 — Indicador de Progresso:** Emitir eventos de progresso em tempo real para a UI durante o scan, exibindo percentual de conclusão e estimativa de tempo restante
- **1.2.8 — Limitação de Recursos:** Garantir que o scan em background não ultrapasse 30% de uso de um núcleo de eficiência, preservando a performance do Mac para o trabalho do usuário
- **1.2.9 — Testes de Performance:** Validar o tempo de scan em volumes de diferentes tamanhos (100 GB, 500 GB, 1 TB) tanto em Apple Silicon quanto em Intel. Ajustar o número de workers paralelos conforme o hardware detectado

---

### 1.3 — ClassificationEngine — Motor de Classificação

**Descrição:** Recebe os metadados do ScanEngine e organiza cada arquivo em uma das categorias de conteúdo definidas no PRD, atribuindo também um score de limpeza.

**Tasks:**

- **1.3.1 — RuleSet — Definição de Regras:** Implementar o conjunto de regras de classificação baseadas em: caminho do arquivo (ex: `~/Library/Caches`), extensão de arquivo, tipo MIME e padrões de nome (ex: `node_modules`, `.DS_Store`, `DerivedData`). As dez categorias são:
  - Caches de Sistema (`~/Library/Caches`, `/tmp`)
  - Caches de Aplicativos (Xcode DerivedData, npm cache, pip cache)
  - Logs (`~/Library/Logs`, `/var/log`)
  - Downloads Antigos (arquivos em `~/Downloads` com mais de 90 dias sem acesso)
  - Duplicatas (arquivos com hash idêntico — implementado na Fase 2 de forma avançada, mas identificação básica no MVP)
  - Apps e Resíduos (arquivos de suporte de apps desinstalados)
  - Arquivos Grandes Inativos (arquivos acima de 100 MB sem acesso há mais de 6 meses)
  - Backups iOS (`~/Library/Application Support/MobileSync`)
  - Builds de Desenvolvimento (`node_modules`, `.gradle`, `.build`, `DerivedData`)
  - Arquivos de Lixo (`.DS_Store`, `Thumbs.db`, `__MACOSX`, `.Spotlight-V100`)

- **1.3.2 — ScoreCalculator — Cálculo do Score de Limpeza:** Para cada arquivo ou grupo de arquivos classificado, calcular um score de 0 a 100 composto por três eixos:
  - Segurança de Remoção (0–40 pontos): baseada no tipo, origem e se o arquivo é regenerável pelo sistema ou aplicativo
  - Impacto em Espaço (0–40 pontos): tamanho absoluto e percentual em relação ao volume total
  - Relevância Temporal (0–20 pontos): tempo decorrido desde o último acesso ou modificação

- **1.3.3 — Nível de Risco:** Classificar cada categoria em um dos três níveis de risco (Verde, Amarelo, Vermelho) conforme definido nas regras do PRD, para exibição no Dashboard

- **1.3.4 — Persistência dos Resultados:** Armazenar os resultados da classificação no SQLite para consulta rápida pela UI sem necessidade de reclassificar a cada abertura do app

- **1.3.5 — Testes de Cobertura de Regras:** Validar as regras de classificação com conjuntos de dados representativos dos três perfis de usuário (desenvolvedor, criativo, usuário comum), garantindo que os itens sejam corretamente categorizados

---

### 1.4 — Dashboard Visual

**Descrição:** Tela principal do app, exibida logo após a conclusão do scan. É o ponto central de navegação e tomada de decisão do usuário.

**Tasks:**

- **1.4.1 — Gráfico de Distribuição por Categoria:** Implementar o gráfico de disco (treemap ou donut chart) usando Swift Charts, mostrando visualmente o espaço ocupado por cada categoria identificada. O gráfico deve ser interativo, permitindo clicar em uma categoria para navegar ao detalhe

- **1.4.2 — Resumo Numérico:** Exibir no topo da tela os três números mais relevantes: espaço total do volume, espaço atualmente usado e espaço potencialmente recuperável com base nas recomendações

- **1.4.3 — Lista de Categorias por Impacto:** Listar todas as categorias identificadas, ordenadas do maior para o menor impacto em espaço. Cada item da lista deve exibir: nome da categoria, badge com o total de espaço, indicador de nível de risco (Verde/Amarelo/Vermelho) e número de arquivos

- **1.4.4 — Botões de Scan:** Implementar dois modos de scan acionáveis pelo usuário:
  - "Scan Rápido": executa apenas a atualização incremental via FSEvents (resultado em menos de 3 segundos)
  - "Scan Completo": executa a varredura total do disco novamente

- **1.4.5 — Barra de Status no Menu Bar (opcional):** Exibir o ícone do StoreLens na menu bar do macOS com o percentual de uso atual do disco. Esta funcionalidade pode ser ativada ou desativada nas preferências do app

- **1.4.6 — Estado de Carregamento:** Enquanto o scan está em andamento, exibir um estado de loading progressivo que vai revelando as categorias conforme os dados chegam, sem bloquear a interface

- **1.4.7 — Estado Vazio:** Exibir uma tela de estado vazio adequada quando nenhum scan foi realizado ainda ou quando o resultado do scan não encontrou nada relevante para recomendar

---

### 1.5 — RecommendationEngine — Motor de Recomendações

**Descrição:** Transforma os resultados classificados em recomendações acionáveis, com contexto textual e orientação clara para cada tipo de conteúdo encontrado.

**Tasks:**

- **1.5.1 — Estrutura de Recomendação:** Implementar a estrutura de dados de uma recomendação com os campos: Título, Contexto (explicação em linguagem natural), Impacto Estimado (tamanho em GB), Nível de Risco (Verde/Amarelo/Vermelho), Ação Primária ("Limpar agora") e Ação Secundária ("Ver arquivos")

- **1.5.2 — Textos de Contexto por Categoria:** Escrever e implementar os textos de contexto para cada uma das dez categorias, adaptados ao nível técnico do usuário. Os textos devem explicar o que o arquivo é, por que pode ser removido com segurança e o que acontece após a remoção (ex: "O Xcode armazena builds intermediários em DerivedData. É seguro remover — serão regenerados na próxima build.")

- **1.5.3 — Tela de Detalhe de Categoria:** Criar a tela de lista detalhada de uma categoria específica, exibindo todos os arquivos pertencentes àquela categoria com nome, caminho, tamanho individual e data do último acesso. A tela deve permitir seleção individual ou em lote

- **1.5.4 — Tela de Detalhe de Arquivo:** Criar a tela de detalhe de um arquivo individual, exibindo todos os metadados coletados, o contexto de remoção e, quando disponível, um preview do conteúdo do arquivo

- **1.5.5 — Ordenação e Filtros:** Na tela de detalhe de categoria, implementar opções de ordenação (por tamanho, por data de acesso, por nome) e filtros básicos

---

### 1.6 — CleanupExecutor — Módulo de Limpeza Guiada

**Descrição:** Executa as ações de remoção aprovadas pelo usuário, sempre de forma não-destrutiva (via Lixeira do macOS), com confirmação obrigatória antes de qualquer ação.

**Tasks:**

- **1.6.1 — Tela de Confirmação:** Criar a tela de confirmação que é exibida obrigatoriamente antes de qualquer remoção. A tela deve listar todos os arquivos que serão movidos para a Lixeira com o tamanho individual de cada um, o total de espaço que será liberado e o checkbox obrigatório "Entendo que esta ação não pode ser desfeita pelo sistema" que deve ser marcado pelo usuário antes de prosseguir

- **1.6.2 — Execução de Remoção via Lixeira:** Implementar a movimentação de arquivos para a Lixeira do macOS usando `FileManager.trashItem()`. Nunca utilizar remoção permanente no MVP. Nunca deletar arquivos fora de `~/Library`, `~/Downloads` e `~/Desktop` sem confirmação extra

- **1.6.3 — Regras de Segurança:** Implementar as seguintes restrições invioláveis:
  - Nunca remover arquivos do sistema ou de aplicativos em `/Applications`
  - Nunca percorrer ou modificar diretórios protegidos pelo SIP
  - Sempre mover para Lixeira — nunca usar remoção direta
  - Exigir confirmação adicional para arquivos fora dos diretórios padrão de limpeza

- **1.6.4 — Tela de Resultado:** Exibir a tela de resultado após a limpeza com: total de espaço liberado, número de arquivos movidos para a Lixeira e lembrete de que os arquivos ainda estão na Lixeira e podem ser recuperados até que o usuário esvazie a Lixeira manualmente

- **1.6.5 — Emissão de Progresso:** Durante a movimentação de arquivos (especialmente em lotes grandes), emitir eventos de progresso para a UI via AsyncStream para exibir barra de progresso

- **1.6.6 — Atualização do Dashboard:** Após a conclusão da limpeza, atualizar automaticamente o Dashboard com os novos valores de espaço utilizado e recuperável

---

### 1.7 — HistoryStore — Histórico de Operações

**Descrição:** Registro persistente de todas as operações de limpeza realizadas pelo usuário desde a instalação do app.

**Tasks:**

- **1.7.1 — Persistência de Operações:** Após cada limpeza, registrar no banco SQLite e no arquivo `~/.storelens/history.json` as seguintes informações: data e hora da operação, categoria afetada, lista de arquivos movidos para a Lixeira, tamanho total liberado e status da operação (sucesso/falha parcial)

- **1.7.2 — Tela de Histórico:** Criar a tela de histórico com uma linha do tempo visual das operações passadas, exibindo data, categoria e espaço liberado em cada entrada

- **1.7.3 — Total Acumulado:** Exibir na tela de histórico o total acumulado de espaço liberado desde a instalação do app

- **1.7.4 — Detalhamento de Operação:** Permitir que o usuário expanda qualquer entrada do histórico para ver a lista completa de arquivos afetados naquela operação

---

### 1.8 — Módulo de Preferências

**Descrição:** Painel de configurações do app com todas as opções de personalização disponíveis no MVP.

**Tasks:**

- **1.8.1 — Ícone na Menu Bar:** Opção de ativar ou desativar o ícone do StoreLens na menu bar do macOS

- **1.8.2 — Alerta de Disco:** Configuração do threshold de alerta de disco cheio (ex: notificar quando restar menos de 10 GB livres)

- **1.8.3 — Diretórios Excluídos:** Interface para que o usuário adicione diretórios que devem ser excluídos da varredura, garantindo que arquivos específicos nunca sejam sugeridos para remoção

- **1.8.4 — Frequência de Scan Automático:** Opção para configurar a frequência do scan automático em background: diário, semanal ou apenas manual

- **1.8.5 — Telemetria:** Opção de telemetria anônima com opt-in explícito, desativada por padrão. Ao ativar, o usuário consente com o envio de dados de uso agregados e anonimizados para melhoria do produto

---

### 1.9 — Qualidade, Testes e Preparação para Lançamento

**Tasks:**

- **1.9.1 — Testes de Integração:** Testar o fluxo completo end-to-end: scan → classificação → dashboard → recomendação → confirmação → limpeza → histórico
- **1.9.2 — Testes em Hardware Diverso:** Validar performance e comportamento em Apple Silicon (M1, M2, M3) e Intel (Core i5, Core i7), garantindo que os limites de tempo de scan sejam atendidos em ambas as arquiteturas
- **1.9.3 — Testes de Stress:** Testar o scanner em volumes com 500k+ arquivos e verificar uso de memória e CPU
- **1.9.4 — Testes de Segurança:** Verificar que nenhuma das regras de segurança é violável via edge cases (ex: symlinks apontando para diretórios do sistema, permissões corrompidas)
- **1.9.5 — Configuração de Crash Reporting:** Configurar o Sentry SDK de forma opt-in para coleta de crash reports em produção
- **1.9.6 — Notarização e Assinatura:** Passar o app pelo processo de assinatura de código e notarização da Apple para distribuição direta
- **1.9.7 — Página de Download:** Preparar a landing page e o instalador para distribuição direta (fora da App Store)

---

## Fase 2 — v1.5: Expansão de Funcionalidades

**Objetivo:** Adicionar a detecção avançada de duplicatas, suporte a volumes externos e completar o módulo de menu bar.

**Prazo Estimado:** Q4 2025

---

### 2.1 — Detecção Avançada de Duplicatas

**Descrição:** Identificação precisa de arquivos com conteúdo idêntico em todo o volume, usando hash criptográfico para comparação.

**Tasks:**

- **2.1.1 — DuplicateFinder com SHA-256:** Implementar o processo de hashing usando CryptoKit (SHA-256) para identificar arquivos com conteúdo bit-a-bit idêntico. O processo deve ser feito em background sem impactar a UI
- **2.1.2 — Estratégia de Hashing em Dois Estágios:** Primeiro comparar arquivos pelo tamanho (fast path) e somente então calcular o hash SHA-256 dos candidatos com tamanho idêntico, reduzindo drasticamente o número de operações de leitura de disco
- **2.1.3 — Agrupamento de Duplicatas:** Agrupar os arquivos duplicados identificados, apresentando ao usuário o grupo com a sugestão de qual cópia manter (a mais recente, a com nome mais descritivo, ou a escolha do usuário)
- **2.1.4 — Interface de Revisão de Duplicatas:** Criar uma tela dedicada para revisão de grupos de duplicatas, permitindo que o usuário selecione qual cópia manter e marque as demais para remoção
- **2.1.5 — Regras de Segurança para Duplicatas:** Garantir que pelo menos uma cópia de cada grupo seja sempre preservada. O usuário não pode marcar todas as cópias para remoção sem confirmação especial

---

### 2.2 — Suporte a Volumes Externos

**Descrição:** Extender o scanner para suportar discos externos, pendrives e outros volumes montados.

**Tasks:**

- **2.2.1 — Detecção de Volumes Montados:** Monitorar o sistema para detectar automaticamente quando novos volumes são montados (discos externos, pendrives, Time Machine drives)
- **2.2.2 — Seleção de Volume:** Criar a interface para o usuário selecionar qual volume deseja varrer (volume principal + qualquer volume externo montado)
- **2.2.3 — Scanner Multi-Volume:** Adaptar o ScanEngine para suportar varredura em múltiplos volumes simultaneamente ou sequencialmente
- **2.2.4 — IndexStore por Volume:** Manter um índice SQLite separado por volume, permitindo scans incrementais independentes para cada dispositivo de armazenamento
- **2.2.5 — Tratamento de Desconexão:** Lidar com a desconexão de um volume externo durante o scan ou durante uma operação de limpeza, sem crashar o app e mantendo a integridade do banco de dados

---

### 2.3 — Menu Bar Completo

**Descrição:** Transformar o ícone na menu bar em um mini-painel funcional com acesso rápido às principais informações e ações.

**Tasks:**

- **2.3.1 — Popover de Status:** Ao clicar no ícone da menu bar, exibir um popover compacto com: percentual de disco usado, top 3 categorias com maior impacto e botão de "Scan Rápido"
- **2.3.2 — Notificações de Alerta:** Implementar as notificações nativas do macOS para alertar o usuário quando o disco atingir o threshold configurado nas preferências
- **2.3.3 — Atualização em Tempo Real:** O ícone da menu bar deve atualizar seu conteúdo em segundo plano via FSEventsMonitor, sempre refletindo o estado atual do disco
- **2.3.4 — Acesso Direto ao App:** Adicionar no menu da menu bar o acesso direto ao dashboard principal, ao histórico e às preferências

---

## Fase 3 — v2.0: Assistente IA Conversacional

**Objetivo:** Integrar um assistente inteligente via API (Claude) que fornece análise contextual personalizada do armazenamento do usuário, com capacidade de diálogo em linguagem natural.

**Prazo Estimado:** Q1 2026

---

### 3.1 — Integração com API de IA

**Tasks:**

- **3.1.1 — Configuração da API:** Configurar a integração com a API do Claude (Anthropic), incluindo gerenciamento seguro da chave de API e tratamento de erros de rede e timeout
- **3.1.2 — Preparação de Contexto:** Definir quais dados do StoreLens serão enviados ao modelo como contexto (categorias encontradas, tamanhos, scores de limpeza, perfil de uso inferido) garantindo que nenhum conteúdo de arquivo seja enviado — apenas metadados agregados e anonimizados
- **3.1.3 — Prompt Engineering:** Desenvolver e refinar os prompts do sistema que definem o comportamento do assistente: foco em clareza, segurança e orientação não-destrutiva
- **3.1.4 — Streaming de Respostas:** Implementar o recebimento de respostas em modo streaming para que o texto do assistente apareça progressivamente na interface, sem esperar o carregamento completo

---

### 3.2 — Interface do Assistente

**Tasks:**

- **3.2.1 — Tela de Chat:** Criar a tela de conversa com o assistente IA, com histórico da conversa, campo de entrada de texto e exibição de respostas em markdown
- **3.2.2 — Sugestões de Perguntas:** Exibir sugestões de perguntas contextuais baseadas no estado atual do disco do usuário (ex: "O que está ocupando mais espaço no meu Mac?", "Posso limpar o DerivedData do Xcode com segurança?")
- **3.2.3 — Ações Executáveis via Chat:** Permitir que o assistente sugira ações de limpeza que o usuário possa aceitar diretamente no chat, acionando o fluxo de confirmação padrão do CleanupExecutor
- **3.2.4 — Modo Offline:** Quando não houver conexão com a internet, exibir mensagem clara informando que o assistente requer conexão e oferecer as funcionalidades offline do app normalmente

---

### 3.3 — Privacidade e Controle do Usuário

**Tasks:**

- **3.3.1 — Consentimento Explícito:** Implementar o fluxo de opt-in para o uso do assistente IA, explicando claramente quais dados são enviados à API e que nenhum arquivo é lido ou enviado
- **3.3.2 — Opção de Desativar:** Permitir que o usuário desative completamente o assistente IA nas preferências, fazendo o app operar 100% offline como nas versões anteriores
- **3.3.3 — Revisão de Dados Enviados:** Disponibilizar nas preferências uma descrição detalhada de exatamente quais informações são compartilhadas com a API quando o assistente é usado

---

## Fase 4 — v2.5: Monitoramento Contínuo e Alertas Preditivos

**Objetivo:** Transformar o StoreLens de uma ferramenta reativa em um agente proativo de saúde do armazenamento, com monitoramento contínuo, alertas inteligentes e relatórios de tendência.

**Prazo Estimado:** Q2 2026

---

### 4.1 — Agente de Monitoramento em Background

**Tasks:**

- **4.1.1 — Login Item:** Configurar o agente do StoreLens como Login Item do macOS, permitindo que o monitoramento seja iniciado automaticamente ao ligar o computador (opt-in nas preferências)
- **4.1.2 — Monitoramento de Crescimento:** Acompanhar o crescimento do uso de disco ao longo do tempo por categoria, registrando snapshots periódicos no banco de dados
- **4.1.3 — Detecção de Anomalias:** Identificar quando uma categoria cresceu de forma anormal em um curto período (ex: DerivedData dobrou de tamanho em 24 horas após uma nova build do Xcode) e notificar o usuário

---

### 4.2 — Alertas Preditivos

**Tasks:**

- **4.2.1 — Modelo de Projeção:** Com base no histórico de crescimento, calcular uma projeção simples de quantos dias até o disco atingir o limite configurado, exibindo alertas antecipados
- **4.2.2 — Alertas Contextuais:** Emitir notificações nativas do macOS com sugestões específicas baseadas no contexto atual (ex: "Seu disco atingirá o limite crítico em 7 dias. DerivedData cresceu 12 GB esta semana — limpar agora?")
- **4.2.3 — Configuração de Alertas:** Permitir ao usuário configurar diferentes níveis de alerta: aviso preventivo, alerta de atenção e alerta crítico, cada um com um threshold configurável

---

### 4.3 — Relatórios de Tendência

**Tasks:**

- **4.3.1 — Tela de Tendências:** Criar uma nova tela com gráficos de linha (Swift Charts) mostrando a evolução do uso de disco ao longo do tempo, por categoria e total
- **4.3.2 — Relatório Semanal:** Implementar um relatório semanal automático (opcional, opt-in) exibindo as categorias que mais cresceram na semana, o espaço total recuperado e as recomendações da semana
- **4.3.3 — Exportação de Relatório:** Permitir que o usuário exporte o relatório de tendências como PDF ou CSV para registro próprio

---

## Fase 5 — v3.0: Inteligência On-Device (Core ML)

**Objetivo:** Migrar a camada de inteligência do app para um modelo on-device usando Core ML, eliminando a dependência de conexão com internet e garantindo privacidade total.

**Prazo Estimado:** Q3 2026

---

### 5.1 — Modelo On-Device com Core ML

**Tasks:**

- **5.1.1 — Definição do Modelo:** Especificar o tipo de modelo mais adequado para a tarefa de classificação e recomendação de limpeza, considerando as limitações de tamanho e performance de modelos on-device em macOS
- **5.1.2 — Dataset de Treinamento:** Construir e curar o dataset de treinamento com exemplos anonimizados de padrões de armazenamento e as classificações/recomendações corretas esperadas
- **5.1.3 — Treinamento e Avaliação:** Treinar o modelo, avaliar métricas de qualidade (precisão das classificações, qualidade das recomendações) e comparar com a performance da solução baseada em API
- **5.1.4 — Conversão para Core ML:** Converter o modelo treinado para o formato `.mlmodel` compatível com Core ML e integrá-lo ao bundle do app
- **5.1.5 — Otimização para Apple Silicon:** Otimizar o modelo para execução acelerada na Neural Engine dos chips Apple Silicon (M1, M2, M3+), garantindo latência mínima nas classificações

---

### 5.2 — Substituição do Assistente por Modelo Local

**Tasks:**

- **5.2.1 — Análise Contextual Offline:** Migrar a análise contextual do assistente para o modelo on-device, permitindo respostas e sugestões inteligentes sem qualquer chamada de rede
- **5.2.2 — Sugestões Proativas:** Implementar a geração de sugestões proativas pelo modelo local, acionadas automaticamente após cada scan ou quando o FSEventsMonitor detectar mudanças significativas
- **5.2.3 — Modo Híbrido (opcional):** Manter a opção de usar a API do Claude para usuários que preferem as capacidades de linguagem natural mais avançadas de um modelo grande, com o modelo local como opção padrão offline

---

### 5.3 — Atualização de Modelo Over-the-Air

**Tasks:**

- **5.3.1 — Infraestrutura de Atualização:** Criar mecanismo para baixar e instalar versões atualizadas do modelo Core ML sem necessidade de atualizar o app completo
- **5.3.2 — Validação de Modelo:** Antes de ativar um novo modelo baixado, validar a integridade e assinatura do arquivo para garantir que não foi adulterado
- **5.3.3 — Rollback de Modelo:** Manter a versão anterior do modelo disponível como fallback caso o novo modelo apresente problemas

---

## Considerações Transversais

As seguintes práticas se aplicam a todas as fases do desenvolvimento:

### Segurança e Privacidade (em todas as fases)

- Nenhum conteúdo de arquivo é lido — apenas metadados
- Toda remoção passa obrigatoriamente pela Lixeira do macOS
- Confirmação explícita do usuário antes de qualquer ação destrutiva
- Logs completos de todas as operações em `~/.storelens/history.json`

### Performance (em todas as fases)

- Monitoramento contínuo dos tempos de scan após cada alteração no ScanEngine
- Testes regressivos de performance a cada release
- Limitar uso de CPU em background a 30% de um núcleo de eficiência

### Compatibilidade (em todas as fases)

- Manter suporte a macOS 13 (Ventura) como versão mínima
- Testar em hardware Intel além do Apple Silicon
- Garantir que o app funcione corretamente em Light Mode e Dark Mode

### Qualidade (em todas as fases)

- Meta de crash-free sessions acima de 99,5%
- Monitoramento via Sentry (opt-in)
- Testes manuais de regressão antes de cada release
