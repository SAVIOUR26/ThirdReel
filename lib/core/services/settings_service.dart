import 'package:shared_preferences/shared_preferences.dart';

/// Trades file size against quality for the merged MP4. Maps to FFmpeg's
/// `-q:v` scale (mpeg4 encoder): lower numbers mean higher quality.
enum VideoQuality {
  standard(qValue: 5, label: 'Standard', description: 'Smaller file'),
  high(qValue: 2, label: 'High', description: 'Larger file, sharper video');

  const VideoQuality({
    required this.qValue,
    required this.label,
    required this.description,
  });

  final int qValue;
  final String label;
  final String description;
}

/// Persists user preferences — currently just video quality — via
/// shared_preferences. Backs the Settings screen reachable from the gear
/// icon on the merge screen.
class SettingsService {
  static const _qualityKey = 'video_quality';

  Future<VideoQuality> getVideoQuality() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_qualityKey);
    return VideoQuality.values.firstWhere(
      (q) => q.name == name,
      orElse: () => VideoQuality.standard,
    );
  }

  Future<void> setVideoQuality(VideoQuality quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_qualityKey, quality.name);
  }
}
