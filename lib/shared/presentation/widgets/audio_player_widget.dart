import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Plays [audioLink] when [child] is tapped. The clip is loaded as soon as the
/// widget appears (and again if the link changes), so a tap only has to seek
/// to the start and play — no load delay.
class AudioPlayerWidget extends StatefulWidget {
  final Widget child;
  final String audioLink;

  const AudioPlayerWidget({
    super.key,
    required this.child,
    required this.audioLink,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  Future<void>? _loading;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _load();
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioLink != widget.audioLink) _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // Buffers the clip without playing it. A failed load (offline, bad link)
  // leaves the player idle so the next tap retries.
  void _load() {
    _loading = _player
        .setUrl(widget.audioLink)
        .then<void>((_) {})
        .catchError((Object e) => debugPrint("[AudioPlayerWidget] load failed: $e"));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playAudio,
      child: widget.child,
    );
  }

  Future<void> _playAudio() async {
    await _loading;
    if (_player.processingState == ProcessingState.idle) {
      _load();
      await _loading;
      if (_player.processingState == ProcessingState.idle) return;
    }
    // Rewind so a repeat tap (or a finished clip) starts from the top. Not
    // awaited: play() only completes when the clip ends.
    await _player.seek(Duration.zero);
    _player.play();
  }
}
