import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _prefix = 'quickplay_';

  // High score keys
  static const _perfectHitHighScore = '${_prefix}perfect_hit_high_score';
  static const _brainHighScore = '${_prefix}brain_high_score';
  static const _dodgeHighScore = '${_prefix}dodge_high_score';

  // Stats keys
  static const _totalGamesPlayed = '${_prefix}total_games_played';
  static const _totalScore = '${_prefix}total_score';
  static const _playerName = '${_prefix}player_name';
  static const _soundEnabled = '${_prefix}sound_enabled';
  static const _hapticsEnabled = '${_prefix}haptics_enabled';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // High scores
  int getPerfectHitHighScore() => _prefs.getInt(_perfectHitHighScore) ?? 0;
  int getBrainHighScore() => _prefs.getInt(_brainHighScore) ?? 0;
  int getDodgeHighScore() => _prefs.getInt(_dodgeHighScore) ?? 0;

  Future<bool> setPerfectHitHighScore(int score) async {
    final current = getPerfectHitHighScore();
    if (score > current) {
      await _prefs.setInt(_perfectHitHighScore, score);
      return true;
    }
    return false;
  }

  Future<bool> setBrainHighScore(int score) async {
    final current = getBrainHighScore();
    if (score > current) {
      await _prefs.setInt(_brainHighScore, score);
      return true;
    }
    return false;
  }

  Future<bool> setDodgeHighScore(int score) async {
    final current = getDodgeHighScore();
    if (score > current) {
      await _prefs.setInt(_dodgeHighScore, score);
      return true;
    }
    return false;
  }

  // Generic per-game high scores (used by new games)
  int getHighScore(String gameId) => _prefs.getInt('${_prefix}hs_$gameId') ?? 0;

  Future<bool> setHighScore(String gameId, int score) async {
    final current = getHighScore(gameId);
    if (score > current) {
      await _prefs.setInt('${_prefix}hs_$gameId', score);
      return true;
    }
    return false;
  }

  // Stats
  int getTotalGamesPlayed() => _prefs.getInt(_totalGamesPlayed) ?? 0;
  int getTotalScore() => _prefs.getInt(_totalScore) ?? 0;

  Future<void> incrementGamesPlayed() async {
    await _prefs.setInt(_totalGamesPlayed, getTotalGamesPlayed() + 1);
  }

  Future<void> addToTotalScore(int score) async {
    await _prefs.setInt(_totalScore, getTotalScore() + score);
  }

  // Player
  String getPlayerName() => _prefs.getString(_playerName) ?? 'Player';
  Future<void> setPlayerName(String name) async {
    await _prefs.setString(_playerName, name);
  }

  // Settings
  bool isSoundEnabled() => _prefs.getBool(_soundEnabled) ?? true;
  bool isHapticsEnabled() => _prefs.getBool(_hapticsEnabled) ?? true;

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabled, enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(_hapticsEnabled, enabled);
  }
}
