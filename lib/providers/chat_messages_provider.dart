import 'dart:io';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:supabase_chat/models/message.dart';

part 'chat_messages_provider.g.dart';

@riverpod
Stream<List<Message>> chatMessages(
  ChatMessagesRef ref,
  int chatId,
) {
  final snapshots = Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id']).eq('chatId', chatId);

  return snapshots.map((snapshot) {
    final messages = <Message>[];
    for (final data in snapshot) {
      messages.add(Message.fromJson(data));
    }
    return messages;
  });
}

@riverpod
Future<Uint8List> chatMediaMemoryData(
  ChatMediaMemoryDataRef ref,
  String mediaPath,
) async {
  final file =
      await Supabase.instance.client.storage.from('media').download(mediaPath);
  return file;
}

@riverpod
Future<File> chatVideoFile(
  ChatVideoFileRef ref,
  String mediaPath,
) async {
  final directory = await getApplicationDocumentsDirectory();
  final videoFile = File('${directory.path}/$mediaPath');
  if (await videoFile.exists()) {
    return videoFile;
  }
  final videoBytes =
      await Supabase.instance.client.storage.from('media').download(mediaPath);
  try {
    videoFile.createSync(recursive: true);
    return await videoFile.writeAsBytes(videoBytes.toList());
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<void> sendMessage(int chatId, int senderId, String text) async {
  await Supabase.instance.client.from('messages').insert(
        Message.newTextMessageToJson(
          chatId: chatId,
          senderId: senderId,
          text: text,
        ),
      );
}

Future<void> sendImageMessage(int chatId, int senderId, File imageFile) async {
  final mediaPath =
      '$chatId/${DateTime.now().microsecondsSinceEpoch.toString()}${path.extension(imageFile.path)}';
  await Supabase.instance.client.storage.from('media').upload(
        mediaPath,
        imageFile,
      );
  await Supabase.instance.client.from('messages').insert(
        Message.newImageMessageToJson(
          chatId: chatId,
          senderId: senderId,
          imagePath: mediaPath,
        ),
      );
}

Future<void> sendVideoMessage(int chatId, int senderId, File videoFile) async {
  final mediaPath =
      '$chatId/${DateTime.now().microsecondsSinceEpoch.toString()}${path.extension(videoFile.path)}';
  await Supabase.instance.client.storage.from('media').upload(
        mediaPath,
        videoFile,
      );
  await Supabase.instance.client.from('messages').insert(
        Message.newVideoMessageToJson(
          chatId: chatId,
          senderId: senderId,
          videoPath: mediaPath,
        ),
      );
}
