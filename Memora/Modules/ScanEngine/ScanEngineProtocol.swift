import Foundation

// ─── Tipos de suporte ao ScanEngine ──────────────────────────────────────────

/// Progresso em tempo real emitido pelo ScanEngine durante uma varredura.
struct ScanProgress: Sendable {
    /// Percentual de conclusão entre 0.0 e 1.0
    let percentComplete: Double

    /// Número total de arquivos encontrados até o momento
    let filesScanned: Int

    /// Tempo estimado até a conclusão, em segundos. Nil quando ainda não é possível estimar.
    let estimatedTimeRemaining: TimeInterval?

    /// Caminho do diretório sendo processado neste momento
    let currentDirectory: String
}

/// Modo de varredura solicitado pelo usuário ou pelo sistema
enum ScanMode: Sendable {
    /// Percorre o disco inteiro do zero
    case full

    /// Atualiza apenas o que mudou desde o último scan (via FSEvents)
    case incremental
}

// ─── Erros do ScanEngine ─────────────────────────────────────────────────────

enum ScanError: Error, Sendable {
    /// Permissão de Full Disk Access não concedida pelo usuário
    case permissionDenied

    /// Scan cancelado pelo usuário antes de concluir
    case cancelled

    /// Falha ao acessar o volume especificado
    case volumeUnavailable(path: String)
}

// ─── Protocolo principal ──────────────────────────────────────────────────────

/// Contrato público do módulo ScanEngine.
///
/// Responsabilidades:
/// - Percorrer o sistema de arquivos e coletar metadados
/// - Persistir o índice em SQLite para scans subsequentes rápidos
/// - Manter o índice atualizado em background via FSEvents
///
/// Fluxo de dados: FileSystem + Spotlight → ScanEngine → [FileMetadata] → ClassificationEngine
protocol ScanEngineProtocol: AnyObject, Sendable {

    /// Stream de progresso emitido durante uma varredura ativa.
    /// Cada valor representa o estado atual do scan naquele momento.
    var progress: AsyncStream<ScanProgress> { get }

    /// Executa uma varredura no modo especificado.
    ///
    /// - Parameter mode: `.full` para varredura completa, `.incremental` para atualização rápida
    /// - Returns: Lista de metadados de todos os arquivos encontrados/atualizados
    /// - Throws: `ScanError` em caso de falha de permissão, cancelamento ou volume indisponível
    func scan(mode: ScanMode) async throws -> [FileMetadata]

    /// Interrompe a varredura em andamento. O stream de progresso é encerrado.
    func cancel()

    /// Inicia o monitoramento de mudanças em background via FSEvents.
    /// Deve ser chamado após o primeiro scan completo.
    func startBackgroundMonitoring()

    /// Para o monitoramento em background.
    func stopBackgroundMonitoring()
}
