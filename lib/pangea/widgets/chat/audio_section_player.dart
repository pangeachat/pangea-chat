import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fluffychat/pages/chat/events/audio_player.dart';
import 'package:fluffychat/pangea/widgets/chat/message_audio_card.dart';
import 'package:fluffychat/utils/error_reporter.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:matrix/matrix.dart';
import 'package:opus_caf_converter_dart/opus_caf_converter_dart.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utils/matrix_sdk_extensions/event_extension.dart';

class AudioSectionPlayerWidget extends StatefulWidget {
  final Event? event;
  final PangeaAudioFile? matrixFile;
  static const int wavesCount = 100;

  final double? sectionStartMS;
  final double? sectionEndMS;

  const AudioSectionPlayerWidget(
    this.event, {
    this.matrixFile,
    this.sectionStartMS,
    this.sectionEndMS,
    super.key,
  });

  @override
  AudioSectionPlayerState createState() => AudioSectionPlayerState();
}

class AudioSectionPlayerState extends State<AudioSectionPlayerWidget> {
  AudioPlayerStatus status = AudioPlayerStatus.notDownloaded;
  AudioPlayer? audioPlayer;

  StreamSubscription? onAudioPositionChanged;
  StreamSubscription? onDurationChanged;
  StreamSubscription? onPlayerStateChanged;
  StreamSubscription? onPlayerError;

  String? statusText;
  int currentPosition = 0;
  double maxPosition = 0;

  MatrixFile? matrixFile;
  File? audioFile;

  int? get startMS {
    return widget.sectionStartMS != null
        ? (widget.sectionStartMS! * maxPosition).round()
        : null;
  }

