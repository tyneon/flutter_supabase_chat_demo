import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  text,
  image,
  video,
}

MessageType _stringToMessageType(String type) {
  switch (type) {
    case 'image':
      return MessageType.image;
    case 'video':
      return MessageType.video;
    default:
      return MessageType.text;
  }
}

@freezed
class Message with _$Message {
  const Message._();
  factory Message({
    required int id,
    required int senderId,
    required int chatId,
    required DateTime timestamp,
    required MessageType type,
    required String text,
    required String? mediaPath,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        senderId: json['senderId'],
        chatId: json['chatId'],
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: _stringToMessageType(json['type']),
        text: json['text'] ?? '',
        mediaPath: json['mediaPath'],
      );

  static Map<String, dynamic> newTextMessageToJson({
    required int senderId,
    required int chatId,
    required String text,
  }) =>
      {
        'chatId': chatId,
        'senderId': senderId,
        'text': text,
      };

  static Map<String, dynamic> newImageMessageToJson({
    required int senderId,
    required int chatId,
    required String imagePath,
  }) =>
      {
        'chatId': chatId,
        'senderId': senderId,
        'type': 'image',
        'mediaPath': imagePath,
      };

  static Map<String, dynamic> newVideoMessageToJson({
    required int senderId,
    required int chatId,
    required String videoPath,
  }) =>
      {
        'chatId': chatId,
        'senderId': senderId,
        'type': 'video',
        'mediaPath': videoPath,
      };

  DateTime get groupDateTime {
    return DateTime(timestamp.year, timestamp.month, timestamp.day);
  }

  String get timestampString {
    return DateFormat('HH:mm').format(timestamp);
  }

  static String groupDateTimeString(DateTime day) {
    if (_isToday(day)) return "Today";
    return DateFormat(_dateFormat(day)).format(day);
  }

  static bool _isToday(DateTime dateTime) {
    return (dateTime.day == DateTime.now().day &&
        dateTime.month == DateTime.now().month &&
        dateTime.year == DateTime.now().year);
  }

  static bool _isTodayIsh(DateTime dateTime) {
    return (dateTime.day == DateTime.now().day &&
            dateTime.month == DateTime.now().month &&
            dateTime.year == DateTime.now().year) ||
        DateTime.now().difference(dateTime).inHours < 12;
  }

  static String _dateFormat(DateTime dateTime) {
    if (DateTime.now().difference(dateTime).inDays < 6) {
      // Show weekday if it's been less than a week
      return 'EEEE';
    } else {
      // Show full date if it's been longer
      if (dateTime.year != DateTime.now().year) {
        // Show year if it's relevant
        return 'MMM d y';
      } else {
        return 'MMM d';
      }
    }
  }
}
