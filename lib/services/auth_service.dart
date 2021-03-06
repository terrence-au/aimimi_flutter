import 'package:aimimi/services/user_document.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:aimimi/models/user.dart";

class AuthService extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool _isSigningIn;

  AuthService() {
    _isSigningIn = false;
  }

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  OurUser _createUser(User user) {
    return user != null
        ? OurUser(uid: user.uid, username: user.displayName)
        : null;
  }

  Stream<OurUser> get user {
    return FirebaseAuth.instance.userChanges().map(_createUser);
  }

  Future signUp(
      String email, String password, String name, BuildContext context) async {
    isSigningIn = true;

    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await auth.currentUser.updateProfile(displayName: name);
      await UserDocument(uid: auth.currentUser.uid).createUserDocuments(
          FieldValue.serverTimestamp(), name, auth.currentUser.photoURL);
      isSigningIn = false;
      return _createUser(result.user);
    } catch (e) {
      showError(e.message, context);
      print(e);
      isSigningIn = false;
    }
  }

  Future emailLogin(String email, String password, BuildContext context) async {
    isSigningIn = true;

    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      isSigningIn = false;
      return _createUser(result.user);
    } catch (e) {
      showError(e.message, context);
      print(e);
      isSigningIn = false;
    }
  }

  showError(String errormessage, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future googleLogin() async {
    isSigningIn = true;

    if (googleSignIn.currentUser != null) {
      await googleSignIn.signOut();
    }

    final user = await googleSignIn.signIn();

    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Update Firebase auth info from Google
      await auth.currentUser.updateProfile(
          displayName: user.displayName, photoURL: user.photoUrl);

      await UserDocument(uid: auth.currentUser.uid).createUserDocuments(
          FieldValue.serverTimestamp(),
          result.user.displayName,
          result.user.photoURL);
      isSigningIn = false;

      return _createUser(result.user);
    }
  }

  Future appleSignIn(BuildContext context) async {
    if (!await AppleSignIn.isAvailable()) {
      showError("Apple sign in is not available on this device", context);
      return;
    }
    print("do what?");

    final result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    print("result" + result.toString());
    switch (result.status) {
      case AuthorizationStatus.authorized:
        try {
          final AppleIdCredential appleIdCredential = result.credential;
          final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
          final credential = oAuthProvider.credential(
              idToken: String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
                  String.fromCharCodes(appleIdCredential.authorizationCode));

          UserCredential res =
              await FirebaseAuth.instance.signInWithCredential(credential);

          print("Apple" + appleIdCredential.toString());

          // Update Firebase auth info from Google
          await auth.currentUser.updateProfile(
              displayName:
                  "${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}",
              photoURL: null);

          await UserDocument(uid: auth.currentUser.uid).createUserDocuments(
              FieldValue.serverTimestamp(),
              "${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}",
              null);

          return _createUser(res.user);
        } on PlatformException catch (error) {
          showError(error.message, context);
        } on FirebaseAuthException catch (error) {
          showError(error.message, context);
        }
        break;
      case AuthorizationStatus.error:
        showError("Apple authorization failed", context);
        break;
      case AuthorizationStatus.cancelled:
        break;
    }
  }

  Future logout() async {
    if (auth.currentUser.providerData[0].providerId == 'google.com') {
      return await Future.wait([
        FirebaseAuth.instance.signOut(),
        googleSignIn.disconnect(),
      ]);
    }
    return FirebaseAuth.instance.signOut();
  }
}
