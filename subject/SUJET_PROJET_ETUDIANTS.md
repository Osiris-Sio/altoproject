# 📱 Projet Alto - Application de Pairing Sécurisé

**BUT Informatique - 2ème année**  
**A rendre :** 10/04/2026 minuit  
**Travail en groupe :** 2 à 3 étudiants

---

## 🎯 Objectif du Projet

Développer une application mobile permettant à deux utilisateurs d'établir une connexion sécurisée via un système de pairing par QR Code, puis d'échanger des informations chiffrées de bout en bout.

**Backend fourni :** Le serveur Spring Boot est déjà développé et disponible sur l'url https://alto.samyn.ovh. Vous devez développer l'application mobile Flutter.

---

## 🎨 Phase Préparatoire : Conception et Organisation

### ⚠️ Avant de coder : Maquettes et Architecture

**Important :** Avant de commencer à écrire du code, votre groupe **DOIT** :

1. **Créer des maquettes** (wireframes) de toutes vos interfaces
2. **Découper en widgets unitaires** réutilisables
3. **Répartir la charge de travail** entre les membres du groupe

Cette phase de conception est **essentielle** pour :
- Éviter les conflits Git
- Travailler en parallèle efficacement
- Avoir une vision commune du projet
- Identifier les composants réutilisables

---

### 🖼️ Liste des Écrans à Concevoir

#### 1. Écran d'Accueil (`HomeScreen`)
**Fonctionnalités :**
- [ ] Bouton "Créer une connexion" (→ InitPairingScreen)
- [ ] Bouton "Scanner un QR code" (→ ScanPairingScreen)
- [ ] Liste des relations existantes (si bonus multi-relations)
- [ ] Sélection d'une relation active pour accéder au détails (messages, couleur, etc)

**Widgets à créer :**
- `HomeScreen` (écran principal)
- `RelationListTile` (item de liste, réutilisable)
- `ActionButton` (bouton stylisé, réutilisable)

---

#### 2. Écran d'Initialisation (`InitPairingScreen`)
**Fonctionnalités :**
- [ ] Génération automatique du QR code au chargement
- [ ] Affichage du QR code en grand format
- [ ] Indicateur de chargement pendant la génération des clés
- [ ] Animation de "polling" (attente du scan)
- [ ] Message d'état dynamique ("En attente du scan...", "Connexion détectée !", "Finalisation...")
- [ ] Bouton "Annuler" pour revenir à l'accueil
- [ ] Timer d'expiration visuel (2 minutes countdown)
- [ ] Transition automatique vers RelationScreen après succès

**Widgets à créer :**
- `InitPairingScreen` (écran)
- `QRCodeDisplay` (affichage du QR code avec bordure)
- `PairingStatusIndicator` (indicateur avec icône)
- `CountdownTimer` (timer visuel circulaire)

---

