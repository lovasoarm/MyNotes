# MyNotes - Application de Prise de Notes

Une application complète de prise de notes développée avec **Flutter** (frontend) et **Node.js/GraphQL** (backend dockerisé), intégrée avec **Firebase** pour la synchronisation cloud.

## Démonstration

### Écran de connexion
![Login](frontend_mobile/docs/images/login.png)

### Écran d'inscription
![Register](frontend_mobile/docs/images/register.png)

### Écran d'accueil (vide)
![Home](frontend_mobile/docs/images/home.png)

### Écran d'accueil avec notes
![Homewithnotes](frontend_mobile/docs/images/homewithnotes.png)


## Fonctionnalités

-  **Authentification complète** (inscription, connexion (possible avec google), déconnexion)
-  **CRUD complet des notes** (créer, lire, modifier, supprimer)
-  **Recherche et filtrage** des notes par date
-  **Synchronisation Firebase** automatique et intelligente
-  **Interface responsive** avec animations simples mais fluides
-  **Support multi-plateforme** (Web, Android, iOS, Windows)
-  **Architecture KISS** (Keep It Simple, Stupid) pour la maintenance

##  Architecture du Projet

```
my-notes/
├── frontend_mobile/          # Application Flutter
│   ├── lib/
│   │   ├── app/              # Configuration de l'app
│   │   ├── core/             # Services et configuration
│   │   │   ├── config/       # Configuration GraphQL
│   │   │   ├── constants/    # Couleurs et polices
│   │   │   ├── graphql/      # Requêtes GraphQL
│   │   │   └── services/     # Services (Firebase, Storage, Sync)
│   │   ├── models/           # Modèles de données
│   │   │   ├── auth/         # Modèles d'authentification
│   │   │   └── notes/        # Modèles de notes
│   │   ├── presentation/     # Interface utilisateur
│   │   │   ├── auth/         # Écrans d'authentification
│   │   │   ├── home/         # Écrans principaux
│   │   │   └── widgets/      # Widgets réutilisables
│   │   ├── state_management/ # Gestion d'état (Provider)
│   │   └── view_models/      # Logique métier
│   ├── android/              # Configuration Android
│   ├── web/                  # Configuration Web
│   └── firebase_options.dart # Configuration Firebase
└── backend/  
    │
    ├── prisma/Schema.prisma
    │    # Fichier de configuration principal de Prisma ORM. Définit les modèles de données  
    │    et la connexion à la base de données.  
    │
    ├── src/auth/ 
    │    # Dossier contenant la logique d'authentification et de gestion des utilisateurs.  
    │    │  
    │    ├── Cors
    │    │    # Configuration des règles CORS pour les requêtes cross-origin.  
    │    │  
    │    ├── notes 
    │    │    # Fonctionnalités liées aux notes (CRUD, relations avec les utilisateurs).  
    │    │  
    │    ├── prisma  
    │    │    # Interactions spécifiques avec la base de données via Prisma Client.  
    │    │  
    │    └── users  
    │         # Gestion des utilisateurs (inscription, connexion, profils).  
    │
    ├── Schema.gql
    │    # Schéma GraphQL définissant les types, requêtes et mutations de l'API.  
    │
    ├── Dockerfile  
    │    # Instructions pour conteneuriser l'application backend (ex : installation des  
    │    dépendances, build, commande de démarrage).  
    │
    └── docker-compose.yml  
        # Configuration des services (backend, base de données, etc.) pour lancer  
        l'environnement avec Docker. Définit les ports, volumes et dépendances.  
    ```


````
##  Technologies Utilisées

### Frontend (Flutter)
- **Flutter 3.x** - Framework UI multi-plateforme
- **Provider** - Gestion d'état simple et efficace
- **GraphQL Flutter** - Client GraphQL pour les API
- **Firebase Core/Firestore** - Synchronisation cloud
- **Shared Preferences** - Stockage local

