import Foundation

/// As dez categorias de conteúdo identificadas pelo ClassificationEngine.
enum FileCategory: String, CaseIterable, Identifiable, Sendable {
    case systemCaches       = "system_caches"
    case appCaches          = "app_caches"
    case logs               = "logs"
    case oldDownloads       = "old_downloads"
    case duplicates         = "duplicates"
    case appResiduals       = "app_residuals"
    case largeInactiveFiles = "large_inactive_files"
    case iosBackups         = "ios_backups"
    case devBuilds          = "dev_builds"
    case junkFiles          = "junk_files"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .systemCaches:       return "Caches de Sistema"
        case .appCaches:          return "Caches de Aplicativos"
        case .logs:               return "Logs"
        case .oldDownloads:       return "Downloads Antigos"
        case .duplicates:         return "Duplicatas"
        case .appResiduals:       return "Apps e Resíduos"
        case .largeInactiveFiles: return "Arquivos Grandes Inativos"
        case .iosBackups:         return "Backups iOS"
        case .devBuilds:          return "Builds de Desenvolvimento"
        case .junkFiles:          return "Arquivos de Lixo"
        }
    }

    var description: String {
        switch self {
        case .systemCaches:
            return "Caches gerados pelo sistema em ~/Library/Caches e /tmp. São regenerados automaticamente e seguros para remover."
        case .appCaches:
            return "Caches de aplicativos como Xcode DerivedData, npm cache e pip cache. Regenerados pelo próprio app."
        case .logs:
            return "Arquivos de log em ~/Library/Logs e /var/log. Logs antigos não têm valor operacional."
        case .oldDownloads:
            return "Arquivos em ~/Downloads sem acesso há mais de 90 dias."
        case .duplicates:
            return "Arquivos com conteúdo idêntico (hash SHA-256). Manter apenas uma cópia é suficiente."
        case .appResiduals:
            return "Arquivos de suporte de aplicativos que foram desinstalados. São resíduos órfãos sem dono."
        case .largeInactiveFiles:
            return "Arquivos acima de 100 MB sem acesso há mais de 6 meses. Revisar com cuidado antes de remover."
        case .iosBackups:
            return "Backups de iPhone e iPad em ~/Library/Application Support/MobileSync. Verificar datas antes de remover."
        case .devBuilds:
            return "Artefatos de build de desenvolvimento: node_modules, .gradle, DerivedData, .build. Regenerados pelos package managers."
        case .junkFiles:
            return "Arquivos sem utilidade: .DS_Store, Thumbs.db, __MACOSX, .Spotlight-V100. Sempre seguros para remover."
        }
    }

    /// Nível de risco padrão da categoria. Pode ser sobrescrito pelo ScoreCalculator por item.
    var defaultRiskLevel: RiskLevel {
        switch self {
        case .systemCaches, .appCaches, .logs, .appResiduals, .devBuilds:
            return .low
        case .oldDownloads, .duplicates, .iosBackups:
            return .medium
        case .largeInactiveFiles:
            return .high
        case .junkFiles:
            return .veryLow
        }
    }
}
