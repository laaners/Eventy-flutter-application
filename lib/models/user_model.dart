class UserModel {
  final String uid;
  final String email;
  final String username;
  final String name;
  final String surname;
  final String profilePic;

  static const collectionName = "user";

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.name,
    required this.surname,
    required this.profilePic,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? name,
    String? surname,
    String? profilePic,
    bool? isLightMode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      profilePic: profilePic ?? this.profilePic,
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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      profilePic: map['profilePic'] as String,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, name: $name, surname: $surname, profilePic: $profilePic)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.username == username &&
        other.name == name &&
        other.surname == surname &&
        other.profilePic == profilePic;
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
