class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'QuickPlay';
  static const String appTagline = 'Fast mini challenges. Anytime.';

  // Game names
  static const String perfectHit = 'Perfect Hit';
  static const String fiveSecondBrain = '5-Second Brain';
  static const String dodgeDrop = 'Dodge Drop';

  // Game descriptions
  static const String perfectHitDesc =
      'Tap at the perfect moment when the indicator hits the target zone.';
  static const String fiveSecondBrainDesc =
      'Solve rapid-fire math equations before the 5-second timer runs out.';
  static const String dodgeDropDesc =
      'Dodge falling obstacles by swiping left and right. Survive as long as you can!';

  // Game icons (Material Icons names)
  static const String perfectHitIcon = 'gps_fixed';
  static const String fiveSecondBrainIcon = 'psychology';
  static const String dodgeDropIcon = 'rocket_launch';

  // Timing
  static const int splashDurationMs = 2500;
  static const int brainTimerSeconds = 5;
  static const int dodgeDropTimerSeconds = 90;

  // Scoring
  static const int perfectHitPerfectScore = 100;
  static const int perfectHitGoodScore = 50;
  static const int perfectHitMissScore = 0;
  static const int brainCorrectScore = 100;
  static const int brainStreakBonus = 50;
  static const int dodgeDropPointsPerSecond = 10;

  // Difficulty
  static const List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  // SharedPreferences keys
  static const String keyHighScorePerfectHit = 'high_score_perfect_hit';
  static const String keyHighScoreBrain = 'high_score_brain';
  static const String keyHighScoreDodge = 'high_score_dodge';
  static const String keyTotalGamesPlayed = 'total_games_played';
  static const String keyPlayerName = 'player_name';
}
