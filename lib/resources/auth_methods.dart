import 'dart:typed_data';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  //Signup User
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User _user = model.User(
          email: email,          
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          username: username,
          bio: bio,
          followers: [],
          following: [],
        );

        await _firestore.collection("users").doc(cred.user!.uid).set(_user.toJson()  );

        //   await _firestore.collection("users").add({
        //     'username': username,
        //     'uid': cred.user!.uid,
        //     'email': email,
        //     'bio': bio,
        //     'followers': [],
        //     'following': [],

        // });

        res = 'success';
      }
    // } on FirebaseAuthException catch (err) {
    //   if (err.code == 'invalid-email') {
    //     res = "The email is badly formatted";
    //   } else if (err.code == "weak-password") {
    //     res = "Password should be at least 6 characters";
    //   }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  //login

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    }
    // } on FirebaseAuthException catch (e) {
    //   if(e.code == 'user-not-found')
    // }

    catch (err) {
      res = err.toString();
    }
    return res;
  }
}
