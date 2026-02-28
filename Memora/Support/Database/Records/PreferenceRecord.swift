import Foundation
import GRDB

/// Registro da tabela `preferences` no SQLite.
/// Armazena as configurações do app como pares chave–valor.
///
/// Usar as constantes em `PreferenceKey` para garantir consistência nas chaves.
struct PreferenceRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "preferences"

    var key: String
    var value: String
    var updatedAt: Double

    init(key: PreferenceKey, value: String) {
        self.key       = key.rawValue
        self.value     = value
        self.updatedAt = Date.now.timeIntervalSince1970
    }
}

// ─── Chaves de preferência ────────────────────────────────────────────────────

/// Chaves válidas para a tabela de preferências.
enum PreferenceKey: String {
    /// Exibe ou oculta o ícone na menu bar. Valor: "true" | "false"
    case menuBarEnabled         = "menu_bar_enabled"

    /// Threshold de alerta de disco em bytes. Valor: inteiro como string.
    case diskAlertThreshold     = "disk_alert_threshold"

    /// Frequência do scan automático. Valor: "daily" | "weekly" | "manual"
    case scanFrequency          = "scan_frequency"

    /// Diretórios excluídos da varredura, separados por newline.
    case excludedPaths          = "excluded_paths"

    /// Telemetria anônima opt-in. Valor: "true" | "false"
    case telemetryEnabled       = "telemetry_enabled"

    /// Data do último scan completo. Valor: Unix timestamp como string.
    case lastFullScanDate       = "last_full_scan_date"
}
