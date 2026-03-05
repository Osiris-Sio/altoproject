# 🔐 Guide Étudiant — Clés publiques/privées (chiffrement & déchiffrement)

## 🎯 Objectif

Comprendre **comment générer** une paire de clés **publique/privée**, puis **chiffrer** un contenu pour qu’il ne soit **déchiffrable que par l’autre partie**.

Dans ce guide, on utilise une approche standard et simple à mettre en pratique :

- **Chaque personne possède une paire de clés** :
  - **clé privée** : *secrète*, ne doit jamais quitter l’appareil
  - **clé publique** : *partageable*, peut être envoyée à n’importe qui
- Pour envoyer un message à Bob : **Alice chiffre avec la clé publique de Bob**.
- Bob déchiffre avec **sa clé privée**.

> Important : en pratique, on ne chiffre presque jamais de gros contenus directement avec RSA. On utilise un schéma hybride :
> - RSA (ou ECC) pour échanger une **clé symétrique**
> - AES/GCM pour chiffrer les données
>
> Mais pour apprendre, on peut commencer par un chiffrement “direct” (petit message), puis passer au schéma hybride.

---

## 🧠 Concepts essentiels (à connaître)

### 1) Chiffrement vs signature

- **Chiffrement** : garantit la **confidentialité** (seul le détenteur de la clé privée peut lire).
- **Signature** : garantit **l’authenticité** (prouve “c’est bien moi qui ai écrit ça”) et l’**intégrité**.

Ce guide couvre **le chiffrement**.

### 2) Règle d’or

- La **clé privée** ne se partage jamais.
- La **clé publique** se partage librement.

### 3) Formats

Vous verrez souvent :
- **PEM** (texte base64 avec en-têtes `-----BEGIN ...-----`)
- **DER** (binaire)

Ici, on va rester sur **PEM**.

---

## 4️⃣ Quels “keys” échanger dans le projet Alto Pairing ?

Dans le workflow de pairing, chaque client doit partager une **clé publique** (jamais la privée).

- `userPublicKey` = la **clé publique** de l’utilisateur
- La clé privée reste sur le téléphone / machine locale

Recommandation pour le projet :
- échangez les clés publiques via le serveur de pairing

---

## ✅ Checklist sécurité (à appliquer)

- [ ] Clé privée stockée sur le téléphone / machine locale uniquement
- [ ] Clé publique transférée lors du pairing uniquement
- [ ] Ne jamais logger les clés privées / secrets

---

## 📱 Flutter / Dart — version pédagogique (simple + rapide)

Le but ici n’est **pas** de faire de la crypto “niveau banque”. On vise un truc :
- **simple à coder**
- qui illustre bien : *clé publique / clé privée* + *seul le destinataire peut déchiffrer*

✅ Hypothèse pédagogique : **les messages sont petits** (ex: un code, un token, un mini-JSON).

### ✅ Principe retenu (le plus simple possible)

- Chaque utilisateur génère une paire **RSA** (publique/privée)
- Il **envoie sa clé publique** à l’autre (via le serveur de pairing)
- Pour envoyer un message à l’autre :
  - je chiffre avec **sa clé publique**
  - il déchiffre avec **sa clé privée**

> Important (à expliquer aux étudiants) : RSA ne chiffre pas des gros messages. Si vous dépassez 150-200 caractères, ça casse.

### 👥 Une paire de clés par relation

On veut que l’app crée une paire de clés **pour chaque relation** (ex: chaque pairing).

- pour une relation `relationId`, l’utilisateur A stocke :
  - `A_privateKey(relationId)` (local)
  - `A_publicKey(relationId)` (partageable)

Ça permet d’avoir une crypto “isolée” par relation.

---

## 1) Dépendances Flutter

Dans `pubspec.yaml` (pédago) :

```yaml
dependencies:
  pointycastle: ^3.9.1
  basic_utils: ^5.7.0
  flutter_secure_storage: ^9.2.2
```

On utilise :
- `pointycastle` pour RSA-OAEP
- `basic_utils` pour encoder/décoder PEM
- `flutter_secure_storage` pour stocker la clé privée localement

