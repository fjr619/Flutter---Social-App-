/*

USER PROFILE

This is what every user should have for their profile.

____________________________

- uid
- name
- email
- username
- bio
- profile photo (we'll do at the end since it requires extra stuff)

 */

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String bio;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
  });

  /*
  firebase -> app
  convert firestore document to user profile so that we can use in our app
   */

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
        uid: doc['uid'],
        name: doc['name'],
        email: doc['email'],
        username: doc['username'],
        bio: doc['bio']);
  }

  /// app -> firebase
  /// convert user profile to map so that we can store in firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? username,
    String? bio,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
    );
  }
}
