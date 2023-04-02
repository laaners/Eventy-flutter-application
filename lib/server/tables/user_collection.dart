class UserCollection {
  final String uid;
  final String email;
  final String username;
  final String name;
  final String surname;
  final String profilePic;
  final bool isLightMode;

  static const collectionName = "user";

  UserCollection({
    required this.uid,
    required this.email,
    required this.username,
    required this.name,
    required this.surname,
    required this.profilePic,
    required this.isLightMode,
  });

  UserCollection copyWith({
    String? uid,
    String? email,
    String? username,
    String? name,
    String? surname,
    String? profilePic,
    bool? isLightMode,
  }) {
    return UserCollection(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      profilePic: profilePic ?? this.profilePic,
      isLightMode: isLightMode ?? this.isLightMode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'username': username,
      'name': name,
      'surname': surname,
      'profilePic': profilePic,
      'isLightMode': isLightMode,
    };
  }

  factory UserCollection.fromMap(Map<String, dynamic> map) {
    return UserCollection(
      uid: map['uid'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      profilePic: map['profilePic'] as String,
      isLightMode: map['isLightMode'] as bool,
    );
  }

  @override
  String toString() {
    return 'UserCollection(uid: $uid, email: $email, username: $username, name: $name, surname: $surname, profilePic: $profilePic, isLightMode: $isLightMode)';
  }

  @override
  bool operator ==(covariant UserCollection other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.username == username &&
        other.name == name &&
        other.surname == surname &&
        other.profilePic == profilePic &&
        other.isLightMode == isLightMode;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        username.hashCode ^
        name.hashCode ^
        surname.hashCode ^
        profilePic.hashCode;
  }
}
