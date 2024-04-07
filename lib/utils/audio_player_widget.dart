import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _playAudio();
      },
      child: widget.child,
    );
  }

  Future<void> _playAudio() async {
    debugPrint("play");
    await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.audioLink)));
    await _player.play();
  }
}