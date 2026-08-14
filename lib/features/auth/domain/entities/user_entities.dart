import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isGuest = false,
  });

  /// Safe name to show in the UI — falls back for guests.
  String get greetingName {
    if (isGuest) return 'Guest';
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim().split(' ').first;
    }
    return email.split('@').first;
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isGuest];
}