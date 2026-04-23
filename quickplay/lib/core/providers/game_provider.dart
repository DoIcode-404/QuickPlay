import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  final StorageService _storage;

  GameProvider(this._storage);

  // Generic high score (works for all 15 games)
  int getHighScore(String gameId) => _storage.getHighScore(gameId);

  // Legacy getters (kept for existing widgets)
  int get perfectHitHighScore => _storage.getPerfectHitHighScore();
  int get brainHighScore => _storage.getBrainHighScore();
  int get dodgeHighScore => _storage.getDodgeHighScore();

  // Stats
  int get totalGamesPlayed => _storage.getTotalGamesPlayed();
  int get totalScore => _storage.getTotalScore();
  String get playerName => _storage.getPlayerName();

  // Settings
  bool get soundEnabled => _storage.isSoundEnabled();
  bool get hapticsEnabled => _storage.isHapticsEnabled();

  // XP / Level
  int get xp => totalScore;
  int get level => (xp / 1000).floor() + 1;
  double get levelProgress => (xp % 1000) / 1000;

  /// Submit a game score (generic — works for all 15 games).
  Future<bool> submitScore(String gameName, int score) async {
    // Use generic storage
    final isNewHighScore = await _storage.setHighScore(
      _gameNameToId(gameName),
      score,
    );

    // Also update legacy keys for the original 3
    switch (gameName) {
      case 'Perfect Hit':
        await _storage.setPerfectHitHighScore(score);
        break;
      case '5-Second Brain':
        await _storage.setBrainHighScore(score);
        break;
      case 'Dodge Drop':
        await _storage.setDodgeHighScore(score);
        break;
    }

    await _storage.incrementGamesPlayed();
    await _storage.addToTotalScore(score);
    notifyListeners();
    return isNewHighScore;
  }

  String _gameNameToId(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  // Settings
  Future<void> toggleSound() async {
    await _storage.setSoundEnabled(!soundEnabled);
    notifyListeners();
  }

  Future<void> toggleHaptics() async {
    await _storage.setHapticsEnabled(!hapticsEnabled);
    notifyListeners();
  }

  Future<void> updatePlayerName(String name) async {
    await _storage.setPlayerName(name);
    notifyListeners();
  }
}
