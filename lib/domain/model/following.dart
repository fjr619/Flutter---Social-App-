import 'package:cloud_firestore/cloud_firestore.dart';

class Following {
  final String username;
  final String uid;
  final String name;

  Following({
    required this.username,
    required this.uid,
    required this.name,
  });

  // Convert a Following object into a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uid': uid,
      'name': name,
    };
  }

  // Optional: Create a Following object from a Firestore DocumentSnapshot
  factory Following.fromDocument(DocumentSnapshot doc) {
    return Following(
      username: doc['username'],
      uid: doc['uid'],
      name: doc['name'],
    );
  }
}
