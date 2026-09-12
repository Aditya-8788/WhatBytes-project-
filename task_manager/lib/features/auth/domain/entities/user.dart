class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}