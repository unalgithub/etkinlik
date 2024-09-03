import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deneme/screens/anasayfa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp(BuildContext context, {required String name, required String email, required String password}) async {
    final navigator = Navigator.of(context);
    try {
      // Kullanıcının zaten var olup olmadığını kontrol et
      final existingUser = await userCollection.where('email', isEqualTo: email).get();
      
      if (existingUser.docs.isNotEmpty) {
        // Eğer kullanıcı zaten kayıtlıysa, hata mesajı göster
        Fluttertoast.showToast(msg: "Bu email adresiyle zaten bir hesap var.", toastLength: Toast.LENGTH_LONG);
      } else {
        // Kullanıcı kayıtlı değilse, yeni kullanıcı oluştur
        final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          await _registerUser(name: name, email: email, password: password);
          Fluttertoast.showToast(msg: "Kayıt başarılı!", toastLength: Toast.LENGTH_LONG);
          navigator.push(MaterialPageRoute(builder: (context) => const EventPage()));
        }
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> signIn(BuildContext context, {required String email, required String password}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        navigator.push(MaterialPageRoute(builder: (context) => const EventPage()));
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> _registerUser({required String name, required String email, required String password}) async {
    await userCollection.doc().set({
      "email": email,
      "name": name,
      "password": password
    });
  }
}
