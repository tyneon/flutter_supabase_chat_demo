import 'package:flutter/material.dart';
import 'package:chat_message_timestamp/chat_message_timestamp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_chat/models/message.dart';
import 'package:supabase_chat/providers/chat_messages_provider.dart';

const bubblePadding = EdgeInsets.all(8);
const bubbleRadius = Radius.circular(15);
const imageBorderRadiusValue = 3.0;
const bubbleMargin = 50.0;
const sentAtTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
);

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool weAreSender;
  const MessageBubble(
    this.message, {
    this.weAreSender = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    late Widget messageBubble;
    switch (message.type) {
      case "text":
        {
          messageBubble = TimestampedChatMessage(
            text: message.text,
            sentAt: message.timestampString,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onBackground,
            ),
            sentAtStyle: sentAtTextStyle,
          );
          break;
        }
      case "image":
        {
          messageBubble = MediaChatMessage(
            mediaPath: message.mediaPath!,
            sentAt: message.timestampString,
          );
          break;
        }
      default:
        messageBubble = TimestampedChatMessage(
          text: "error detecting message type",
          sentAt: message.timestampString,
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.error,
          ),
        );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Align(
        alignment: weAreSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: bubblePadding,
          decoration: BoxDecoration(
            color: weAreSender
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: bubbleRadius,
              topRight: bubbleRadius,
              bottomLeft: weAreSender ? bubbleRadius : Radius.zero,
              bottomRight: weAreSender ? Radius.zero : bubbleRadius,
            ),
          ),
          child: messageBubble,
        ),
      ),
    );
  }
}

class MediaChatMessage extends ConsumerWidget {
  final String mediaPath;
  final String sentAt;
  const MediaChatMessage({
    required this.mediaPath,
    required this.sentAt,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaAsyncValue = ref.watch(chatMediaMemoryDataProvider(mediaPath));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        mediaAsyncValue.isLoading
            ? SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.background,
                  ),
                ),
              )
            : (mediaAsyncValue.hasError || mediaAsyncValue.value == null)
                ? Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                  )
                : Container(
                    constraints: BoxConstraints(
                      minHeight: 100,
                      minWidth: 100,
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(imageBorderRadiusValue),
                      child: Image.memory(mediaAsyncValue.value!),
                    ),
                  ),
        Text(
          sentAt,
          style: sentAtTextStyle,
        ),
      ],
    );
  }
}