  int? get endMS {
    return widget.sectionEndMS != null
        ? (widget.sectionEndMS! * maxPosition).round()
        : null;
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

  @override
  void didUpdateWidget(covariant oldWidget) {
    if ((oldWidget.sectionEndMS != widget.sectionEndMS) ||
        (oldWidget.sectionStartMS != widget.sectionStartMS)) {
      debugPrint('selection changed');
      if (startMS != null) {
        audioPlayer?.seek(Duration(milliseconds: startMS!));
        audioPlayer?.play();
      } else {
        audioPlayer?.stop();
        audioPlayer?.seek(null);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _downloadAction() async {
    if (status != AudioPlayerStatus.notDownloaded || widget.event == null) {
      return;
    }
    setState(() => status = AudioPlayerStatus.downloading);
    try {
      final matrixFile = await widget.event!.downloadAndDecryptAttachment();
      File? file;

      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final fileName = Uri.encodeComponent(
          widget.event!.attachmentOrThumbnailMxcUrl()!.pathSegments.last,
        );
        file = File('${tempDir.path}/${fileName}_${matrixFile.name}');

        await file.writeAsBytes(matrixFile.bytes);

        if (Platform.isIOS &&
            matrixFile.mimeType.toLowerCase() == 'audio/ogg') {
          Logs().v('Convert ogg audio file for iOS...');
          final convertedFile = File('${file.path}.caf');
          if (await convertedFile.exists() == false) {
            OpusCaf().convertOpusToCaf(file.path, convertedFile.path);
          }
          file = convertedFile;
        }
      }

      setState(() {
        audioFile = file;
        this.matrixFile = matrixFile;
        status = AudioPlayerStatus.downloaded;
      });
      _playAction();
    } catch (e, s) {
      Logs().v('Could not download audio file', e, s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toLocalizedString(context)),
        ),
      );
    }
  }

  void _playAction() async {
    final audioPlayer = this.audioPlayer ??= AudioPlayer();
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
                AudioSectionPlayerWidget.wavesCount)
            .round();
      });

      if (startMS != null &&
          endMS != null &&
          state.inMilliseconds.toDouble() >= endMS!) {
        audioPlayer.stop();
        audioPlayer.seek(Duration(milliseconds: startMS!));
      } else if (state.inMilliseconds.toDouble() == maxPosition) {
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

    final audioFile = this.audioFile;
    if (audioFile != null) {
      audioPlayer.setFilePath(audioFile.path);
    } else {
      try {
        if (widget.matrixFile != null) {
          await audioPlayer.setAudioSource(
            BytesAudioSource(
              widget.matrixFile!.bytes,
              widget.matrixFile!.mimeType,
            ),
          );
        } else {
          await audioPlayer.setAudioSource(MatrixFileAudioSource(matrixFile!));
        }
      } catch (e, _) {
        debugger(when: kDebugMode);
      }
    }

    if (startMS != null) {
      audioPlayer.seek(Duration(milliseconds: startMS!));
    }
    audioPlayer.play().onError(
          ErrorReporter(context, 'Unable to play audio message')
              .onErrorCallback,
        );
  }

  static const double buttonSize = 36;

  String? get _durationString {
    int? durationInt;
    if (widget.matrixFile?.duration != null) {
      durationInt = widget.matrixFile!.duration;
    } else {
      durationInt = widget.event?.content
          .tryGetMap<String, dynamic>('info')
          ?.tryGet<int>('duration');
    }
    if (durationInt == null) return null;
    final duration = Duration(milliseconds: durationInt);
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  List<int> _getWaveform() {
    final eventWaveForm = widget.matrixFile?.waveform ??
        widget.event?.content
            .tryGetMap<String, dynamic>('org.matrix.msc1767.audio')
            ?.tryGetList<int>('waveform');
    if (eventWaveForm == null || eventWaveForm.isEmpty) {
      return List<int>.filled(AudioSectionPlayerWidget.wavesCount, 500);
    }
    while (eventWaveForm.length < AudioSectionPlayerWidget.wavesCount) {
      for (var i = 0; i < eventWaveForm.length; i = i + 2) {
        eventWaveForm.insert(i, eventWaveForm[i]);
      }
    }
    var i = 0;
    final step =
        (eventWaveForm.length / AudioSectionPlayerWidget.wavesCount).round();
    while (eventWaveForm.length > AudioSectionPlayerWidget.wavesCount) {
      eventWaveForm.removeAt(i);
      i = (i + step) % AudioSectionPlayerWidget.wavesCount;
    }
    return eventWaveForm.map((i) => i > 1024 ? 1024 : i).toList();
  }

  late final List<int> waveform;

  Future<void> _downloadMatrixFile() async {
    if (kIsWeb) return;
    final temp = await getTemporaryDirectory();
    final tempDir = temp;
    final file = File('${tempDir.path}/${widget.matrixFile!.name}');
    await file.writeAsBytes(widget.matrixFile!.bytes);
    audioFile = file;
  }

  @override
  void initState() {
    super.initState();
    waveform = _getWaveform();
    if (widget.matrixFile != null) {
      _downloadMatrixFile().then((_) {
        setState(() => status = AudioPlayerStatus.downloaded);
        status == AudioPlayerStatus.downloaded
            ? _playAction()
            : _downloadAction();
      });
    } else {
      status == AudioPlayerStatus.downloaded
          ? _playAction()
          : _downloadAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;

    final statusText = this.statusText ??= _durationString ?? '00:00';
    final audioPlayer = this.audioPlayer;

    final msPerWave = (maxPosition / AudioSectionPlayerWidget.wavesCount);
    final int? startWave = startMS != null && msPerWave > 0
        ? (startMS! / msPerWave).floor()
        : null;
    final int? endWave =
        endMS != null && msPerWave > 0 ? (endMS! / msPerWave).ceil() : null;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: status == AudioPlayerStatus.downloading
                ? CircularProgressIndicator(strokeWidth: 2, color: color)
                : InkWell(
                    borderRadius: BorderRadius.circular(64),
                    child: Material(
                      color: color.withAlpha(64),
                      borderRadius: BorderRadius.circular(64),
                      child: Icon(
                        audioPlayer?.playerState.playing == true
                            ? Icons.pause_outlined
                            : Icons.play_arrow_outlined,
                        color: color,
                      ),
                    ),
                    onLongPress: () => widget.event?.saveFile(context),
                    onTap: () {
                      if (status == AudioPlayerStatus.downloaded) {
                        _playAction();
                      } else {
                        _downloadAction();
                      }
                    },
                  ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < AudioSectionPlayerWidget.wavesCount; i++)
                  Builder(
                    builder: (context) {
                      final bool hasSelection =
                          endMS != null && startMS != null;

                      final bool inRange = startWave != null &&
                          i >= startWave &&
                          endWave != null &&
                          i < endWave;

                      double barOpacity = currentPosition > i ? 1 : 0.5;
                      if (hasSelection && !inRange) {
                        barOpacity = 0.5;
                      }

                      return Expanded(
                        child: Stack(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTapDown: (_) => audioPlayer?.seek(
                                  Duration(
                                    milliseconds: (maxPosition /
                                                AudioSectionPlayerWidget
                                                    .wavesCount)
                                            .round() *
                                        i,
                                  ),
                                ),
                                child: Expanded(
                                  child: Container(
                                    height: 32,
                                    color: color.withAlpha(0),
                                    alignment: Alignment.center,
                                    child: Opacity(
                                      opacity: barOpacity,
                                      child: Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          height: 32 * (waveform[i] / 1024),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (startWave != null &&
                                i >= startWave &&
                                endWave != null &&
                                i < endWave)
                              Expanded(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
