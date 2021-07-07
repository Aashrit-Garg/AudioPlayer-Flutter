import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'MusicPlayer/AudioPlayerTask.dart';
import 'MusicPlayer/SeekBar.dart';
import 'components/CustomBottomNavBar.dart';
import 'enums.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioServiceWidget(child: MainScreen()),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Service Demo'),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedMenu: MenuState.home,
        key: Key('navBar'),
        playPause: StreamBuilder<MediaState>(
          stream: _mediaStateStream,
          builder: (context, snapshot) {
            final mediaState = snapshot.data;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.navigate_before),
                      iconSize: 64.0,
                      onPressed: () {
                        Duration pos = mediaState?.position ?? Duration.zero;
                        Duration updatedPos = pos - Duration(seconds: 15);
                        AudioService.seekTo(updatedPos > Duration.zero
                            ? updatedPos
                            : Duration.zero);
                      },
                    ),
                    StreamBuilder<bool>(
                      stream: AudioService.playbackStateStream
                          .map((state) => state.playing)
                          .distinct(),
                      builder: (context, snapshot) {
                        final playing = snapshot.data ?? false;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (playing) pauseButton() else playButton(),
                            stopButton(),
                          ],
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.navigate_next),
                      iconSize: 64.0,
                      onPressed: () {
                        Duration duration =
                            mediaState?.mediaItem?.duration ?? Duration.zero;
                        Duration pos = mediaState?.position ?? Duration.zero;
                        Duration updatedPos = pos + Duration(seconds: 15);
                        AudioService.seekTo(
                            updatedPos < duration ? updatedPos : duration);
                      },
                    ),
                  ],
                ),
                SeekBar(
                  duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                  position: mediaState?.position ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    AudioService.seekTo(newPosition);
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: StreamBuilder<bool>(
          stream: AudioService.runningStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              // Don't show anything until we've ascertained whether or not the
              // service is running, since we want to show a different UI in
              // each case.
              return SizedBox();
            }
            final running = snapshot.data ?? false;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!running) ...[
                  // UI to show when we're not running, i.e. a menu.
                  audioPlayerButton(),
                  // if (kIsWeb || !Platform.isMacOS) textToSpeechButton(),
                ] else ...[
                  // UI to show when we're running, i.e. player state/controls.

                  // Queue display/controls.
                  StreamBuilder<QueueState>(
                    stream: _queueStateStream,
                    builder: (context, snapshot) {
                      final queueState = snapshot.data;
                      final queue = queueState?.queue ?? [];
                      final mediaItem = queueState?.mediaItem;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (queue.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.skip_previous),
                                  iconSize: 64.0,
                                  onPressed: mediaItem == queue.first
                                      ? null
                                      : AudioService.skipToPrevious,
                                ),
                                IconButton(
                                  icon: Icon(Icons.skip_next),
                                  iconSize: 64.0,
                                  onPressed: mediaItem == queue.last
                                      ? null
                                      : AudioService.skipToNext,
                                ),
                              ],
                            ),
                          if (mediaItem?.title != null) Text(mediaItem!.title),
                        ],
                      );
                    },
                  ),
                  // Play/pause/stop buttons.
                  StreamBuilder<bool>(
                    stream: AudioService.playbackStateStream
                        .map((state) => state.playing)
                        .distinct(),
                    builder: (context, snapshot) {
                      final playing = snapshot.data ?? false;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (playing) pauseButton() else playButton(),
                          stopButton(),
                        ],
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.airplanemode_active),
                    iconSize: 64.0,
                    onPressed: () async {
                      List<MediaItem> items = <MediaItem>[
                        MediaItem(
                          // This can be any unique id, but we use the audio URL for convenience.
                          id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
                          album: "Science Friday",
                          title: "A",
                          artist: "Science Friday and WNYC Studios",
                          duration: Duration(milliseconds: 5739820),
                          artUri: Uri.parse(
                              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
                        ),
                        MediaItem(
                          id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
                          album: "Science Friday",
                          title: "B",
                          artist: "Science Friday and WNYC Studios",
                          duration: Duration(milliseconds: 2856950),
                          artUri: Uri.parse(
                              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
                        ),
                        MediaItem(
                          id: "https://files.hubhopper.com/podcast/316340/episode/25390674/what-is-karma-vishen-lakhiani-with-sadhguru-mindvalley.mp3?v=1625499668&s=rss-feed",
                          album: "Science Friday",
                          title: "C",
                          artist: "Science Friday and WNYC Studios",
                          duration: Duration(milliseconds: 2856950),
                          artUri: Uri.parse(
                              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
                        ),
                      ];
                      await AudioService.updateQueue(items);
                    },
                  ),
                  // A seek bar.
                  StreamBuilder<MediaState>(
                    stream: _mediaStateStream,
                    builder: (context, snapshot) {
                      final mediaState = snapshot.data;
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.navigate_before),
                                iconSize: 64.0,
                                onPressed: () {
                                  Duration pos =
                                      mediaState?.position ?? Duration.zero;
                                  Duration updatedPos =
                                      pos - Duration(seconds: 15);
                                  AudioService.seekTo(updatedPos > Duration.zero
                                      ? updatedPos
                                      : Duration.zero);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.navigate_next),
                                iconSize: 64.0,
                                onPressed: () {
                                  Duration duration =
                                      mediaState?.mediaItem?.duration ??
                                          Duration.zero;
                                  Duration pos =
                                      mediaState?.position ?? Duration.zero;
                                  Duration updatedPos =
                                      pos + Duration(seconds: 15);
                                  AudioService.seekTo(updatedPos < duration
                                      ? updatedPos
                                      : duration);
                                },
                              ),
                            ],
                          ),
                          SeekBar(
                            duration: mediaState?.mediaItem?.duration ??
                                Duration.zero,
                            position: mediaState?.position ?? Duration.zero,
                            onChangeEnd: (newPosition) {
                              AudioService.seekTo(newPosition);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  // Display the processing state.
                  StreamBuilder<AudioProcessingState>(
                    stream: AudioService.playbackStateStream
                        .map((state) => state.processingState)
                        .distinct(),
                    builder: (context, snapshot) {
                      final processingState =
                          snapshot.data ?? AudioProcessingState.none;
                      return Text(
                          "Processing state: ${describeEnum(processingState)}");
                    },
                  ),
                  // Display the latest custom event.
                  StreamBuilder(
                    stream: AudioService.customEventStream,
                    builder: (context, snapshot) {
                      return Text("custom event: ${snapshot.data}");
                    },
                  ),
                  // Display the notification click status.
                  StreamBuilder<bool>(
                    stream: AudioService.notificationClickEventStream,
                    builder: (context, snapshot) {
                      return Text(
                        'Notification Click Status: ${snapshot.data}',
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          (mediaItem, position) => MediaState(mediaItem, position));

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>?, MediaItem?, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          (queue, mediaItem) => QueueState(queue, mediaItem));

  ElevatedButton audioPlayerButton() => startButton(
        'AudioPlayer',
        () {
          AudioService.start(
            backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
            androidNotificationChannelName: 'Audio Service Demo',
            // Enable this if you want the Android service to exit the foreground state on pause.
            //androidStopForegroundOnPause: true,
            androidNotificationColor: 0xFF2196f3,
            androidNotificationIcon: 'mipmap/ic_launcher',
            androidEnableQueue: true,
          );
        },
      );

  ElevatedButton startButton(String label, VoidCallback onPressed) =>
      ElevatedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: AudioService.stop,
      );
}

class QueueState {
  final List<MediaItem>? queue;
  final MediaItem? mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

// NOTE: Your entrypoint MUST be a top-level function.
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

// Provides access to a library of media items. In your app, this could come
// from a database or web service.
class MediaLibrary {
  final _items = <MediaItem>[
    MediaItem(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 5739820),
      artUri: Uri.parse(
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    ),
    MediaItem(
      id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
      album: "Science Friday",
      title: "From Cat Rheology To Operatic Incompetence",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 2856950),
      artUri: Uri.parse(
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    ),
  ];

  List<MediaItem> get items => _items;
}
