# Script de test - Feature Profile
# Exécutez ce script pour tester la feature Profile

Write-Host "🚀 Test de la Feature Profile - Alto" -ForegroundColor Cyan
Write-Host ""

# Navigation vers le projet
Set-Location "C:\Users\lysan\AndroidStudioProjects\altoproject\src"

Write-Host "1️⃣  Vérification des dépendances..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dépendances OK" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "2️⃣  Analyse du code..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Analyse OK - Aucun problème critique" -ForegroundColor Green
} else {
    Write-Host "⚠️ Des avertissements ont été détectés" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "3️⃣  Vérification des fichiers Profile..." -ForegroundColor Yellow
$profileFiles = @(
    "lib\features\profile\models\pairing_relation.dart",
    "lib\features\profile\notifiers\profile_notifier.dart",
    "lib\features\profile\providers\profile_providers.dart",
    "lib\features\profile\view\profile_screen.dart",
    "lib\features\profile\widgets\qr_code_display.dart",
    "lib\features\profile\widgets\countdown_timer.dart",
    "lib\services\pairing_api_service.dart"
)

$allFilesExist = $true
foreach ($file in $profileFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file MANQUANT" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if ($allFilesExist) {
    Write-Host "✅ Tous les fichiers Profile sont présents" -ForegroundColor Green
} else {
    Write-Host "❌ Certains fichiers manquent" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ Feature Profile prête à être testée !" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "📱 Pour lancer l'application :" -ForegroundColor Yellow
Write-Host "   flutter run" -ForegroundColor White
Write-Host ""

Write-Host "📋 Scénario de test :" -ForegroundColor Yellow
Write-Host "   1. Créer un compte (prénom)" -ForegroundColor White
Write-Host "   2. Observer la navigation vers ProfileScreen" -ForegroundColor White
Write-Host "   3. Voir le QR Code généré" -ForegroundColor White
Write-Host "   4. Observer le countdown (2:00 → 0:00)" -ForegroundColor White
Write-Host "   5. Tester l'expiration et la régénération" -ForegroundColor White
Write-Host ""

Write-Host "🔐 Fonctionnalités implementées :" -ForegroundColor Yellow
Write-Host "   ✓ QR Code dynamique avec expiration" -ForegroundColor Green
Write-Host "   ✓ Countdown timer 2 minutes" -ForegroundColor Green
Write-Host "   ✓ Progression circulaire visuelle" -ForegroundColor Green
Write-Host "   ✓ Polling automatique (prêt pour API)" -ForegroundColor Green
Write-Host "   ✓ Gestion des états (loading, actif, expiré)" -ForegroundColor Green
Write-Host "   ✓ Sécurité IRL (In Real Life pairing)" -ForegroundColor Green
Write-Host ""

$response = Read-Host "Voulez-vous lancer l'application maintenant? (O/N)"
if ($response -eq "O" -or $response -eq "o") {
    Write-Host ""
    Write-Host "🚀 Lancement de Alto..." -ForegroundColor Cyan
    flutter run
} else {
    Write-Host ""
    Write-Host "👋 À bientôt !" -ForegroundColor Cyan
}

