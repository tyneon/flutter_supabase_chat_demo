import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_user.freezed.dart';
part 'chat_user.g.dart';

@freezed
class ChatUser with _$ChatUser {
  const ChatUser._();
  factory ChatUser({
    required int id,
    required String name,
    required String email,
    required List<int> chatIds,
    // required String avatarUrl, // TODO
  }) = _ChatUser;
  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
}
