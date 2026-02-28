import SwiftUI

/// Nível de risco de remoção de um arquivo ou categoria.
/// Exibido como semáforo na UI (Verde → Vermelho).
enum RiskLevel: Int, Comparable, Sendable {
    case veryLow = 0
    case low     = 1
    case medium  = 2
    case high    = 3

    static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .veryLow: return "Muito Baixo"
        case .low:     return "Baixo"
        case .medium:  return "Médio"
        case .high:    return "Alto"
        }
    }

    var color: Color {
        switch self {
        case .veryLow: return .green
        case .low:     return .green
        case .medium:  return .yellow
        case .high:    return .red
        }
    }

    /// Ícone de semáforo para uso em badges na UI
    var systemImage: String {
        switch self {
        case .veryLow, .low: return "checkmark.circle.fill"
        case .medium:        return "exclamationmark.triangle.fill"
        case .high:          return "xmark.octagon.fill"
        }
    }
}
