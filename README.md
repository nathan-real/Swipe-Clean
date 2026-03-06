# Swipe Clean

Une application Flutter intuitive permettant de trier, nettoyer et organiser la galerie photo de son téléphone grâce à un système de balayage (swipe) fluide.

## Fonctionnalités
* **Tri rapide** : Swipe à gauche pour jeter, swipe à droite pour garder.
* **Corbeille sécurisée** : Les photos rejetées sont stockées dans une liste avant toute suppression définitive.
* **Mémoire locale** : L'application sauvegarde automatiquement l'état de votre tri et le contenu de votre corbeille, même après fermeture.
* **Interface fluide** : Animations personnalisées et retour visuel (couleurs dynamiques selon la direction du swipe).

---

## Prérequis

Pour compiler et lancer ce projet sur votre machine, vous devez installer :
* Le [SDK Flutter](https://docs.flutter.dev/get-started/install) (version stable recommandée).
* **Android Studio** (pour émuler ou compiler sur Android).
* Un appareil physique connecté via USB/Wi-Fi (fortement recommandé pour tester la galerie photo) ou un émulateur.

---

## Installation et Lancement

### 1. Récupérer le projet
Ouvrez votre terminal et clonez le dépôt :
```bash
git clone https://github.com/nathan-real/Swipe-Clean
cd swipe_clean
```

### 2. Installer les dépendances
Téléchargez les paquets requis pour le fonctionnement de l'application (comme photo_manager ou shared_preferences) en exécutant :

```bash
flutter pub get
```
⚠️ Note importante pour les utilisateurs Windows :
Ce projet utilise des dépendances qui nécessitent la création de "liens symboliques". Pour que l'installation réussisse, vous devez activer le Mode développeur dans les paramètres de Windows.
Astuce : tapez start ms-settings:developers dans votre terminal pour y accéder directement et cochez la case "Mode développeur".

### 3. Lancer l'application
Assurez-vous qu'un téléphone Android est branché à votre ordinateur (avec le débogage USB activé) ou lancez un émulateur depuis Android Studio, puis exécutez :

```bash
flutter run
```

---

### Permissions requises
L'application doit lire les médias locaux pour fonctionner. Les accès sont déjà pré-configurés dans le code source :

Android (dans android/app/src/main/AndroidManifest.xml) : Requiert les permissions READ_EXTERNAL_STORAGE, READ_MEDIA_IMAGES et READ_MEDIA_VIDEO.