// Convertit un nombre d'octets en texte lisible (Ko, Mo, Go)
String formatBytes(int bytes) {
  if (bytes <= 0) return "0 Mo";
  if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} Ko";
  if (bytes < 1024 * 1024 * 1024) {
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo";
  }
  return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} Go";
}
