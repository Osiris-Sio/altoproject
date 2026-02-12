# 🎨 Widgets Alto - Guide d'utilisation

## Widgets réutilisables disponibles

La feature Add inclut plusieurs widgets réutilisables dans `lib/features/add/widgets/alto_widgets.dart`.

## 📝 AltoTextField

Champ de texte stylisé avec le design Alto.

### Utilisation basique
```dart
import 'package:altoproject/features/add/widgets/alto_widgets.dart';

final controller = TextEditingController();

AltoTextField(
  controller: controller,
  labelText: "Prénom",
  hintText: "Entrez votre prénom",
  prefixIcon: Icons.person_outline,
)
```

### Avec validation
```dart
AltoTextField(
  controller: controller,
  labelText: "Email",
  hintText: "votre@email.com",
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (!value.contains('@')) {
      return 'Email invalide';
    }
    return null;
  },
)
```

### Champ mot de passe
```dart
AltoTextField(
  controller: controller,
  labelText: "Mot de passe",
  obscureText: true,
  prefixIcon: Icons.lock_outline,
  validator: (value) {
    if (value == null || value.length < 8) {
      return 'Minimum 8 caractères';
    }
    return null;
  },
)
```

### Propriétés disponibles
- `controller` : TextEditingController (requis)
- `labelText` : Label du champ (requis)
- `hintText` : Texte d'indication
- `prefixIcon` : Icône à gauche
- `validator` : Fonction de validation
- `enabled` : Active/désactive le champ
- `textCapitalization` : Capitalisation automatique
- `keyboardType` : Type de clavier
- `obscureText` : Masquer le texte (mot de passe)
- `maxLines` : Nombre de lignes max

## 🔘 AltoButton

Bouton stylisé avec le design Alto.

### Utilisation basique
```dart
AltoButton(
  text: "Valider",
  onPressed: () {
    print("Bouton cliqué");
  },
)
```

### Avec icône
```dart
AltoButton(
  text: "Continuer",
  icon: Icons.arrow_forward,
  onPressed: () {
    // Action
  },
)
```

### Avec état de chargement
```dart
AltoButton(
  text: "Créer mon compte",
  isLoading: isLoading,
  onPressed: () async {
    setState(() => isLoading = true);
    await createAccount();
    setState(() => isLoading = false);
  },
)
```

### Couleurs personnalisées
```dart
AltoButton(
  text: "Supprimer",
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
  icon: Icons.delete,
  onPressed: () {
    // Action de suppression
  },
)
```

### Propriétés disponibles
- `text` : Texte du bouton (requis)
- `onPressed` : Callback au clic
- `isLoading` : Affiche un loader
- `backgroundColor` : Couleur de fond
- `foregroundColor` : Couleur du texte
- `icon` : Icône à afficher

## 🏷️ AltoLogo

Logo Alto avec slogan.

### Utilisation basique
```dart
AltoLogo()
```

### Taille personnalisée
```dart
AltoLogo(fontSize: 80)  // Logo plus grand
AltoLogo(fontSize: 32)  // Logo plus petit
```

### Couleur personnalisée
```dart
AltoLogo(
  fontSize: 56,
  color: Colors.blue,
)
```

### Propriétés disponibles
- `fontSize` : Taille du texte ALTO (défaut: 56)
- `color` : Couleur du logo (défaut: deepPurple)

## ⚠️ AltoErrorMessage

Message d'erreur stylisé.

### Utilisation basique
```dart
if (errorMessage != null)
  AltoErrorMessage(
    message: errorMessage!,
  )
```

### Avec bouton de fermeture
```dart
AltoErrorMessage(
  message: "Une erreur est survenue",
  onDismiss: () {
    setState(() => errorMessage = null);
  },
)
```

### Propriétés disponibles
- `message` : Message d'erreur (requis)
- `onDismiss` : Callback pour fermer le message

## ℹ️ AltoInfoMessage

Message d'information stylisé.

### Message de sécurité
```dart
AltoInfoMessage(
  message: "Vos données sont chiffrées de bout en bout",
  icon: Icons.lock_outline,
)
```

### Message de succès
```dart
AltoInfoMessage(
  message: "Compte créé avec succès !",
  icon: Icons.check_circle_outline,
  color: Colors.green.shade700,
)
```

### Message d'avertissement
```dart
AltoInfoMessage(
  message: "Cette action est irréversible",
  icon: Icons.warning_outlined,
  color: Colors.orange.shade700,
)
```

### Propriétés disponibles
- `message` : Message à afficher (requis)
- `icon` : Icône (défaut: info_outline)
- `color` : Couleur (défaut: blue)

## 📋 Exemple complet

Voici un exemple complet d'utilisation de tous les widgets :

```dart
import 'package:flutter/material.dart';
import 'package:altoproject/features/add/widgets/alto_widgets.dart';

class ExampleScreen extends StatefulWidget {
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Votre logique ici
      await Future.delayed(Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Succès !')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AltoLogo(),
                SizedBox(height: 60),

                // Champ prénom
                AltoTextField(
                  controller: _nameController,
                  labelText: "Prénom",
                  hintText: "Entrez votre prénom",
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Prénom requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Champ email
                AltoTextField(
                  controller: _emailController,
                  labelText: "Email",
                  hintText: "votre@email.com",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Message d'erreur
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AltoErrorMessage(
                      message: _errorMessage!,
                      onDismiss: () => setState(() => _errorMessage = null),
                    ),
                  ),

                // Bouton
                AltoButton(
                  text: "Valider",
                  icon: Icons.check,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                SizedBox(height: 16),

                // Message info
                AltoInfoMessage(
                  message: "Vos données sont protégées",
                  icon: Icons.lock_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 🎨 Personnalisation

Tous les widgets utilisent les couleurs et styles cohérents :
- **Couleur principale** : Deep Purple
- **Border radius** : 12px
- **Padding** : 16px vertical pour les boutons
- **Font weight** : 600 pour les boutons

Vous pouvez les personnaliser en modifiant directement les widgets ou en créant des variantes.

## ✨ Bonnes pratiques

1. **Réutilisez ces widgets** plutôt que de recréer des TextField/Button personnalisés
2. **Validez toujours** les entrées utilisateur
3. **Gérez les états de chargement** pour une meilleure UX
4. **Affichez les erreurs** de manière claire et visible
5. **Donnez du feedback** à l'utilisateur (SnackBar, messages)

## 🚀 Extension

Pour créer de nouveaux widgets réutilisables, ajoutez-les dans le même fichier `alto_widgets.dart` en respectant le pattern existant.

