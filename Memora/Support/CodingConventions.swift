// ============================================================================
// CONVENÇÕES DE CÓDIGO — StoreLens / Memora
// ============================================================================
//
// Este arquivo serve como referência de convenções adotadas no projeto.
// Não contém código executável.
//
// ─── NOMENCLATURA ────────────────────────────────────────────────────────────
//
// Tipos (structs, classes, enums, protocols):  PascalCase
//   ex: FileMetadata, ScanEngineProtocol, RiskLevel
//
// Variáveis, propriedades, funções:            camelCase
//   ex: totalSize, formattedImpact, startScan()
//
// Constantes globais e casos de enum:          camelCase
//   ex: RiskLevel.veryLow, ScanMode.full
//
// Arquivos de protocolo:                       NomeDoModulo + "Protocol.swift"
//   ex: ScanEngineProtocol.swift
//
// Arquivos de implementação:                   NomeDoModulo + "Impl.swift" ou nome direto
//   ex: ScanEngineImpl.swift, FileSystemWalker.swift
//
// ─── ESTRUTURA DE ARQUIVO ────────────────────────────────────────────────────
//
// Ordem das seções em um arquivo Swift:
//   1. import statements
//   2. Tipos de suporte locais (structs/enums auxiliares)
//   3. Protocolo ou tipo principal
//   4. Extensions do tipo principal (agrupadas por conformance)
//
// Separadores de seção: usar linha de comentário com traços
//   // ─── Nome da Seção ───────────...
//
// ─── CONCORRÊNCIA (Swift Concurrency) ────────────────────────────────────────
//
// - Todo código que acessa o disco deve ser marcado como `async`
// - Módulos que emitem eventos contínuos devem usar `AsyncStream`
// - Tipos compartilhados entre tasks devem conformar a `Sendable`
// - Preferir `actor` sobre `class` para estado mutável compartilhado
// - Nunca usar DispatchQueue diretamente — usar `Task`, `TaskGroup` e `async/await`
//
// ─── TRATAMENTO DE ERROS ─────────────────────────────────────────────────────
//
// - Cada módulo define seu próprio enum de erro (ex: ScanError, CleanupError)
// - Erros devem ser `Sendable` e ter casos descritivos
// - Nunca usar `try!` ou `try?` em código de produção sem justificativa comentada
// - Erros de UI são tratados na camada de ViewModel, não nos módulos
//
// ─── DOCUMENTAÇÃO INLINE ─────────────────────────────────────────────────────
//
// - Toda declaração pública (protocolo, struct, função pública) deve ter um
//   comentário de documentação com `///`
// - Parâmetros e retornos documentados com `- Parameter` e `- Returns`
// - Comentários internos (não-documentação) usam `//` comum
// - Proibido: comentários que apenas repetem o que o código já diz
//   ERRADO: // incrementa o contador
//   CERTO:  // offset de 1 porque o índice do Spotlight começa em zero
//
// ─── SEGURANÇA — REGRAS INVIOLÁVEIS ──────────────────────────────────────────
//
// 1. NUNCA usar FileManager.removeItem() — sempre FileManager.trashItem()
// 2. NUNCA processar arquivos com isSIPProtected == true
// 3. NUNCA ler o conteúdo de arquivos do usuário — apenas metadados
// 4. NUNCA enviar metadados para servidores externos sem consentimento explícito
// 5. SEMPRE registrar operações de limpeza no HistoryStore antes de retornar
//
// ─── FLUXO DE DADOS (referência) ─────────────────────────────────────────────
//
//   FileSystem + Spotlight Index
//          ↓
//      ScanEngine → IndexStore (SQLite)
//          ↓
//   ClassificationEngine → [CategoryResult]
//          ↓
//   RecommendationEngine → [CleanupRecommendation]
//          ↓
//       Dashboard UI → Confirmação do Usuário
//          ↓
//     CleanupExecutor → Trash (FileManager.trashItem)
//          ↓
//      HistoryStore (SQLite + history.json)
//
// ============================================================================
