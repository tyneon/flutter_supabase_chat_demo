import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MessageVideoPlayer extends StatefulWidget {
  final File videoFile;
  const MessageVideoPlayer(this.videoFile, {super.key});

  @override
  State<MessageVideoPlayer> createState() => _MessageVideoPlayerState();
}

class _MessageVideoPlayerState extends State<MessageVideoPlayer> {
  late VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.file(widget.videoFile);
    videoController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    videoController.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    videoController.setLooping(true);
    videoController.play();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(videoController);
  }
}