### Backend (Node.js)
- **Node.js 18+** - Runtime JavaScript
- **Apollo Server** - Serveur GraphQL
- **Prisma** - ORM
- **PostgreSQL** - Base de données relationnelle
- **JWT** - Authentification par tokens
- **bcryptjs** - Hachage des mots de passe

### Cloud & DevOps
- **Firebase** - Base de données temps réel et authentification
- **Firestore** - Base de données NoSQL pour la synchronisation
- **Git** - Contrôle de version

##  Installation et Configuration

### Prérequis

- **Flutter SDK 3.0+** : [Installation Flutter](https://docs.flutter.dev/get-started/install)
- **Node.js 18+** : [Installation Node.js](https://nodejs.org/)
- **Git** : [Installation Git](https://git-scm.com/downloads)

### 1. Configuration Backend

#### Installation des dépendances
```bash
cd backend
npm install
```

#### Configuration de la base de données
```bash
# Créer la base de données PostgreSQL
createdb mynotes_db

# Configurer les variables d'environnement
cp .env.example .env

# Éditer .env avec vos paramètres :
DATABASE_URL=postgresql://username:password@localhost:5432/notesapp
JWT_SECRET=votre_secret_jwt_super_secure
PORT=3000
```

#### Migrations de la base de données
```bash
# Exécuter les migrations
npm run migrate

# (Optionnel) Ajouter des données de test
npm run seed
```

#### Démarrage du serveur
```bash
# Mode développement
npm run dev

# Mode production
npm start
```

Le serveur GraphQL sera accessible sur `http://localhost:3000/graphql`

### 2. Configuration Frontend

#### Installation des dépendances Flutter
```bash
cd frontend_mobile
flutter pub get
```

#### Configuration Firebase

1. **Créer un projet Firebase** :
   - Aller sur [Firebase Console](https://console.firebase.google.com/)
   - Créer un nouveau projet `mynotes-8d8e9`
   - Activer **Firestore** et **Authentication**

2. **Télécharger la configuration** :
   - Ajouter une app Web au projet Firebase
   - Ajouter une app Android au projet Firebase
   - Télécharger `google-services.json` dans `android/app/`

3. **Configuration déjà incluse** :
   -  `firebase_options.dart` - Configuration multi-plateformes
   -  `main.dart` - Initialisation Firebase
   -   Services de synchronisation configurés

#### Configuration GraphQL
Éditer `lib/core/config/graphql_config.dart` si nécessaire :
```dart
static const String uri = 'http://localhost:3000/graphql'; // Backend local
// ou
static const String uri = 'https://notesapp.herokuapp.com/graphql'; // Production
```

### 3. Lancement de l'Application

#### Vérifier les devices disponibles
```bash
flutter devices
```

#### Lancer sur Web (Recommandé pour développement)
```bash
flutter run -d edge
# ou
flutter run -d chrome
```

#### Lancer sur Android
```bash
flutter run -d android
```

#### Lancer sur Windows Desktop
```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

##  Configuration Firebase en Détail

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Rules pour les notes
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.authorId;
    }
    
    // Rules pour les utilisateurs
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

##  Structure de la Base de Données

### PostgreSQL (Backend)
```sql
-- Table users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table notes
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    author_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Firestore (Synchronisation)
```javascript
// Collection: users
{
  id: number,
  email: string,
  createdAt: timestamp,
  lastSyncAt: timestamp
}

// Collection: notes
{
  id: string,
  title: string,
  content: string,
  authorId: number,
  authorEmail: string,
  createdAt: timestamp,
  updatedAt: timestamp,
  lastSyncAt: timestamp
}
```

##  Scripts et Commandes Utiles

### Backend
```bash
# Démarrage
pnpm run dev              # Mode développement avec nodemon
pnpm start               # Mode production
pnpm run migrate         # Exécuter migrations
pnpm run migrate:undo    # Annuler dernière migration
# ou Démarrer juste Docker

### Frontend
```bash
# Développement
flutter run -d web          # Lancer sur web
flutter run -d android      # Lancer sur Android
flutter hot-reload          # Rechargement à chaud (r dans le terminal)
flutter hot-restart         # Redémarrage à chaud (R dans le terminal)

# Build et déploiement
flutter build web           # Build pour web
flutter build apk           # Build APK Android
flutter build windows       # Build Windows

# Maintenance
flutter clean              # Nettoyer le projet
flutter pub get            # Installer dépendances
flutter analyze            # Analyser le code
```

## Personnalisation

### Thème et Couleurs
Modifier `lib/core/constants/colors.dart` :
```dart
class AppColors {
  static const Color primary = Color(0xFF6C63FF);      // Violet principal
  static const Color secondary = Color(0xFF4CAF50);    // Vert secondaire
  static const Color background = Color(0xFFF5F5F5);   // Gris clair
  static const Color delete = Color(0xFFE57373);       // Rouge suppression
}
```

### Polices
Modifier `lib/core/constants/fonts.dart` et `pubspec.yaml`

### Animations
Utiliser `lib/presentation/widgets/animation_widget.dart` :
```dart
// Animations disponibles et simples
AnimationWidget.fadeIn(child: widget)
AnimationWidget.slideFromLeft(child: widget)
AnimationWidget.scaleWithBounce(child: widget)
AnimationWidget.listItemAnimation(index: index, child: widget)
```

## Dépannage

### Problèmes Courants

#### 1. Erreur Firebase "FirebaseOptions cannot be null"
**Solution** : Vérifier que `firebase_options.dart` est bien configuré et que Firebase est initialisé dans `main.dart`

#### 2. Erreur PostgreSQL "database does not exist"
**Solution** : 
```bash
createdb mynotes_db
```

#### 3. Erreur GraphQL "Network Error"
**Solution** : Vérifier que le backend est démarré et accessible sur le bon port

#### 4. Erreur Flutter "packages get failed"
**Solution** :
```bash
flutter clean
flutter pub get
```

#### 5. Erreur Firestore "requires an index"
**Solution** : Cliquer sur le lien dans l'erreur pour créer l'index automatiquement

### Logs et Debug

#### Backend
```bash
# Logs en temps réel
npm run dev

# Debug mode
DEBUG=* npm run dev
```

#### Frontend
```bash
# Mode debug avec logs
flutter run -d web --debug

# Analyser les performances
flutter run --profile
```

### Frontend Mobile (Stores)
```bash
# Android Play Store
flutter build appbundle

# iOS App Store
flutter build ios
```

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Conventions de Code

- **Frontend** : Suivre les [Dart Style Guidelines](https://dart.dev/guides/language/effective-dart/style)
- **Backend** : Suivre les [JavaScript Standard Style](https://standardjs.com/)
- **Commits** : Utiliser [Conventional Commits](https://www.conventionalcommits.org/)

##  TODO / Roadmap

- [ ] **Push Notifications** pour les rappels
- [ ] **Mode hors ligne** complet
- [ ] **Partage de notes** entre utilisateurs
- [ ] **Catégories et tags** pour organiser les notes
- [ ] **Export PDF/Word** des notes
- [ ] **Mode sombre** complet
- [ ] **Recherche avancée** avec filtres
- [ ] **Sauvegarde automatique** en temps réel
- [ ] **API REST** en complément de GraphQL
- [ ] **Tests automatisés** (unit + integration)


## Auteurs

- Lovasoa RM - Développement mobile - [GitHub](https://github.com/lovasoarm)

##  Remerciements

- [Flutter Team](https://flutter.dev/) pour le framework mobile
- [Apollo GraphQL](https://www.apollographql.com/) pour les outils GraphQL
- [Firebase](https://firebase.google.com/) pour les services cloud
- [Node.js Community](https://nodejs.org/) pour l'écosystème backend
- [youtube](https://youtube.com/) pour les tutoriels

---

**MyNotes** - Une application moderne de prise de notes avec synchronisation cloud
