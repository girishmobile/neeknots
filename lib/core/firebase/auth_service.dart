import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:neeknots/core/hive/app_config_cache.dart';

import '../../main.dart';
import '../../routes/app_routes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final contactUsCollection = "contact_us";
  final orderFilterCollection = "order_filter";
  final productCollection = "product";
  final storesCollection = "stores";
  late final String storeName; // 🔹 dynamic storeName accessible in all methods

  //--------------------------------------------------------------------------------------------common Collection Store Wise ------------------------------------------------------------
  Future<CollectionReference<Map<String, dynamic>>> getStoreSubCollection(
    String subCollection,
  ) async {
    final config = await AppConfigCache.loadConfig();
    final storeName = config['storeName'] ?? '';

    if (storeName.isEmpty) {
      throw Exception("Store name not found in config");
    }

    final collectionRef = _firestore
        .collection(storeName) // e.g. "merlettenyc-demo"
        .doc(
          subCollection,
        ) // optional — can also use a fixed document name like "root"
        .collection(subCollection); // e.g. "contact_us", "stores", "orders"

    return collectionRef;
  }

  //---------------------------------------------------------------------------------------------For store ------------------------------------------------------------
  Future<Map<String, dynamic>> signupUser({
    required String email,
    required String storeName,
    required String websiteUrl,
    required String mobile,
    required String logoUrl,
    required String name,
    String? countryCode,
    File? photo,
  }) async {
    try {
      final existing = await _firestore
          .collection(storesCollection)
          .where("email", isEqualTo: email)
          .get();
      if (existing.docs.isNotEmpty) {
        throw "Email already exists";
      }

      final docRef = _firestore.collection(storesCollection).doc();
      String uid = docRef.id;

      /*     String photoUrl = "";
      if (photo != null) {
        final ref = _storage.ref().child("store_photos").child("$uid.jpg");
        await ref.putFile(photo);
        photoUrl = await ref.getDownloadURL();
      }*/

      // Get FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Save user data
      Map<String, dynamic> userData = {
        "store_name": storeName,
        "website_url": websiteUrl,
        "email": email,
        "mobile": mobile,
        "name": name,
        "accessToken": '',
        "version_code": '',
        "logo_url": '',
        "photo": '',
        "country_code": countryCode ?? "+1",
        "fcm_token": fcmToken ?? "",
        "active_status": false,
        "created_at": FieldValue.serverTimestamp(),
      };

      await docRef.set(userData);
      userData["uid"] = uid; // return uid
      return userData;
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  /// 🔹 Login User with Email + Mobile
  Future<Map<String, dynamic>>  loginUser({
    required String email,
    required String mobile,
    required String countryCode,
  }) async {
    try {
      // Check Firestore for a document matching BOTH email and mobile
      final query = await _firestore
          .collection(storesCollection)
          .where("email", isEqualTo: email)
          .where("mobile", isEqualTo: mobile)
          .where("country_code", isEqualTo: countryCode)
          .get();
      if (query.docs.isEmpty) {
        throw "User not found with this email and mobile number";
      }

      final data = query.docs.first.data();

      if (data["active_status"] != true) {
        throw "Your account is inactive. Contact admin.";
      }

      data["uid"] = query.docs.first.id; // add UID
      return data;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  /// 🔹 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>> checkUserStatus({
    required String emailOrMobile,
  }) async {
    try {
      // 1️⃣ Check by email
      final query = await _firestore
          .collection(storesCollection)
          .where("email", isEqualTo: emailOrMobile)
          .get();

      List<QueryDocumentSnapshot> docs = query.docs;

      // 2️⃣ If email not found, check by mobile
      if (docs.isEmpty) {
        final mobileQuery = await _firestore
            .collection(storesCollection)
            .where("mobile", isEqualTo: emailOrMobile)
            .get();

        if (mobileQuery.docs.isEmpty) {
          throw "Unauthorized: User not found";
        }

        docs = mobileQuery.docs;
      }

      // 3️⃣ Get first user document
      final data = docs.first.data() as Map<String, dynamic>;

      // 4️⃣ Check active_status
      if (data["active_status"] != true) {
        throw "Unauthorized: Account inactive";
      }

      // 5️⃣ Add UID
      data["uid"] = docs.first.id;

      return data;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Delete user from Firestore (and optionally Firebase Auth)
  Future<void> deleteUser({required String uid}) async {
    try {
      await _firestore.collection(storesCollection).doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Example usage in a button or any widget
  Future<void> deleteCurrentUser({
    required BuildContext context,
    required String uid,
  }) async {
    final authService = AuthService();

    try {
      await authService.deleteUser(uid: uid);

      // 1️⃣ Show success message
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text("Your account has been deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );

      // 2️⃣ Wait a short moment to show the message
      await Future.delayed(Duration(seconds: 2));

      await AppConfigCache.clearConfig();
      // 3️⃣ Redirect to login screen
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        RouteName.loginScreen,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text("Failed to delete account: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String userID,
    required String enteredOtp,
  }) async {
    try {
      // 1️⃣ Get the user document from Firestore
      final docRef = _firestore.collection(storesCollection).doc(userID);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw "User not found";
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      //for Demo user
      final String email = (data["email"] ?? "").toString().toLowerCase();
      final storedOtp = data["otp"];
      // ✅ Demo user check by email
      final bool isDemoUser = email == "girishchauhan@gmail.com";

      if (!isDemoUser) {
        if (!data.containsKey("otp")) {
          throw "OTP not found. Please request a new OTP.";
        }

        final Timestamp otpCreatedAt = data["otp_created_at"];

        // 3️⃣ Optional: check OTP expiry (e.g., 15 minutes)
        final currentTime = DateTime.now();
        final otpTime = otpCreatedAt.toDate();
        if (currentTime.difference(otpTime).inMinutes > 15) {
          throw "OTP expired. Please request a new OTP.";
        }
      }
      // 2️⃣ Check if OTP exists

      // 4️⃣ Verify OTP
      if (storedOtp == enteredOtp) {
        // OTP is correct, mark user as active
        await docRef.update({
          "active_status": true,
          "otp": FieldValue.delete(),
          "otp_created_at": FieldValue.delete(),
        });

        // 5️⃣ Return user details
        final updatedDoc = await docRef.get();
        final userData = updatedDoc.data() as Map<String, dynamic>;
        userData["uid"] = updatedDoc.id; // Include UID
        return userData;
      } else {
        throw "Invalid OTP. Please try again.";
      }
    } catch (e) {
      throw Exception("OTP verification failed: $e");
    }
  }

  Future<void> updateFcm({
    required String userID,
    required String fcmToken,
  }) async {
    try {
      // 1️⃣ Get the user document from Firestore
      final docRef = _firestore.collection(storesCollection).doc(userID);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw "User not found";
      }

      await docRef.update({"fcm_token": fcmToken});
    } catch (e) {
      throw Exception("OTP verification failed: $e");
    }
  }

  /// 🔹 Get all users from Firestore
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection(storesCollection).get();

      if (querySnapshot.docs.isEmpty) {
        return []; // No users found
      }

      // Map each document to a Map<String, dynamic> including its UID
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data["uid"] = doc.id; // Add UID
        return data;
      }).toList();

      return users;
    } catch (e) {
      throw Exception("Failed to fetch users: $e");
    }
  }

  Future<void> insetContactUSForm({
    required String email,

    required String message,
    required String mobile,
    required String name,
  }) async {
    try {
      final contactCollection = await getStoreSubCollection(
        contactUsCollection,
      );

      final docRef = contactCollection.doc();
      final uid = docRef.id;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      Map<String, dynamic> userData = {
        "uid": uid,
        "email": email,
        "mobile": mobile,
        "name": name,
        "message": message,
        "isSeen": false, // 👈 ye flag add karna hoga
        "fcm_token": fcmToken ?? "",
        "created_at": FieldValue.serverTimestamp(),
      };

      await docRef.set(userData);
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  //============================================contactUs==============================================================//
  Future<List<Map<String, dynamic>>> getAllContactList() async {
    try {
      final contactCollection = await getStoreSubCollection(
        contactUsCollection,
      );

      final storeSnapshot = await contactCollection.get();

      final allContacts = storeSnapshot.docs.map((doc) {
        final data = doc.data();
        data["uid"] = doc.id; // add document ID
        return data;
      }).toList();

      return allContacts; // ✅ return the list
    } catch (e) {
      throw Exception("Failed to fetch contacts: $e");
    }
  }

  Future<int?> getUnseenContactCount() async {
    final contactCollection = await getStoreSubCollection(contactUsCollection);

    try {
      // 🔹 Create aggregate query
      final aggregateQuery = contactCollection
          .where("isSeen", isEqualTo: false)
          .count();

      // 🔹 Await the result
      final snapshot = await aggregateQuery.get();

      final count = snapshot.count; // ✅ now it's defined
      return count;
    } catch (e) {
      debugPrint("❌ Failed to fetch unseen count: $e");
      //_contactCount = 0;
    }
    return null;
  }

  Future<void> markAllAsSeen() async {
    try {
      WriteBatch batch = _firestore.batch();
      final contactCollection = await getStoreSubCollection(
        contactUsCollection,
      );
      final querySnapshot = await contactCollection.get();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {"isSeen": true});
      }

      await batch.commit();
      debugPrint("✅ All contacts marked as seen");
    } catch (e) {
      debugPrint("❌ Failed to mark all as seen: $e");
    }
  }

  //============================================End==============================================================//

  //============================================Order Filter==============================================================//

  Future<List<Map<String, dynamic>>> getAllFilterOrderList() async {
    try {
      final contactCollection = await getStoreSubCollection(
        orderFilterCollection,
      );

      final storeSnapshot = await contactCollection.get();

      final allContacts = storeSnapshot.docs.map((doc) {
        final data = doc.data();
        data["uid"] = doc.id; // add document ID
        return data;
      }).toList();

      return allContacts; // ✅ return the list
    } catch (e) {
      throw Exception("Failed to fetch contacts: $e");
    }
  }
}
