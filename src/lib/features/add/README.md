# Feature "Add" - Ajout de Contact avec Pairing IRL

## 📋 Vue d'ensemble

Cette feature implémente le flux complet d'ajout d'un contact via le système de pairing IRL (In Real Life) d'Alto. Deux utilisateurs doivent être physiquement ensemble pour scanner un QR code et échanger leurs clés publiques de manière sécurisée.

## 🏗️ Architecture

### Structure des dossiers

```
lib/features/add/
├── models/
│   ├── contact.dart              # Modèle de contact
│   └── pairing_data.dart         # Modèles de données de pairing
├── services/
│   ├── crypto_service.dart       # Génération de clés RSA
│   ├── key_storage.dart          # Stockage sécurisé des clés
│   ├── database_service.dart     # Base de données SQLite
│   └── pairing_api_service.dart  # Appels API vers le backend
├── notifiers/
│   └── add_user_notifier.dart    # Logique métier du pairing
├── providers/
│   └── add_providers.dart        # Providers Riverpod
└── view/
    ├── add_screen.dart           # Écran principal d'ajout
    ├── scan_pairing_screen.dart  # Écran de scan QR code
    ├── show_qr_screen.dart       # Écran d'affichage QR code
    └── add_confirm_screen.dart   # Écran de confirmation
```

## 🔄 Flux de Pairing

### Scénario 1 : Alice montre son QR code, Bob scanne

1. **Alice** :
   - Ouvre l'écran "Montrer mon QR code"
   - L'app génère une paire de clés RSA (2048 bits)
   - L'app génère un `relationCode` (UUID)
   - L'app appelle `POST /pairing` pour initialiser
   - L'app affiche le QR code contenant le `relationCode`
   - L'app commence le polling (`GET /pairing/{id}/status`)

2. **Bob** :
   - Ouvre l'écran "Scanner un QR code"
   - Scanne le QR code d'Alice
   - L'app génère sa propre paire de clés RSA
   - L'app génère son `relationCode`
   - L'app appelle `PUT /pairing` pour matcher
   - L'app reçoit la clé publique d'Alice
   - L'app démarre le polling pour la finalisation

3. **Alice** (détection du match) :
   - Le polling détecte `status: "completed"`
   - L'app appelle `DELETE /pairing` pour finaliser
   - L'app reçoit la clé publique de Bob
   - Navigation vers l'écran de confirmation

4. **Bob** (détection de la finalisation) :
   - Le polling détecte `status: "finalized"`
   - Navigation vers l'écran de confirmation

5. **Les deux utilisateurs** :
   - Entrent le nom du contact
   - Valident l'ajout
   - Le contact est sauvegardé en local (SQLite + clés dans SecureStorage)

## 🔐 Sécurité

### Cryptographie

