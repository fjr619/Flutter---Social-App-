// /*

// AUTHENTICATION SERVICE

// This handles everything to do with authentication in firebase

// __________________________

// - login
// - register
// - logout
// - delete account (required if you want to publish to app store)

// */

// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   // get instance of the auth
//   final _auth = FirebaseAuth.instance;

//   // get current user & uid
//   User? get currentUser => _auth.currentUser;
//   String get currentUid => currentUser?.uid ?? "";

//   //login -> email and password
//   Future<UserCredential> loginEmailPassword(
//       String email, String password) async {
//     // attempt login
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return userCredential;
//     }

//     // catch any errors
//     on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }

//   // register
//   Future<UserCredential> registerEmailPassword(
//       String email, String password) async {
//     // attemp to register new user
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }

//   // logout
//   Future<void> logout() async {
//     await _auth.signOut();
//   }

//   // delete account
  
// }
