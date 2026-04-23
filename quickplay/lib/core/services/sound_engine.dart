import 'dart:async';
import 'dart:js_interop';

/// Web Audio API bindings for synthesized game audio.
/// No audio files needed — everything is generated from oscillators.

@JS('AudioContext')
extension type JSAudioContext._(JSObject _) implements JSObject {
  external factory JSAudioContext();
  external JSAudioDestinationNode get destination;
  external num get currentTime;
  external JSString get state;
  external JSPromise resume();
  external JSOscillatorNode createOscillator();
  external JSGainNode createGain();
  external JSBiquadFilterNode createBiquadFilter();
}

@JS('OscillatorNode')
extension type JSOscillatorNode._(JSObject _) implements JSObject {
  external JSAudioParam get frequency;
  external set type(JSString value);
  external void connect(JSObject destination);
  external void start([num when]);
  external void stop([num when]);
}

@JS('GainNode')
extension type JSGainNode._(JSObject _) implements JSObject {
  external JSAudioParam get gain;
  external void connect(JSObject destination);
  external void disconnect();
}

@JS('BiquadFilterNode')
extension type JSBiquadFilterNode._(JSObject _) implements JSObject {
  external set type(JSString value);
  external JSAudioParam get frequency;
  external JSAudioParam get Q;
  external void connect(JSObject destination);
}

@JS('AudioParam')
extension type JSAudioParam._(JSObject _) implements JSObject {
  external set value(num v);
  external num get value;
  external void setValueAtTime(num value, num startTime);
  external void linearRampToValueAtTime(num value, num endTime);
  external void exponentialRampToValueAtTime(num value, num endTime);
}

@JS('AudioDestinationNode')
extension type JSAudioDestinationNode._(JSObject _) implements JSObject {}

/// Synthesized game audio engine using Web Audio API.
class SoundEngine {
  JSAudioContext? _ctx;
  final List<_BGMNode> _bgmNodes = [];
  bool _bgmPlaying = false;
  String? _currentBGM;

  SoundEngine();

  JSAudioContext get _audioCtx {
    _ctx ??= JSAudioContext();
    return _ctx!;
  }

  Future<void> _ensureResumed() async {
    if (_audioCtx.state.toDart == 'suspended') {
      _audioCtx.resume();
    }
  }

  // ─── SOUND EFFECTS ──────────────────────────────────────────────────

  /// Short click / tap
  void playTap() {
    _ensureResumed();
    _playTone(800, 0.06, 'sine', 0.15);
    _playTone(1200, 0.04, 'sine', 0.08, delay: 0.03);
  }

  /// Success ding — ascending two-note chime
  void playSuccess() {
    _ensureResumed();
    _playTone(880, 0.12, 'sine', 0.2);
    _playTone(1320, 0.15, 'sine', 0.18, delay: 0.08);
  }

  /// Error buzz — low dissonant tone
  void playError() {
    _ensureResumed();
    _playTone(180, 0.2, 'sawtooth', 0.12);
    _playTone(200, 0.18, 'square', 0.06, delay: 0.02);
  }

  /// Level up — ascending arpeggio
  void playLevelUp() {
    _ensureResumed();
    _playTone(523, 0.1, 'sine', 0.15);
    _playTone(659, 0.1, 'sine', 0.15, delay: 0.08);
    _playTone(784, 0.1, 'sine', 0.15, delay: 0.16);
    _playTone(1047, 0.2, 'sine', 0.18, delay: 0.24);
  }

  /// Game over — descending thud
  void playGameOver() {
    _ensureResumed();
    _playTone(440, 0.15, 'sine', 0.2);
    _playTone(330, 0.15, 'sine', 0.18, delay: 0.12);
    _playTone(220, 0.3, 'sine', 0.22, delay: 0.24);
    _playTone(110, 0.5, 'triangle', 0.15, delay: 0.36);
  }

  /// Countdown beep (3-2-1)
  void playCountdownTick() {
    _ensureResumed();
    _playTone(660, 0.08, 'sine', 0.2);
  }

  /// Countdown GO!
  void playCountdownGo() {
    _ensureResumed();
    _playTone(880, 0.1, 'sine', 0.25);
    _playTone(1320, 0.15, 'sine', 0.2, delay: 0.06);
    _playTone(1760, 0.2, 'sine', 0.18, delay: 0.14);
  }

