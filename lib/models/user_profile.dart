class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? bio;
  final String? phoneNumber;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    this.phoneNumber,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'phoneNumber': phoneNumber,
    };
  }

  // Create from Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      bio: map['bio'],
      phoneNumber: map['phoneNumber'],
    );
  }

  // Copy with method for updates
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? bio,
    String? phoneNumber,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

