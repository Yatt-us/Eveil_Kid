/// Formate un nombre de secondes en chaîne lisible (mm:ss ou hh:mm:ss).
/// Utilisé partout où la durée provient du provider Cloudinary.
String formatDurationSeconds(double seconds) {
  if (seconds <= 0) return '00:00';
  final total = seconds.round();
  final heures = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final secs = total % 60;
  if (heures > 0) {
    return '${heures.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
