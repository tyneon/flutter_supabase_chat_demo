import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const Message._();
  factory Message({
    required int id,
    required int senderId,
    required int chatId,
    required DateTime timestamp,
    required String text,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        senderId: json['senderId'],
        chatId: json['chatId'],
        timestamp: DateTime.parse(json['timestamp'] as String),
        text: json['text'],
      );

  static Map<String, dynamic> newMessageToJson({
    required int senderId,
    required int chatId,
    required String text,
  }) =>
      {
        'senderId': senderId,
        'text': text,
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
