import Foundation
import AppKit
import UserNotifications

// ─── Tipos ────────────────────────────────────────────────────────────────────

/// Permissões que o StoreLens precisa para funcionar.
enum AppPermission: CaseIterable {
    /// Acesso Total ao Disco — obrigatório para o ScanEngine varrer ~/Library.
    /// Concedida manualmente pelo usuário em Preferências do Sistema.
    case fullDiskAccess

    /// Automação via Finder — necessária para FileManager.trashItem().
    /// Solicitada pelo sistema na primeira vez que o app tenta usar a Lixeira.
    case finderAutomation

    /// Notificações do sistema — para alertas de disco cheio e scans em background.
    /// Opcional — o app funciona sem ela.
    case userNotifications

    var displayName: String {
        switch self {
        case .fullDiskAccess:    return "Acesso Total ao Disco"
        case .finderAutomation:  return "Automação (Finder)"
        case .userNotifications: return "Notificações"
        }
    }

    var isRequired: Bool {
        switch self {
        case .fullDiskAccess:    return true
        case .finderAutomation:  return true
        case .userNotifications: return false
        }
    }

    /// Caminho nas Preferências do Sistema onde o usuário concede esta permissão.
    var systemPreferencesPath: String {
        switch self {
        case .fullDiskAccess:
            return "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        case .finderAutomation:
            return "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
        case .userNotifications:
            return "x-apple.systempreferences:com.apple.preference.notifications"
        }
    }
}

/// Status de uma permissão verificada em tempo de execução.
enum PermissionStatus {
    case granted
    case denied
    case notDetermined
}

// ─── PermissionManager ────────────────────────────────────────────────────────

/// Verifica e orienta o usuário a conceder as permissões necessárias ao StoreLens.
///
/// Full Disk Access e Automation não têm uma API de solicitação programática —
/// o usuário precisa ir manualmente às Preferências do Sistema. Este manager
/// detecta o status atual e abre a tela correta das Preferências quando necessário.
@MainActor
final class PermissionManager: ObservableObject {

    static let shared = PermissionManager()

    @Published private(set) var fullDiskAccessStatus: PermissionStatus = .notDetermined
    @Published private(set) var notificationStatus: PermissionStatus = .notDetermined

    // ─── Full Disk Access ─────────────────────────────────────────────────────

    /// Verifica se o app tem Full Disk Access tentando ler um arquivo protegido.
    /// Não há API pública — a única forma confiável é tentar o acesso.
    func checkFullDiskAccess() {
        // ~/Library/Application Support/com.apple.TCC/TCC.db é um arquivo
        // que só pode ser lido com Full Disk Access concedido.
        let probeURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/com.apple.TCC/TCC.db")

        let readable = FileManager.default.isReadableFile(atPath: probeURL.path)
        fullDiskAccessStatus = readable ? .granted : .denied
    }

    /// Abre a tela de Acesso Total ao Disco nas Preferências do Sistema.
    func requestFullDiskAccess() {
        openSystemPreferences(for: .fullDiskAccess)
    }

    // ─── User Notifications ───────────────────────────────────────────────────

    /// Verifica o status atual das notificações de forma assíncrona.
    func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            notificationStatus = .granted
        case .denied:
            notificationStatus = .denied
        case .notDetermined:
            notificationStatus = .notDetermined
        @unknown default:
            notificationStatus = .notDetermined
        }
    }

    /// Solicita autorização para notificações. Exibe o diálogo nativo do sistema.
    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            notificationStatus = granted ? .granted : .denied
        } catch {
            notificationStatus = .denied
        }
    }

    // ─── Verificação completa ─────────────────────────────────────────────────

    /// Verifica todas as permissões de uma vez. Chamar na inicialização do app
    /// e sempre que a app voltar para o foreground (pode ter sido concedida nas Prefs).
    func checkAll() async {
        checkFullDiskAccess()
        await checkNotificationStatus()
    }

    /// Retorna `true` se todas as permissões obrigatórias foram concedidas.
    var allRequiredPermissionsGranted: Bool {
        fullDiskAccessStatus == .granted
    }

    // ─── Utilitários ──────────────────────────────────────────────────────────

    /// Abre a seção correta das Preferências do Sistema para a permissão dada.
    func openSystemPreferences(for permission: AppPermission) {
        guard let url = URL(string: permission.systemPreferencesPath) else { return }
        NSWorkspace.shared.open(url)
    }
}
