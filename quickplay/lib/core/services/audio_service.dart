import 'package:flutter/services.dart';
import '../providers/game_provider.dart';
import 'sound_engine.dart';

/// Audio + haptic feedback service wrapping the synthesized SoundEngine.
/// Respects user sound/haptic preferences from GameProvider.
class AudioService {
  final GameProvider _provider;
  final SoundEngine _engine = SoundEngine();

  AudioService(this._provider);

  bool get _soundEnabled => _provider.soundEnabled;
  bool get _hapticsEnabled => _provider.hapticsEnabled;

  /// Short tap/click feedback
  void tap() {
    if (_soundEnabled) _engine.playTap();
    if (_hapticsEnabled) HapticFeedback.selectionClick();
  }

  /// Success ding — correct answer, perfect hit
  void success() {
    if (_soundEnabled) _engine.playSuccess();
    if (_hapticsEnabled) HapticFeedback.lightImpact();
  }

  /// Perfect hit — sparkle chime
  void perfect() {
    if (_soundEnabled) _engine.playPerfect();
    if (_hapticsEnabled) HapticFeedback.lightImpact();
  }

  /// Error buzz — wrong answer, miss
  void error() {
    if (_soundEnabled) _engine.playError();
    if (_hapticsEnabled) HapticFeedback.mediumImpact();
  }

  /// Level up ascending arpeggio
  void levelUp() {
    if (_soundEnabled) _engine.playLevelUp();
    if (_hapticsEnabled) HapticFeedback.mediumImpact();
  }

  /// Game over descending thud
  void gameOver() {
    if (_soundEnabled) _engine.playGameOver();
    if (_hapticsEnabled) HapticFeedback.heavyImpact();
  }

  /// Countdown tick (3, 2, 1)
  void countdownTick() {
    if (_soundEnabled) _engine.playCountdownTick();
  }

  /// Countdown GO!
  void countdownGo() {
    if (_soundEnabled) _engine.playCountdownGo();
  }

  /// Score increment tick
  void scoreTick() {
    if (_soundEnabled) _engine.playScoreTick();
  }

  /// Start background music for a game
  void startBGM(String gameId) {
    if (_soundEnabled) _engine.startBGM(gameId);
  }

  /// Stop background music
  void stopBGM() {
    _engine.stopBGM();
  }

  void dispose() {
    _engine.dispose();
  }
}
