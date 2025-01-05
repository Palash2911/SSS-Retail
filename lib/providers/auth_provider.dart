import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  var _token = '';
  var verificationId = '';
  var _userName = '';
  var _phoneNo = '';
  var _dealerShipName = '';
  var _isAdmin = false;

  bool get isAuth {
    return _auth.currentUser?.uid != null ? true : false;
  }

  bool get isAdmin {
    return _isAdmin;
  }

  String get token {
    return _token;
  }

  String get userName {
    return _userName;
  }

  String get dealShipName {
    return _dealerShipName;
  }

  String get phoneNo {
    return _phoneNo;
  }

  Future<void> authenticate(String phoneNo) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print("Invalid Number");
          } else {
            print(e);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
      _phoneNo = _auth.currentUser!.phoneNumber!;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendOtp() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _auth.currentUser!.phoneNumber ?? "",
      verificationCompleted: (PhoneAuthCredential credential) async {
        // await _auth.currentUser!.linkWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      var cred = await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      _token = _auth.currentUser!.uid;
      _phoneNo = _auth.currentUser!.phoneNumber!;
      prefs.setString('UID', _token);
      prefs.setString("UserName", "");
      prefs.setString("UserName", "");
      prefs.setBool("IsAdmin", false);
      prefs.setString("PhoneNo", _phoneNo);

      notifyListeners();
      return cred.user != null ? true : false;
    } catch (e) {
      print('Mein error  $e');
      rethrow;
    }
  }

  Future<int> checkUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      final currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null) {
        return -1;
      }

      final userSnapshot = await users.doc(currentUserId).get();
      if (userSnapshot.exists) {
        prefs.setString("UserName", userSnapshot['Name']);
        prefs.setString("PhoneNo", userSnapshot['Contact']);
        prefs.setString("DealerShipName", userSnapshot['DealerShipName']);
        prefs.setBool("IsAdmin", false);
        prefs.setString('UID', _auth.currentUser!.uid);
        _userName = userSnapshot['Name'];
        _phoneNo = userSnapshot['Contact'];
        return 0;
      }

      final adminQuery = await users
          .where('Contact', isEqualTo: _auth.currentUser?.phoneNumber)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        final adminSnapshot = adminQuery.docs.first;
        prefs.setString("UserName", adminSnapshot['Name']);
        prefs.setString("PhoneNo", adminSnapshot['Contact']);
        prefs.setString('UID', _auth.currentUser!.uid);
        prefs.setString("DealerShipName", 'SWAMI SAMARTHA ENT');
        prefs.setBool("IsAdmin", true);
        _userName = adminSnapshot['Name'];
        _phoneNo = adminSnapshot['Contact'];
        _token = _auth.currentUser!.uid;
        return 1;
      }

      return -1;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _auth.signOut();
    } catch (e) {
      print(e);
      rethrow;
    }
    notifyListeners();
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('UID') ||
        !prefs.containsKey('UserName') ||
        !prefs.containsKey('PhoneNo') ||
        !prefs.containsKey('DealerShipName') ||
        !prefs.containsKey('IsAdmin')) {
      return;
    }
    _token = prefs.getString('UID')!;
    _userName = prefs.getString("UserName")!;
    _phoneNo = prefs.getString("PhoneNo")!;
    _dealerShipName = prefs.getString("DealerShipName")!;
    _isAdmin = prefs.getBool("IsAdmin")!;
    notifyListeners();
  }

  Future<void> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('UID')!;
    _userName = prefs.getString("UserName")!;
    _phoneNo = prefs.getString("PhoneNo")!;
    _dealerShipName = prefs.getString("DealerShipName")!;
    _isAdmin = prefs.getBool("IsAdmin")!;
    notifyListeners();
  }
}
