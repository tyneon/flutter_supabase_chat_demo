import 'package:flutter/material.dart';
import 'package:chat_message_timestamp/chat_message_timestamp.dart';

import 'package:supabase_chat/models/message.dart';

const bubblePadding = EdgeInsets.all(8);
const bubbleRadius = Radius.circular(15);
const bubbleMargin = 50.0;

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
          child: TimestampedChatMessage(
            text: message.text,
            sentAt: message.timestampString,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }
}
