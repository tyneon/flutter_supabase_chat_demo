import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';

import 'package:supabase_chat/providers/chat_messages_provider.dart';
import 'package:supabase_chat/cameras.dart';

class VideoMessageDialog extends StatefulWidget {
  final int chatId;
  final int auth;
  const VideoMessageDialog(
    this.chatId,
    this.auth, {
    super.key,
  });

  @override
  State<VideoMessageDialog> createState() => _VideoMessageDialogState();
}

class _VideoMessageDialogState extends State<VideoMessageDialog> {
  VideoPlayerController? videoController;
  late CameraController cameraController;
  int selectedCameraIndex = 0;
  bool isRecording = false;
  File? recordedVideo;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    disposeCamera();
    disposeVideoPlayer();
    super.dispose();
  }

  void initCamera() {
    cameraController = CameraController(
      Cameras.list[selectedCameraIndex],
      ResolutionPreset.low,
    );
    cameraController.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  Future<void> disposeCamera() async {
    await cameraController.dispose();
  }

  void switchCamera() async {
    selectedCameraIndex = (selectedCameraIndex + 1) % Cameras.list.length;
    await disposeCamera();
    initCamera();
  }

  Future<void> startVideoRecording() async {
    if (!cameraController.value.isInitialized ||
        cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.startVideoRecording();
      if (mounted) {
        setState(() {
          isRecording = true;
        });
      }
    } on CameraException catch (e) {
      // _showCameraException(e);
      print(e);
    }
  }

  Future<void> stopVideoRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      recordedVideo = File((await cameraController.stopVideoRecording()).path);
      initVideoPlayer();
      if (mounted) {
        setState(() {
          isRecording = false;
        });
      }
    } on CameraException catch (e) {
      // _showCameraException(e);
      print(e);
    }
  }

  void initVideoPlayer() {
    if (recordedVideo == null) {
      return;
    }
    videoController = VideoPlayerController.file(recordedVideo!);
    videoController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    videoController!.setLooping(true);
    videoController!.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    videoController!.play();
  }

  void disposeVideoPlayer() {
    videoController?.dispose();
  }

  void deleteRecordedVideo() {
    if (mounted) {
      setState(() {
        recordedVideo = null;
      });
    }
  }

  void sendRecordedVideo() async {
    if (recordedVideo == null) {
      return;
    }
    await sendVideoMessage(widget.chatId, widget.auth, recordedVideo!);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 50,
      child: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: 500,
              width: MediaQuery.of(context).size.width - 50,
              child: (recordedVideo != null && videoController != null)
                  ? VideoPlayer(videoController!)
                  : cameraController.value.isInitialized
                      ? Center(
                          child: CameraPreview(
                            cameraController,
                          ),
                        )
                      : const Center(child: Placeholder()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filledTonal(
                    onPressed: switchCamera,
                    icon: const Icon(Icons.change_circle_outlined),
                  ),
                  if (recordedVideo == null)
                    IconButton.filledTonal(
                      onPressed: isRecording
                          ? stopVideoRecording
                          : startVideoRecording,
                      icon: Icon(
                        Icons.fiber_manual_record,
                        color: isRecording ? Colors.red : Colors.white,
                      ),
                    )
                  else
                    IconButton.filledTonal(
                      onPressed: deleteRecordedVideo,
                      icon: const Icon(
                        Icons.delete_forever,
                      ),
                    ),
                  IconButton.filledTonal(
                    onPressed: recordedVideo == null ? null : sendRecordedVideo,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