#### 3. Écran de Scan (`ScanPairingScreen`)
**Fonctionnalités :**
- [ ] Vue caméra pour scanner en plein écran
- [ ] Cadre de visée pour guider l'utilisateur
- [ ] Message d'instructions ("Scannez le QR code affiché par votre contact")
- [ ] Feedback visuel et sonore après scan réussi
- [ ] Gestion des permissions caméra (demande + message d'erreur)
- [ ] Indicateur de chargement pendant le match avec le serveur
- [ ] Message d'erreur si QR code invalide
- [ ] Transition automatique vers RelationScreen après succès

**Widgets à créer :**
- `ScanPairingScreen` (écran)
- `CameraView` (vue caméra avec overlay)
- `PermissionRequestDialog` (dialogue de demande de permission)

---

#### 4. Écran de Relation (`RelationScreen`)
**Fonctionnalités :**
- [ ] Affichage du nom/id de la relation active en haut
- [ ] Liste des messages échangés (historique scrollable)
- [ ] Champ de saisie de message en bas
- [ ] Sélecteur de type d'information (dropdown : MESSAGE, ICON, COLOR, URL, LOCATION)
- [ ] Interface adaptée selon le type sélectionné :
  - MESSAGE : champ texte simple
  - ICON : picker d'emoji
  - COLOR : sélecteur de couleur
  - LOCATION : bouton "Ma position actuelle"
- [ ] Bouton d'envoi (désactivé si champ vide)
- [ ] Indicateur "Chiffrement en cours..." pendant l'envoi
- [ ] Bouton "Actualiser" pour récupérer les nouveaux messages
- [ ] Auto-refresh optionnel (toutes les 5 secondes)
- [ ] Affichage différencié selon le type reçu :
  - MESSAGE : bulle de texte
  - ICON : emoji en grand
  - COLOR : rectangle coloré avec code hex
  - LOCATION : mini-carte ou distance à vol d'oiseau
- [ ] Distinction visuelle émetteur/récepteur (bulles alignées différemment, couleurs différentes)

**Widgets à créer :**
- `RelationScreen` (écran de la relation)
- `MessageBubble` (bulle de message, réutilisable, s'adapte au type)
- `MessageInput` (champ de saisie avec sélecteur de type)
- `ColorPickerWidget` (si type COLOR)
- `EmojiPickerWidget` (si type ICON)
- `LocationDisplay` (si type LOCATION)

---

#### 5. Écrans/Widgets Secondaires

##### 5.1 Écran/Overlay de Chargement
**Fonctionnalités :**
- [ ] Animation de chargement (spinner ou animation personnalisée)
- [ ] Message contextuel ("Génération des clés RSA...", "Chiffrement du message...", etc.)
- [ ] Fond semi-transparent

**Widgets à créer :**
- `LoadingOverlay` (widget réutilisable, peut être un modal)

##### 5.2 Widget d'Erreur
**Fonctionnalités :**
- [ ] Message d'erreur clair et compréhensible
- [ ] Icône/illustration d'erreur
- [ ] Bouton "Réessayer"
- [ ] Bouton "Retour à l'accueil"

**Widgets à créer :**
- `ErrorDisplay` (widget réutilisable)

##### 5.3 Widget de Succès
**Fonctionnalités :**
- [ ] Animation de confirmation (checkmark)
- [ ] Message de succès personnalisé
- [ ] Disparition automatique après 2 secondes (optionnel)

**Widgets à créer :**
- `SuccessAnimation` (widget réutilisable)

---

### 📐 Widgets Communs (À Créer en Priorité)

Ces widgets seront utilisés dans **plusieurs écrans**. Créez-les en premier pour garantir la cohérence :

| Widget | Utilisé dans             | Fonction |
|--------|--------------------------|----------|
| `PrimaryButton` | Tous                     | Bouton principal stylisé (ex: "Créer", "Envoyer") |
| `SecondaryButton` | Tous                     | Bouton secondaire (ex: "Annuler", "Retour") |
| `LoadingIndicator` | Tous                     | Spinner personnalisé avec couleurs du thème |
| `EmptyStateWidget` | Home, Relation, Messages | État vide avec illustration (pas de données) |

**Conseil :** Créez ces widgets dans un dossier `lib/widgets/common/` et documentez leur utilisation dans un fichier `README.md` du dossier.

---

### 🎯 Répartition Recommandée du Travail

#### **Groupe de 2 personnes**

**Membre 1 : Pairing + Navigation (50%)**
- `HomeScreen`
- `InitPairingScreen`
- `ScanPairingScreen`
- Services de pairing (`pairing_service.dart`)
- Navigation entre écrans (routes)

**Membre 2 : Crypto + Relation + UI (50%)**
- Cryptographie (`crypto/`)
- Client API (`api_client.dart`)
- `RelationScreen` et widgets de messages
- Widgets communs
- Design global et thème

---

#### **Groupe de 3 personnes**

**Membre 1 : Pairing & Navigation (35%)**
- `HomeScreen`
- `InitPairingScreen`
- `ScanPairingScreen`
- Service de pairing (`pairing_service.dart`)
- Navigation entre écrans (routes)

**Membre 2 : Cryptographie & Backend (30%)**
- Génération des clés (`key_generator.dart`)
- Chiffrement/déchiffrement (`rsa_crypto.dart`)
- Stockage sécurisé (`key_storage.dart`)
- Client API (`api_client.dart`)
- Service d'échange (`element_service.dart`)

**Membre 3 : Relation & Interface (35%)**
- `RelationScreen` complet
- Widgets de messages (`MessageBubble`, `MessageInput`)
- Sélecteurs de types (couleur, emoji, location)
- Widgets communs (buttons, loading, errors)
- Design global, thème et cohérence visuelle

---

### 📋 Checklist Avant de Commencer à Coder

- [ ] **Maquettes dessinées** (papier, Figma, Excalidraw) pour les 4 écrans principaux
- [ ] **Liste des widgets** identifiés et nommés avec leur responsabilité
- [ ] **Répartition des tâches** validée et documentée (qui fait quoi ?)
- [ ] **Convention de nommage** définie (ex: `snake_case` pour les fichiers, `PascalCase` pour les classes)
- [ ] **Structure de dossiers** créée dans `lib/` :
  ```
  lib/
  ├── main.dart
  ├── screens/
  ├── widgets/
  │   ├── common/
  │   └── relation/
  ├── services/
  ├── crypto/
  └── models/
  ```
- [ ] **Branches Git** (`main` : utilisée pour la correction)
- [ ] **Premier commit** : README avec noms du groupe
- [ ] **Suivi** : TODO.md avec les tâches à faire de chaque membre

---

### 🛠️ Outils pour les Maquettes

**Gratuits et recommandés :**
- **[Figma](https://www.figma.com/)** - Le plus complet, collaboration en temps réel (recommandé)
- **Papier + crayon** - Parfaitement valide pour démarrer rapidement !

**Conseils pour les maquettes :**
- Restez **simples** : des wireframes basiques suffisent (pas besoin de designs finaux)
- **Annotez** les interactions (boutons → écrans, actions)
- **Numérotez** les écrans pour la navigation (1. Home → 2a. Init ou 2b. Scan → 3. Relation)
- **Validez** les maquettes avec toute l'équipe avant de commencer à coder
- **Prenez une photo** ou exportez-les et ajoutez-les dans un dossier `/docs/mockups/` du dépôt

---

### ⚡ Astuces pour Bien Démarrer

1. **Commencez par les widgets communs** (`PrimaryButton`, `LoadingIndicator`, etc.)
   - Tout le monde peut les utiliser immédiatement
   - Garantit la cohérence visuelle dès le départ

2. **Créez des "TODO" temporaires**
   ```dart
   // TODO(Membre2): Implémenter le chiffrement RSA ici
   String encryptMessage(String message) {
     return message; // Version temporaire non chiffrée
   }
   ```
3. **Documentez au fur et à mesure**
   - Ajoutez des commentaires sur les fonctions complexes
   - Mettez à jour le README avec les choix techniques

4. **Communiquez régulièrement**
   - Créez un groupe Discord/WhatsApp
   - Partagez vos blocages rapidement
   - Faites des mini code reviews entre vous

---

## 📚 Documentation Technique

Avant de commencer, lisez attentivement les guides suivants :

1. **`GUIDE_PAIRING.md`** - Comprendre le workflow de pairing (QR code, polling, statuts)
2. **`GUIDE_KEYS.md`** - Génération et utilisation des clés publiques/privées
3. **`GUIDE_ELEMENT.md`** - Échange sécurisé d'informations post-appairage

---

## 🛠️ Stack Technique Imposée

### Application Mobile
- **Framework :** Flutter / Dart
- **Dépendances à étudier :**
  - `qr_flutter` - Génération de QR codes
  - `mobile_scanner` ou `qr_code_scanner` - Scan de QR codes
  - `pointycastle` - Cryptographie RSA
  - `basic_utils` - Manipulation des clés PEM
  - `flutter_secure_storage` - Stockage sécurisé des clés privées
  - `http` ou `dio` - Appels API REST

---

## 📋 Fonctionnalités à Implémenter

### 🟢 Partie 1 : Pairing Initial (4 points)

#### Feature 1.1 : Initialisation du Pairing (1 points)
**Objectif :** L'utilisateur A (Alice) peut initier un pairing.

**Critères de validation :**
- [ ] Génération d'une paire de clés RSA (2048 bits)
- [ ] Génération d'un `relationCode` unique (UUID recommandé)
- [ ] Appel API `POST /pairing` avec les bonnes données
- [ ] Affichage d'un QR code contenant le `relationCode`
- [ ] Stockage sécurisé de la clé privée dans `flutter_secure_storage`

**Livrables :**
- Code de génération des clés (`lib/crypto/`)
- Écran d'initialisation avec bouton "Créer une connexion"
- Génération et affichage du QR code

---

#### Feature 1.2 : Scan et Match (1 points)
**Objectif :** L'utilisateur B (Bob) peut scanner le QR code et compléter le pairing.

**Critères de validation :**
- [ ] Ouverture de la caméra pour scanner le QR code
- [ ] Extraction du `relationCodeA` depuis le QR code
- [ ] Génération de sa propre paire de clés + `relationCodeB`
- [ ] Appel API `PUT /pairing` avec les trois informations
- [ ] Réception et stockage sécurisé des informations d'Alice

**Livrables :**
- Écran de scan avec bouton "Scanner un QR code"
- Logique de match avec l'API
- Feedback visuel (succès/erreur)

---

#### Feature 1.3 : Polling et Détection (1 points)
**Objectif :** Les deux applications détectent automatiquement la complétion du pairing.

**Critères de validation :**
- [ ] Alice poll `GET /pairing/{id}/status` toutes les 2-3 secondes
- [ ] Détection du passage à `"completed"` côté Alice
- [ ] Bob poll après le match pour détecter `"finalized"`
- [ ] Arrêt automatique du polling une fois terminé
- [ ] Gestion du timeout (abandon après 2 minutes)

**Livrables :**
- Service de polling avec Timer ou Stream
- Écran d'attente avec indicateur de progression
- Gestion des états (waiting → completed → finalized)

---

#### Feature 1.4 : Finalisation (1 points)
**Objectif :** Alice finalise le pairing et récupère les informations de Bob.

**Critères de validation :**
- [ ] Appel API `DELETE /pairing` après détection de `"completed"`
- [ ] Réception et stockage des informations de Bob
- [ ] Confirmation visuelle du succès du pairing
- [ ] Sauvegarde de la relation (clés publiques + relationCodes)

**Livrables :**
- Logique de finalisation
- Écran de confirmation "Connexion établie avec succès"
- Persistance des données de relation

---

### 🟡 Partie 2 : Échange Sécurisé d'Informations (8 points)

#### Feature 2.1 : Chiffrement et Envoi (2 points)
**Objectif :** Un utilisateur peut envoyer un message chiffré à son contact.

**Critères de validation :**
- [ ] Interface pour saisir un message (type `MESSAGE`)
- [ ] Chiffrement du message
- [ ] Encodage en Base64 pour transmission
- [ ] Appel API `POST /element` avec `relationCode`, `key`, `value`
- [ ] Confirmation d'envoi

**Livrables :**
- Écran de composition de message
- Fonctions de chiffrement RSA (`rsaEncryptToBase64`)
- Gestion des erreurs (message trop long, erreur réseau)

---

#### Feature 2.2 : Réception et Déchiffrement (2 points)
**Objectif :** Un utilisateur peut récupérer et lire un message chiffré.

**Critères de validation :**
- [ ] Bouton "Vérifier les messages" ou polling automatique
- [ ] Appel API `GET /element?relationCode={code}`
- [ ] Décodage Base64 et déchiffrement RSA
- [ ] Stockage et affichage du message en clair
- [ ] Gestion du cas "aucun message"

**Livrables :**
- Écran de réception des messages
- Fonctions de déchiffrement RSA (`rsaDecryptFromBase64`)
- Interface utilisateur claire (émetteur/récepteur)

---

#### Feature 2.3 : Types d'Informations Multiples (4 points)
**Objectif :** Supporter plusieurs types d'échanges (pas seulement `MESSAGE`).

**Critères de validation :**
- [ ] Support de `MESSAGE` (texte)
- [ ] Support d'au moins 2 autres types au choix :
  - `ICON` : partage d'un emoji/icône
  - `COLOR` : partage d'une couleur (hex)
  - `URL` : partage d'un lien
  - `LOCATION` : partage de coordonnées GPS (lat/lng)
- [ ] Interface adaptée selon le type (sélecteur de couleur, picker d'emoji, etc.)
- [ ] Affichage adapté à la réception

**Livrables :**
- Interface multi-types avec sélecteur
- Logique de sérialisation/désérialisation
- Au moins 3 types différents fonctionnels

---

### 🔵 Partie 3 : Qualité et Professionnalisme (5 points)

#### Feature 3.1 : Gestion des Erreurs (1.5 points)
**Critères de validation :**
- [ ] Try-catch sur tous les appels API
- [ ] Messages d'erreur clairs pour l'utilisateur
- [ ] Gestion des cas limites (réseau indisponible, QR invalide, timeout)
- [ ] Logs utiles pour le débogage (sans afficher les clés privées !)

---

#### Feature 3.2 : Interface Utilisateur (2.5 points)
**Critères de validation :**
- [ ] Design cohérent et professionnel
- [ ] Navigation intuitive (home → init/scan → relation)
- [ ] Feedback visuel (loading, success, error)
- [ ] Responsive (fonctionne sur différentes tailles d'écran)

---

#### Feature 3.3 : Organisation du Code (1 point)
**Critères de validation :**
- [ ] Architecture propre (séparation UI / logique / API)
- [ ] Nommage clair des variables et fonctions
- [ ] Commentaires sur les parties complexes (crypto)
- [ ] Respect des conventions Dart/Flutter

---

### ⭐ Bonus : Multi-Relations (3 points)

**Objectif :** Permettre à un utilisateur de gérer plusieurs relations simultanément.

**Critères de validation :**
- [ ] Liste des relations existantes
- [ ] Génération d'une paire de clés par relation
- [ ] Sélection de la relation active pour envoyer/recevoir
- [ ] Interface de gestion (ajout, suppression, sélection)

**Livrables :**
- Écran de liste des contacts/relations
- Possibilité de créer plusieurs pairings

---

## 📊 Barème Détaillé

| Partie | Feature | Points    |
|--------|---------|-----------|
| **Partie 1** | **Pairing Initial** | **4 pts** |
| | 1.1 - Initialisation | 1         |
| | 1.2 - Scan et Match | 1         |
| | 1.3 - Polling et Détection | 1         |
| | 1.4 - Finalisation | 1         |
| **Partie 2** | **Échange Sécurisé** | **8 pts** |
| | 2.1 - Chiffrement et Envoi | 2         |
| | 2.2 - Réception et Déchiffrement | 2         |
| | 2.3 - Types Multiples | 4         |
| **Partie 3** | **Qualité** | **5 pts** |
| | 3.1 - Gestion des Erreurs | 1.5       |
| | 3.2 - Interface Utilisateur | 2.5       |
| | 3.3 - Organisation du Code | 1         |
| **Bonus** | Multi-Relations | **3 pts** |
| | **TOTAL** | **/20**   |

---

## 🗓️ Planning Recommandé

### Etape 1 : Découverte et Setup
- [ ] Lecture des guides
- [ ] Installation de l'environnement (Flutter, Android Studio)
- [ ] Lancement du backend avec Docker
- [ ] Tests API avec Postman (suivre `GUIDE_PAIRING.md`)
- [ ] Création du dépôt GitHub + organisation du projet

### Etape 2 : Pairing - Partie Initialisation
- [ ] Feature 1.1 : Génération de clés et QR code
- [ ] Tests unitaires sur la génération de clés

### Etape 3 : Pairing - Partie Scan et Finalisation
- [ ] Feature 1.2 : Scan et match
- [ ] Feature 1.3 : Polling
- [ ] Feature 1.4 : Finalisation
- [ ] Test du workflow complet entre 2 appareils

### Etape 4 : Échange Sécurisé
- [ ] Feature 2.1 : Chiffrement et envoi
- [ ] Feature 2.2 : Réception et déchiffrement
- [ ] Tests de bout en bout

### Etape 5 : Types Multiples et Qualité
- [ ] Feature 2.3 : Types multiples
- [ ] Feature 3.1 et 3.2 : Gestion d'erreurs et UI
- [ ] Refactoring et nettoyage du code

### Etape 6 : Finitions
- [ ] Feature 3.3 et 3.4 : Organisation et tests
- [ ] (Optionnel) Bonus multi-relations
- [ ] Afficher météo locale dans RelationScreen (bonus non noté)

---

## 📦 Livrables Attendus

### Sur GitHub

**Structure attendue du dépôt :**
```
votre-repo-alto/
├── README.md                    # Documentation du projet + instructions
├── lib/
│   ├── main.dart
│   ├── screens/                 # Écrans de l'app
│   │   ├── home_screen.dart
│   │   ├── init_pairing_screen.dart
│   │   ├── scan_pairing_screen.dart
│   │   └── relation_screen.dart
│   ├── services/                # Logique métier
│   │   ├── pairing_service.dart
│   │   ├── element_service.dart
│   │   └── api_client.dart
│   ├── crypto/                  # Cryptographie
│   │   ├── key_generator.dart
│   │   ├── rsa_crypto.dart
│   │   └── key_storage.dart
│   └── models/                  # Modèles de données
│       ├── pairing.dart
│       └── element.dart
└── pubspec.yaml
```

### README.md du projet

Votre README doit contenir :
1. **Titre et description** du projet
2. **Membres du groupe** (noms + rôles)
3. **Fonctionnalités implémentées** : checklist des features
4. **Améliorations possibles**

---

## 🚨 Points d'Attention Sécurité

### ⚠️ À NE JAMAIS FAIRE
- ❌ Commiter les clés privées sur GitHub
- ❌ Logger les clés privées dans la console
- ❌ Transmettre une clé privée via l'API
- ❌ Stocker les clés en clair dans les SharedPreferences

### ✅ Bonnes Pratiques
- ✅ Utiliser `flutter_secure_storage` pour les clés privées
- ✅ Ajouter `.env`, `*.key`, `*.pem` au `.gitignore`
- ✅ Valider les inputs utilisateur (longueur, format)
- ✅ Gérer les exceptions crypto (message trop long pour RSA)

---

## 💡 Conseils pour Réussir

### Organisation du Travail
1. **Utilisez GitHub efficacement :**
   - Créez des branches par feature (`feature/pairing-init`)
   - Merge régulièrement dans `main` quand une feature est terminée
   - Utilisez les Issues pour tracker les tâches

2. **Travaillez en parallèle :**
   - Une personne sur le pairing, une autre sur la crypto
   - Fusionnez régulièrement pour éviter les conflits

3. **Testez souvent :**
   - Testez chaque feature avant de passer à la suivante
   - Utilisez 2 émulateurs ou 1 émulateur + 1 téléphone

### Debugging
- Utilisez `print()` ou `debugPrint()` pour tracer le flux
- Testez les appels API avec Postman **avant** de coder dans Flutter
- Consultez les guides fournis en cas de doute

---

## ❓ FAQ

**Q : Peut-on utiliser un autre langage que Flutter ?**  
R : Non, Flutter/Dart est imposé.

**Q : Le backend est-il modifiable ?**  
R : Non, le backend est fourni tel quel. Vous ne devez travailler que sur l'application mobile.

**Q : Combien de temps prend le polling ?**  
R : Testez avec 2-3 secondes. Si c'est trop lent, vous pouvez descendre à 1 seconde.

**Q : RSA est lent, peut-on utiliser AES ?**  
R : Pour ce projet pédagogique, RSA suffit. Le chiffrement hybride (RSA + AES) est un bonus non noté mais mentionnable en soutenance.

**Q : Peut-on travailler seul ?**  
R : Non, le travail en groupe (2-3) est obligatoire pour simuler un environnement professionnel.

**Q : Comment tester avec 2 appareils ?**  
R : Utilisez 2 émulateurs Android, ou 1 émulateur + votre téléphone en mode debug.

---

**Bon courage ! 🚀**

*Ce projet vous permettra de comprendre :* 
- les bases de la cryptographie asymétrique, 
- les échanges sécurisés 
- l'architecture client-serveur
- les bases du développement mobile avec Flutter.
