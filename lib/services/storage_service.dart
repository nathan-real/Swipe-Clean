import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Fonction pour enregistrer la liste des photos dans la corbeille
  Future<void> saveTrashList(List<String> photoIds) async {
    final prefs = await SharedPreferences.getInstance();
    // On enregistre une liste de textes
    await prefs.setStringList('trash_photos', photoIds);
  }

  // Fonction pour récuperer la liste des photos dans la corbeille
  Future<List<String>> getTrashList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('trash_photos') ?? [];
  }

  // Fonction pour save le mode de tri
  Future<void> saveSortMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortMode', mode);
  }

  // Récupérer le mode de tri
  Future<String> getSortMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sortMode') ?? 'chronological';
  }

  // Récupère la liste des IDs déjà triés
  Future<Set<String>> getProcessedPhotoIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? ids = prefs.getStringList('processed_photos_ids');
    return ids?.toSet() ?? {};
  }

  // Ajoute un ID à la liste des photos triées
  Future<void> savePhotoAsProcessed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> ids = (prefs.getStringList('processed_photos_ids') ?? [])
        .toSet();

    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList('processed_photos_ids', ids.toList());
    }
  }

  // Supprime les IDs d'une liste spécifique
Future<void> resetProcessedPhotos(List<String> idsToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    // On récupère la liste actuelle
    List<String> currentList =
        prefs.getStringList('processed_photos_ids') ?? [];

    // On retire les IDs du dossier
    currentList.removeWhere((id) => idsToRemove.contains(id));

    // On sauvegarde la nouvelle liste
    await prefs.setStringList('processed_photos_ids', currentList);
  }

  // Sauvegarder l'état de la vibration
  Future<void> setVibrationEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', isEnabled);
  }

  // Récupérer l'état de la vibration (true par défaut)
  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibration_enabled') ?? true;
  }

  // Ajouter des octets à l'espace total libéré
  Future<void> addSavedSpace(int bytesToAdd) async {
    final prefs = await SharedPreferences.getInstance();
    int currentSpace = prefs.getInt('saved_space_bytes') ?? 0;
    await prefs.setInt('saved_space_bytes', currentSpace + bytesToAdd);
  }

  // Récupérer l'espace total libéré
  Future<int> getSavedSpace() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('saved_space_bytes') ?? 0;
  }
}
