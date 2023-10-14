import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';
import 'package:instagram_flutter/config/paths.dart';
import 'package:instagram_flutter/repositories/auth/base_auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/models/failure_model.dart';

class AuthRepository extends BaseAuthRepository {
  final FirebaseFirestore _firebaseFirestore;
  final auth.FirebaseAuth _firebaseAuth;

  AuthRepository({
    FirebaseFirestore? firebaseFirestore,
    auth.FirebaseAuth? firebaseAuth
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  @override
  Stream<auth.User?> get user => _firebaseAuth.userChanges();

  @override
  Future<auth.User?> signUpWithEmailAndPassword(
      {required String userName,
      required String email,
      required String password}) async {
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = credentials.user;
      _firebaseFirestore.collection(Paths.users).doc(user!.uid).set(
        {
          'username': userName,
          'email': email,
          'followers': 0,
          'following': 0
        }
      );
      return user;
    
    } on auth.FirebaseAuthException catch (authException) {
      throw Failure(code: authException.code, message: authException.message);
    } on PlatformException catch (platformException) {
      throw Failure(code: platformException.code, message: platformException.message!);
    }
  }

  @override
  Future<auth.User?> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return credentials.user;
    } on auth.FirebaseAuthException catch (authException) {
      throw Failure(code: authException.code, message: authException.message!);
    } on PlatformException catch (platformExceptioon) {
      throw Failure(code: platformExceptioon.code, message: platformExceptioon.message);
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