  /// Perfect hit — sparkle chime
  void playPerfect() {
    _ensureResumed();
    _playTone(1047, 0.08, 'sine', 0.2);
    _playTone(1319, 0.08, 'sine', 0.18, delay: 0.05);
    _playTone(1568, 0.12, 'sine', 0.15, delay: 0.1);
    _playTone(2093, 0.18, 'sine', 0.12, delay: 0.16);
  }

  /// Score tick (points added)
  void playScoreTick() {
    _ensureResumed();
    _playTone(1200, 0.04, 'sine', 0.1);
  }

  void _playTone(
    double freq,
    double duration,
    String type,
    double gain, {
    double delay = 0,
  }) {
    final ctx = _audioCtx;
    final now = ctx.currentTime.toDouble();
    final startTime = now + delay;
    final endTime = startTime + duration;

    final osc = ctx.createOscillator();
    final gainNode = ctx.createGain();

    osc.type = type.toJS;
    osc.frequency.setValueAtTime(freq, startTime);

    gainNode.gain.setValueAtTime(gain, startTime);
    gainNode.gain.linearRampToValueAtTime(0.0, endTime);

    osc.connect(gainNode);
    gainNode.connect(ctx.destination);

    osc.start(startTime);
    osc.stop(endTime + 0.05);
  }

  // ─── BACKGROUND MUSIC ──────────────────────────────────────────────

  /// Start looping background music for a specific game.
  void startBGM(String gameId) {
    if (_currentBGM == gameId && _bgmPlaying) return;
    stopBGM();
    _currentBGM = gameId;
    _bgmPlaying = true;
    _ensureResumed();

    switch (gameId) {
      case 'perfect_hit':
        _playPerfectHitBGM();
        break;
      case 'brain':
        _playBrainBGM();
        break;
      case 'dodge':
        _playDodgeBGM();
        break;
    }
  }

  void stopBGM() {
    _bgmPlaying = false;
    _currentBGM = null;
    for (final node in _bgmNodes) {
      try {
        node.gain.disconnect();
      } catch (_) {}
    }
    _bgmNodes.clear();
  }

  /// Perfect Hit — Chill rhythmic pulse (steady beat, muted)
  void _playPerfectHitBGM() {
    // Low bass drone
    _bgmLoop([220, 220, 247, 220], 0.6, 'sine', 0.06, 'perfect_hit');
    // Soft mid pad
    _bgmLoop([440, 494, 523, 494], 0.8, 'triangle', 0.03, 'perfect_hit');
  }

  /// Brain — Ticking ambient tension (clock-like)
  void _playBrainBGM() {
    // Soft ticking bass
    _bgmLoop([330, 330, 392, 330], 0.5, 'sine', 0.05, 'brain');
    // High sparkle notes
    _bgmLoop([660, 784, 880, 784], 0.8, 'sine', 0.025, 'brain');
  }

  /// Dodge — Driving pulse (energetic, faster)
  void _playDodgeBGM() {
    // Driving bass
    _bgmLoop([165, 196, 165, 220], 0.4, 'triangle', 0.06, 'dodge');
    // Rhythmic mid
    _bgmLoop([330, 392, 440, 392], 0.4, 'sine', 0.03, 'dodge');
  }

  void _bgmLoop(
    List<double> notes,
    double noteDuration,
    String type,
    double gain,
    String gameId,
  ) {
    final ctx = _audioCtx;
    final osc = ctx.createOscillator();
    final gainNode = ctx.createGain();

    osc.type = type.toJS;
    gainNode.gain.value = gain;

    osc.connect(gainNode);
    gainNode.connect(ctx.destination);

    _bgmNodes.add(_BGMNode(gainNode));

    osc.start();

    // Schedule note changes
    int noteIndex = 0;
    Timer.periodic(Duration(milliseconds: (noteDuration * 1000).toInt()), (
      timer,
    ) {
      if (!_bgmPlaying || _currentBGM != gameId) {
        timer.cancel();
        try {
          osc.stop();
        } catch (_) {}
        return;
      }
      final note = notes[noteIndex % notes.length];
      osc.frequency.value = note;

      // Soft volume envelope for each note
      final now = ctx.currentTime.toDouble();
      gainNode.gain.setValueAtTime(gain, now);
      gainNode.gain.linearRampToValueAtTime(
        gain * 0.6,
        now + noteDuration * 0.8,
      );

      noteIndex++;
    });
  }

  void dispose() {
    stopBGM();
    _ctx = null;
  }
}

class _BGMNode {
  final JSGainNode gain;
  _BGMNode(this.gain);
}
