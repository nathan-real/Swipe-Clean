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
}