- **Algorithme** : RSA 2048 bits
- **Génération** : Utilise `pointycastle` avec un générateur sécurisé
- **Format** : Clés encodées en PEM
- **Stockage** :
  - Clé privée : `flutter_secure_storage` (chiffrée par l'OS)
  - Clé publique : SQLite + SecureStorage
  - Contact : SQLite

### Principe

- Chaque utilisateur génère une paire de clés unique par relation
- Seule la clé publique est échangée via le serveur
- La clé privée ne quitte jamais l'appareil
- Le serveur ne conserve les données que 2 minutes après le match

## 🌐 API Backend

### Configuration

Dans `lib/features/add/providers/add_providers.dart`, modifiez l'URL du backend :

```dart
final pairingApiServiceProvider = Provider<PairingApiService>((ref) {
  return PairingApiService(baseUrl: 'http://votre-serveur:8080');
});
```

### Endpoints utilisés

1. **POST /pairing** - Initialisation
   ```json
   {
     "relationCode": "uuid-v4",
     "userPublicKey": "-----BEGIN RSA PUBLIC KEY-----..."
   }
   ```

2. **PUT /pairing** - Match
   ```json
   {
     "relationCodeA": "uuid-alice",
     "relationCodeB": "uuid-bob",
     "publicKeyB": "-----BEGIN RSA PUBLIC KEY-----..."
   }
   ```

3. **GET /pairing/{relationCode}/status** - Polling
   ```json
   {
     "status": "waiting|completed|finalized"
   }
   ```

4. **DELETE /pairing?relationCodeA={relationCode}** - Finalisation
   ```json
   {
     "relationCodeB": "uuid-bob",
     "publicKeyB": "-----BEGIN RSA PUBLIC KEY-----..."
   }
   ```

## 📱 Permissions

### Android

Les permissions suivantes sont configurées dans `AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

L'app demande automatiquement la permission caméra au premier scan.

### iOS

À configurer dans `ios/Runner/Info.plist` :

```xml
<key>NSCameraUsageDescription</key>
<string>Alto a besoin d'accéder à la caméra pour scanner les QR codes de pairing</string>
```

## 🎨 UI/UX

### Palette de couleurs

- Fond principal : `#E6D5F5` (violet clair)
- Accent : `#6B4FA0` (violet foncé)
- Boutons : `#D4C5E8` (violet moyen)

### Écrans

1. **AddScreen** : Choix entre scanner ou montrer le QR code
2. **ScanPairingScreen** : Caméra avec overlay de scan
3. **ShowQrScreen** : Affichage du QR code + indicateur de polling
4. **AddConfirmScreen** : Saisie du nom + confirmation finale

## 🧪 Tests

### Test manuel avec Postman/Bruno

Les collections de tests sont disponibles dans `/bruno/` :

1. `Init.bru` - Initialisation du pairing
2. `Match.bru` - Match du pairing
3. `Get Status.bru` - Vérification du statut
4. `Finalize.bru` - Finalisation

### Test en local

1. Démarrez le backend Spring Boot :
   ```bash
   cd backend
   ./gradlew bootRun
   ```

2. Lancez l'app Flutter :
   ```bash
   cd src
   flutter run
   ```

3. Pour tester avec deux appareils :
   - Utilisez un émulateur + un appareil physique
   - Ou deux émulateurs Android (attention au réseau)

## 📦 Dépendances

```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # State management
  mobile_scanner: ^5.2.3        # Scan QR code
  qr_flutter: ^4.1.0            # Affichage QR code
  pointycastle: ^3.9.1          # Cryptographie RSA
  basic_utils: ^5.7.0           # Encodage PEM
  flutter_secure_storage: ^9.2.4 # Stockage sécurisé
  http: ^1.2.2                  # HTTP client
  uuid: ^4.5.2                  # Génération UUID
  sqflite: ^2.4.2               # Base de données
  path_provider: ^2.1.5         # Chemins système
  permission_handler: ^11.4.0   # Gestion permissions
```

## 🚀 Utilisation

```dart
// Navigation vers l'écran d'ajout
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AddScreen(),
  ),
);
```

## ⚠️ Points d'attention

1. **Polling** : Le polling s'arrête automatiquement après détection du changement de statut
2. **Timeout** : Le serveur supprime les pairings après 2 minutes d'inactivité
3. **Réseau** : L'app nécessite une connexion internet pour le pairing
4. **Caméra** : Demande de permission au premier scan
5. **Backend** : Assurez-vous que le backend est accessible depuis l'appareil

## 🔮 Améliorations futures

- [ ] Ajout de photos de profil
- [ ] Support de QR codes avec clé publique directement
- [ ] Mode offline avec partage Bluetooth
- [ ] Vérification d'identité par code PIN
- [ ] Support de groupes
- [ ] Import/export de contacts

## 📝 Notes techniques

### Base de données

Table `contacts` :
```sql
CREATE TABLE contacts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  relationCode TEXT NOT NULL UNIQUE,
  publicKey TEXT NOT NULL,
  createdAt TEXT NOT NULL
)
```

### Stockage sécurisé

Clés stockées avec le pattern :
- `rel:{relationCode}:pubPem` - Clé publique
- `rel:{relationCode}:privPem` - Clé privée

## 📚 Ressources

- [GUIDE_PAIRING.md](../../../../subject/GUIDE_PAIRING.md) - Guide détaillé du workflow
- [GUIDE_KEYS.md](../../../../subject/GUIDE_KEYS.md) - Guide de cryptographie
- [GUIDE_ELEMENT.md](../../../../subject/GUIDE_ELEMENT.md) - Échange de messages

---

**Développé pour Alto - Messagerie Sécurisée**

