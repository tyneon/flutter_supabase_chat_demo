import 'dart:io';

import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/providers/chat_messages_provider.dart';
import 'package:supabase_chat/models/chat.dart';
import 'package:supabase_chat/widgets/video_message_dialog.dart';

class MessageInput extends ConsumerStatefulWidget {
  final int chatId;
  const MessageInput(this.chatId, {super.key});

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  FocusNode focus = FocusNode();
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    focus.addListener(onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    focus.removeListener(onFocusChange);
    focus.dispose();
  }

  void onFocusChange() {
    setState(() {});
    print("Focus: ${focus.hasFocus.toString()}");
  }

  void pickImageSource() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton.icon(
              onPressed: () {
                pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.camera),
              label: const Text("Take a photo"),
            ),
            FilledButton.icon(
              onPressed: () {
                pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.image_search),
              label: const Text("Browse gallery"),
            ),
          ],
        ),
      ),
    );
  }

  void pickImage(ImageSource imageSource) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: imageSource!);

    if (image == null) {
      return;
    }

    setState(() {
      pickedImage = File(image.path);
    });
  }

  void clearPickedImage() {
    setState(() {
      pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final doSend = focus.hasFocus || (pickedImage != null);
    final authAsyncValue = ref.watch(authProvider);
    if (authAsyncValue.hasError) {
      return Center(child: Text('ERROR: ${authAsyncValue.error}'));
    }
    if (authAsyncValue.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (authAsyncValue.value == null) {
      throw Exception("Not authenticated");
    }
    final auth = authAsyncValue.value!;
    final textController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: (pickedImage == null)
                ? TextField(
                    style: TextStyle(
                      color: colorScheme.onBackground,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                      isDense: true,
                    ),
                    controller: textController,
                    focusNode: focus,
                    minLines: 1,
                    maxLines: 4,
                  )
                : ImagePreview(
                    pickedImage!,
                    onCancel: clearPickedImage,
                  ),
          ),
          IconButton(
            onPressed: () async {
              if (doSend) {
                if (textController.text.isNotEmpty) {
                  sendMessage(widget.chatId, auth, textController.text);
                  textController.clear();
                } else if (pickedImage != null) {
                  await sendImageMessage(widget.chatId, auth, pickedImage!);
                  clearPickedImage();
                }
              } else {
                pickImageSource();
              }
            },
            icon: Icon(doSend ? Icons.send : Icons.attach_file),
            color: colorScheme.secondary,
          ),
          if (!doSend)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => VideoMessageDialog(widget.chatId, auth),
                );
              },
              icon: const Icon(Icons.photo_camera_outlined),
              color: colorScheme.secondary,
            ),
        ],
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final File image;
  final Function() onCancel;
  const ImagePreview(
    this.image, {
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 15;
    const double borderWidth = 3;
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(5),
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.tertiary,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(radius - borderWidth),
              child: Image.file(
                image,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            InkWell(
              onTap: onCancel,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: colorScheme.background,
                ),
                child: Icon(
                  Icons.cancel,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
