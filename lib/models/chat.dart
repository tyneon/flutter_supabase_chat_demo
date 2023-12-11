import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';

@freezed
class Chat with _$Chat {
  factory Chat({
    required int id,
    required int otherUserId,
  }) = _Chat;
}
