# 🎓 Guide Étudiant - Système de Pairing

## 🎯 Objectif

Permettre à deux utilisateurs d'échanger leurs clés publiques de manière sécurisée via un serveur temporaire.

---

## 📱 Workflow pour Application Mobile avec QR Code

Ce scénario est le plus courant pour une application mobile. Alice veut se connecter à Bob en lui montrant un QR code.

### Acteurs
*   **Utilisateur A (Alice)** : Affiche le QR code.
*   **Utilisateur B (Bob)** : Scanne le QR code.
*   **Serveur** : Notre backend Spring Boot.

---

### 🔄 Le Workflow Détaillé en 4 Étapes

#### Étape 1️⃣ : Alice initie et affiche le QR Code

1.  **Action Utilisateur (Alice)** : Appuie sur "Se connecter à un nouvel appareil".
2.  **App d'Alice** :
    *   Génère `publicKeyA` et un `relationCodeA` sécurisé (une longue chaîne de caractères aléatoires, par exemple un **UUID**).
    *   Appelle `POST /pairing` pour enregistrer le pairing sur le serveur.
    *   Après confirmation (`200 OK`), l'app génère un **QR code contenant uniquement le `relationCodeA`**.
    *   L'app affiche le QR code et commence à **interroger le serveur toutes les 2-3 secondes** pour savoir si le match a été fait. C'est ce qu'on appelle le "polling".

**Visuellement :**
```
Alice App                      Serveur
    |                              |
    |  1. POST /pairing            |
    |  (relationCodeA, publicKeyA) |
    |----------------------------->|
    |                              | [Stocke le pairing, statut="waiting"]
    |  200 OK                      |
    |<-----------------------------|
    |                              |
    | [Affiche QR(relationCodeA)]  |
    | [Commence le polling...]     |
    |                              |
    |  2. GET /pairing/{id}/status |
    |----------------------------->|
    |                              | "waiting"
    |<-----------------------------|
```

---

#### Étape 2️⃣ : Bob scanne, matche et commence le polling

1.  **Action Utilisateur (Bob)** : Choisit "Scanner un QR code" et vise l'écran d'Alice.
2.  **App de Bob** :
    *   Lit le `relationCodeA` depuis le QR code.
    *   Génère `publicKeyB` et un `relationCodeB` sécurisé (par exemple, un autre **UUID**).
    *   Appelle `PUT /pairing` avec les trois informations.
3.  **Serveur** :
    *   Trouve le pairing, le complète avec les infos de Bob, **reset le timer** et passe le statut à `"completed"`.
    *   Répond à Bob avec les infos d'Alice (`publicKeyA`, `relationCodeA`).
4.  **App de Bob** :
    *   Reçoit les infos d'Alice. **Le pairing est à moitié terminé pour Bob.**
    *   L'app de Bob commence à son tour un **polling** sur `GET /pairing/{id}/status` pour s'assurer qu'Alice a bien reçu ses informations.

**Visuellement :**
```
Bob App                        Serveur
    |                              |
    |  1. Scan QR -> relationCodeA |
    |                              |
    |  2. PUT /pairing             |
    |  (relationCodeA,             |
    |   relationCodeB, publicKeyB) |
    |<-----------------------------|
    |                              | [Statut="completed", Reset timer]
    |  3. 200 OK                   |
    |  (relationCodeA, publicKeyA) |
    |----------------------------->|
    |                              |
    | [Stocke infos d'Alice]       |
    | [Commence son propre polling]|
```

---

#### Étape 3️⃣ : L'app d'Alice détecte le match et finalise

1.  **App d'Alice (Polling)** :
    *   L'appel à `GET /pairing/{relationCodeA}/status` renvoie maintenant `"completed"`.
    *   L'app sait que Bob a scanné. Elle arrête le polling.
2.  **App d'Alice (Finalisation)** :
    *   Immédiatement, l'app appelle `DELETE /pairing` avec son `relationCodeA`.
3.  **Serveur** :
    *   Vérifie que le pairing est bien complet.
    *   Répond à Alice avec les infos de Bob (`publicKeyB`, `relationCodeB`).
    *   **Met à jour le statut du pairing à `"finalized"`**. Le pairing n'est pas supprimé pour que Bob puisse vérifier.

**Visuellement :**
```
Alice App                      Serveur
    |                              |
    |  1. GET /pairing/{id}/status |
    |----------------------------->|
    |                              | "completed"
    |<-----------------------------|
    |                              |
    | [Arrête le polling]          |
    |                              |
    |  2. DELETE /pairing          |
    |----------------------------->|
    |                              | [Statut="finalized"]
    |  3. 200 OK                   |
    |  (relationCodeB, publicKeyB) |
    |<-----------------------------|
    |                              |
    | [Stocke infos de Bob]        |
```

---

#### Étape 4️⃣ : L'app de Bob détecte la finalisation

1.  **App de Bob (Polling)** :
    *   L'application de Bob continuait son polling.
    *   L'appel à `GET /pairing/{relationCodeA}/status` renvoie maintenant `"finalized"`.
    *   L'app de Bob sait qu'Alice a bien reçu ses informations. Elle peut arrêter le polling.

**Visuellement :**
```
Bob App                        Serveur
    |                              |
    |  1. GET /pairing/{id}/status |
    |----------------------------->|
    |                              | "finalized"
    |<-----------------------------|
    |                              |
    | [Arrête le polling]          |
    | [Connexion 100% établie]     |
```

### 🎉 Résultat Final

À la fin de ce processus, les deux applications ont la certitude que l'échange de clés a réussi dans les deux sens. Le pairing restera sur le serveur jusqu'à son expiration naturelle (2 minutes après le match), garantissant qu'il n'y a plus de trace de l'échange.

---

## 🧪 Tester avec Postman

### Collection de Tests

#### 1. Init
```
POST http://localhost:8080/pairing
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "relationCode": "ALICE123",
  "userPublicKey": "pk_alice_xyz"
}
```

#### 2. Get Status (Waiting)
```
GET http://localhost:8080/pairing/ALICE123/status
```
*Réponse attendue :* `{ "status": "waiting" }`

#### 3. Match
```
PUT http://localhost:8080/pairing
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "relationCodeA": "ALICE123",
  "relationCodeB": "BOB456",
  "publicKeyB": "pk_bob_abc"
}
```

#### 4. Get Status (Completed)
```
GET http://localhost:8080/pairing/ALICE123/status
```
*Réponse attendue :* `{ "status": "completed" }`

#### 5. Finalize
```
DELETE http://localhost:8080/pairing?relationCodeA=ALICE123
```

#### 6. Get Status (Finalized)
```
GET http://localhost:8080/pairing/ALICE123/status
```
*Réponse attendue :* `{ "status": "finalized" }`

