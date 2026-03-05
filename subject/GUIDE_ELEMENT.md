# Guide Étudiant : Échange d'Informations Sécurisé Post-Appairage

Ce document explique comment deux utilisateurs, Alice et Bob, peuvent s'échanger des informations de manière sécurisée après avoir établi une connexion sécurisée (un "pairing").

## Contexte

Ce guide suppose que vous avez déjà suivi la procédure d'appairage décrite dans `GUIDE_PAIRING.md`. Grâce à cette étape, Alice et Bob partagent désormais un secret commun : le `relationCode`. Ce code leur permet de communiquer de manière sécurisée via notre service, qui agit comme une "boîte aux lettres" numérique éphémère.

Le principe est le suivant :
1.  Alice dépose un message dans une "boîte" (le service) en utilisant le `relationCode` comme clé.
2.  Bob utilise le même `relationCode` pour ouvrir la boîte et récupérer le message.
3.  Une fois le message récupéré, la boîte est immédiatement détruite pour garantir la confidentialité.

## Le Flux d'Échange d'Information

L'information est structurée sous la forme d'un `Element`, qui contient une `key` et une `value`.

*   **`key`** : Représente le **type** d'information échangée. C'est une chaîne de caractères qui donne un contexte à la donnée (par exemple : `MESSAGE`, `COULEUR`, `ICONE`, `GPS LOCALISATION`, etc.).
*   **`value`** : La donnée elle-même, chiffrée avec la clé privée de l'expéditeur. Elle ne pourra être déchiffrée que par le destinataire à l'aide de la clé publique de l'expéditeur, qui a été échangée lors de l'étape de pairing.

### Étape 1 : Alice (l'émetteur) dépose l'information

Alice veut envoyer une information à Bob (par exemple, un message texte).

1.  **Elle chiffre le message** avec sa propre clé privée.
2.  **Elle utilise le `relationCode`** qu'elle partage déjà avec Bob.
3.  **Elle envoie l'information au service.** Pour cela, elle fait un appel `POST` sur l'endpoint `/element` avec les données suivantes :
    *   `relationCode` : Le code secret partagé.
    *   `key` : `"MESSAGE"` (pour indiquer que c'est un message texte).
    *   `value` : `"<chaîne de caractères chiffrés>"`.

Le service stocke alors cet `Element` en l'associant au `relationCode`.

### Étape 2 : Bob (le récepteur) récupère l'information

Bob s'attend à recevoir une information de la part d'Alice.

1.  **Il interroge le service** en utilisant le même `relationCode`. Il fait un appel `GET` sur l'endpoint `/element` en passant le `relationCode` en paramètre.
2.  **Le service vérifie le `relationCode` :**
    *   S'il correspond à une information stockée, le service renvoie l'information (`key: "MESSAGE"`, `value: "<chaîne de caractères chiffrés>"`) à Bob.
    *   **Très important :** Immédiatement après avoir envoyé l'information, le service la **supprime définitivement**.
3.  **Bob déchiffre l'information.** Il utilise la clé publique d'Alice (qu'il a obtenue lors du pairing) pour déchiffrer la `value` et lire le message original : `"Bonjour Bob !"`.

### Pourquoi ce mécanisme est-il sécurisé ?

*   **Chiffrement de bout-en-bout** : Même si le service ou la communication avec le service était compromise, la `value` reste illisible sans la clé de déchiffrement. Seul Bob peut lire le message d'Alice.
*   **Secret Partagé** : Seuls Alice et Bob connaissent le `relationCode`. Sans lui, personne ne peut accéder à l'information. Le canal est déjà établi.
*   **Usage unique (Read-Once)** : L'information est détruite après la première lecture. Si Bob récupère le message, un attaquant qui obtiendrait le `relationCode` plus tard ne trouverait plus rien. Cela protège contre les accès futurs et permet de détecter une anomalie (si Bob ne trouve rien, c'est peut-être qu'un attaquant a déjà intercepté le message).
*   **Découplage** : L'information transite par un intermédiaire (notre service). Alice et Bob n'ont pas besoin d'être connectés en même temps pour que l'échange fonctionne.

### Limites et Points de Vigilance

La sécurité de ce système repose sur la robustesse de l'étape d'appairage initiale.
1.  **Le `relationCode` doit avoir été généré et échangé de manière sécurisée** lors de la phase de pairing.