---

## 2) Générer une paire RSA (par relation)

Fichier exemple : `lib/crypto/relationship_keys.dart`

```dart
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';

FortunaRandom _secureRandom() {
  final random = FortunaRandom();
  final seed = Uint8List(32);
  final r = Random.secure();
  for (var i = 0; i < seed.length; i++) {
    seed[i] = r.nextInt(256);
  }
  random.seed(pc.KeyParameter(seed));
  return random;
}

/// Génère une paire RSA (pédago) et renvoie les clés en PEM.
/// À appeler *une fois par relation*.
({String publicKeyPem, String privateKeyPem}) generateRelationshipRsaKeyPair({
  int bitLength = 2048,
}) {
  final generator = RSAKeyGenerator()
    ..init(
      pc.ParametersWithRandom(
        pc.RSAKeyGeneratorParameters(
          BigInt.parse('65537'),
          bitLength,
          64,
        ),
        _secureRandom(),
      ),
    );

  final pair = generator.generateKeyPair();
  final publicKey = pair.publicKey as pc.RSAPublicKey;
  final privateKey = pair.privateKey as pc.RSAPrivateKey;

  return (
    publicKeyPem: CryptoUtils.encodeRSAPublicKeyToPem(publicKey),
    privateKeyPem: CryptoUtils.encodeRSAPrivateKeyToPem(privateKey),
  );
}
```

---

## 3) Stocker les clés par `relationId`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RelationshipKeyStorage {
  final FlutterSecureStorage _storage;

  RelationshipKeyStorage(this._storage);

  String _pubKey(String relationId) => 'rel:$relationId:pubPem';
  String _privKey(String relationId) => 'rel:$relationId:privPem';

  Future<void> saveKeyPair(
    String relationId, {
    required String publicKeyPem,
    required String privateKeyPem,
  }) async {
    // Vous pouvez stocker la clé publique ailleurs (prefs),
    // mais la garder ici est plus simple.
    await _storage.write(key: _pubKey(relationId), value: publicKeyPem);
    await _storage.write(key: _privKey(relationId), value: privateKeyPem);
  }

  Future<String?> readPublicKeyPem(String relationId) =>
      _storage.read(key: _pubKey(relationId));

  Future<String?> readPrivateKeyPem(String relationId) =>
      _storage.read(key: _privKey(relationId));
}
```

---

## 4) Chiffrer / déchiffrer un petit message (RSA-OAEP)

### Payload simple

Comme RSA sort des **bytes**, on transporte le résultat en Base64 :

- `ciphertextB64` (String)

### Exemple Flutter (le plus direct)

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/asymmetric/api.dart' show RSAPublicKey, RSAPrivateKey;
import 'package:pointycastle/asymmetric/oaep.dart';

String rsaEncryptToBase64({
  required String recipientPublicKeyPem,
  required String plaintext,
}) {
  final RSAPublicKey publicKey = CryptoUtils.rsaPublicKeyFromPem(recipientPublicKeyPem);

  final engine = OAEPEncoding(pc.RSAEngine())
    ..init(true, pc.PublicKeyParameter<RSAPublicKey>(publicKey));

  final ciphertextBytes = engine.process(Uint8List.fromList(utf8.encode(plaintext)));
  return base64Encode(ciphertextBytes);
}

String rsaDecryptFromBase64({
  required String myPrivateKeyPem,
  required String ciphertextB64,
}) {
  final RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(myPrivateKeyPem);

  final engine = OAEPEncoding(pc.RSAEngine())
    ..init(false, pc.PrivateKeyParameter<RSAPrivateKey>(privateKey));

  final clearBytes = engine.process(base64Decode(ciphertextB64));
  return utf8.decode(clearBytes);
}
```

### Taille max

Avec RSA-2048, on ne peut pas chiffrer beaucoup.
Si vous essayez de chiffrer un texte trop long, vous aurez une erreur du type :
- “data too large for key size” / “input too large”

Donc :
- chiffrez des **petits messages** (codes, tokens, mini JSON)
- si vous voulez chiffrer des gros contenus, il faudra passer en hybride (hors de ce TP)

---