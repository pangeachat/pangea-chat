import 'dart:async';

import 'package:fluffychat/pages/chat/events/audio_player.dart';
import 'package:fluffychat/pangea/widgets/chat/message_audio_card.dart';
import 'package:fluffychat/utils/error_reporter.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:matrix/matrix.dart';

class AudioClipPlayerWidget extends StatefulWidget {
  final Color color;
  final PangeaAudioFile audio;
  final Event event;
  final int startTime;
  final int endTime;
  final bool autoplay;
  static String? currentId;

  const AudioClipPlayerWidget(
    this.color,
    this.audio,
    this.event,
    this.startTime,
    this.endTime, {
    this.autoplay = true,
    super.key,
  });

  @override
  AudioClipPlayerState createState() => AudioClipPlayerState();
}

class AudioClipPlayerState extends State<AudioClipPlayerWidget> {
  static const double buttonSize = 36;
  String? statusText;
  late final List<int> waveform;
  AudioPlayer? audioPlayer;
  int currentPosition = 0;
  double maxPosition = 0;

  StreamSubscription? onAudioPositionChanged;
  StreamSubscription? onDurationChanged;
  StreamSubscription? onPlayerStateChanged;
  StreamSubscription? onPlayerError;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer!.setAudioSource(
      BytesAudioSource(widget.audio.bytes, widget.audio.mimeType),
    );
    audioPlayer!.setClip(
      start: Duration(milliseconds: widget.startTime),
      end: Duration(milliseconds: widget.startTime),
    );
    waveform = _getWaveform();
    if (widget.autoplay) {
      _playAction();
    }
  }

  @override
  void dispose() {
    if (audioPlayer?.playerState.playing == true) {
      audioPlayer?.stop();
    }
    onAudioPositionChanged?.cancel();
    onDurationChanged?.cancel();
    onPlayerStateChanged?.cancel();
    onPlayerError?.cancel();

    super.dispose();
  }

  void _playAction() async {
    final audioPlayer = this.audioPlayer!;
    if (AudioClipPlayerWidget.currentId != widget.event.eventId) {
      if (AudioClipPlayerWidget.currentId != null &&
          (audioPlayer.playerState.playing)) {
        await audioPlayer.stop();
        setState(() {});
      }
      AudioClipPlayerWidget.currentId = widget.event.eventId;
    }
    if (audioPlayer.playerState.playing) {
      await audioPlayer.pause();
      return;
    } else if (audioPlayer.position != Duration.zero) {
      await audioPlayer.play();
      return;
    }

    onAudioPositionChanged ??= audioPlayer.positionStream.listen((state) {
      if (maxPosition <= 0) return;
      setState(() {
        statusText =
            '${state.inMinutes.toString().padLeft(2, '0')}:${(state.inSeconds % 60).toString().padLeft(2, '0')}';
        currentPosition = ((state.inMilliseconds.toDouble() / maxPosition) *
                AudioPlayerWidget.wavesCount)
            .round();
      });
      if (state.inMilliseconds.toDouble() == maxPosition) {
        audioPlayer.stop();
        audioPlayer.seek(null);
      }
    });
    onDurationChanged ??= audioPlayer.durationStream.listen((max) {
      if (max == null || max == Duration.zero) return;
      setState(() => maxPosition = max.inMilliseconds.toDouble());
    });
    onPlayerStateChanged ??=
        audioPlayer.playingStream.listen((_) => setState(() {}));
    audioPlayer.play().onError(
          ErrorReporter(context, 'Unable to play audio message')
              .onErrorCallback,
        );
  }

  String? get _durationString {
    final duration =
        Duration(milliseconds: (widget.endTime - widget.startTime));
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // Edit to reflect clipping of audio?
  List<int> _getWaveform() {
    final eventWaveForm = widget.audio.waveform;
    if (eventWaveForm == null || eventWaveForm.isEmpty) {
      return List<int>.filled(AudioPlayerWidget.wavesCount, 500);
    }
    while (eventWaveForm.length < AudioPlayerWidget.wavesCount) {
      for (var i = 0; i < eventWaveForm.length; i = i + 2) {
        eventWaveForm.insert(i, eventWaveForm[i]);
      }
    }
    var i = 0;
    final step = (eventWaveForm.length / AudioPlayerWidget.wavesCount).round();
    while (eventWaveForm.length > AudioPlayerWidget.wavesCount) {
      eventWaveForm.removeAt(i);
      i = (i + step) % AudioPlayerWidget.wavesCount;
    }
    return eventWaveForm.map((i) => i > 1024 ? 1024 : i).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = this.statusText ??= _durationString ?? '00:00';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: InkWell(
              borderRadius: BorderRadius.circular(64),
              child: Material(
                color: widget.color.withAlpha(64),
                borderRadius: BorderRadius.circular(64),
                child: Icon(
                  audioPlayer?.playerState.playing == true
                      ? Icons.pause_outlined
                      : Icons.play_arrow_outlined,
                  color: widget.color,
                ),
              ),
              onTap: () {
                _playAction();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < AudioPlayerWidget.wavesCount; i++)
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => audioPlayer?.seek(
                        Duration(
                          milliseconds: ((widget.endTime - widget.startTime) /
                                      AudioPlayerWidget.wavesCount)
                                  .round() *
                              i,
                        ),
                      ),
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        child: Opacity(
                          opacity: currentPosition > i ? 1 : 0.5,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: widget.color,
                              borderRadius: BorderRadius.circular(64),
                            ),
                            height: 32 * (waveform[i] / 1024),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            alignment: Alignment.centerRight,
            width: 42,
            child: Text(
              statusText,
              style: TextStyle(
                color: widget.color,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: InkWell(
                  splashColor: widget.color.withAlpha(128),
                  borderRadius: BorderRadius.circular(64),
                  child: Icon(Icons.mic_none_outlined, color: widget.color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
