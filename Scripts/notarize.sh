#!/usr/bin/env bash
# =============================================================================
# notarize.sh — Build, Archive, Export e Notarização do StoreLens
# =============================================================================
#
# Pré-requisitos:
#   1. Xcode Command Line Tools instalado
#   2. Developer ID Application certificate no Keychain
#   3. App-specific password gerado em appleid.apple.com
#   4. Variáveis de ambiente configuradas (ver abaixo)
#
# Uso:
#   export APPLE_ID="seu@email.com"
#   export APPLE_TEAM_ID="M667GNZHD4"
#   export NOTARY_PASSWORD="xxxx-xxxx-xxxx-xxxx"   # app-specific password
#   ./Scripts/notarize.sh
# =============================================================================

set -e  # Para o script em qualquer erro

# ─── Configuração ─────────────────────────────────────────────────────────────

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$PROJECT_ROOT/Memora.xcodeproj"
SCHEME="Memora (Notarized)"
EXPORT_OPTIONS="$PROJECT_ROOT/Scripts/ExportOptions.plist"
ARCHIVE_PATH="$PROJECT_ROOT/build/Memora.xcarchive"
EXPORT_PATH="$PROJECT_ROOT/build/export"
APP_PATH="$EXPORT_PATH/Memora.app"
DMG_PATH="$PROJECT_ROOT/build/Memora.dmg"

echo "=== StoreLens — Build & Notarize ==="
echo "Projeto: $PROJECT_FILE"
echo ""

# ─── 1. Limpar build anterior ─────────────────────────────────────────────────

echo "[1/5] Limpando build anterior..."
rm -rf "$PROJECT_ROOT/build"
mkdir -p "$PROJECT_ROOT/build"

# ─── 2. Archive ───────────────────────────────────────────────────────────────

echo "[2/5] Gerando archive..."
xcodebuild archive \
  -project "$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -configuration Notarized \
  -archivePath "$ARCHIVE_PATH" \
  -destination "generic/platform=macOS" \
  | xcpretty || true

echo "Archive gerado em: $ARCHIVE_PATH"

# ─── 3. Export ────────────────────────────────────────────────────────────────

echo "[3/5] Exportando .app assinado..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -exportPath "$EXPORT_PATH"

echo "App exportado em: $APP_PATH"

# ─── 4. Notarização ───────────────────────────────────────────────────────────

echo "[4/5] Submetendo para notarização na Apple..."

# Comprime o .app em zip para envio
ditto -c -k --keepParent "$APP_PATH" "$EXPORT_PATH/Memora.zip"

# Envia para o serviço de notarização e aguarda o resultado
xcrun notarytool submit "$EXPORT_PATH/Memora.zip" \
  --apple-id "$APPLE_ID" \
  --team-id "$APPLE_TEAM_ID" \
  --password "$NOTARY_PASSWORD" \
  --wait \
  --output-format plist

echo "Notarização aprovada!"

# ─── 5. Staple ────────────────────────────────────────────────────────────────

echo "[5/5] Aplicando staple ao .app..."
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"

echo ""
echo "=== Concluído com sucesso! ==="
echo "App notarizado em: $APP_PATH"

# Opcional: gerar DMG para distribuição
# hdiutil create -volname "StoreLens" -srcfolder "$APP_PATH" \
#   -ov -format UDZO "$DMG_PATH"
# echo "DMG gerado em: $DMG_PATH"
