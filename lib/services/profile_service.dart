import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'profiles';

  // Create profile
  Future<void> createProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.uid)
          .set(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get profile by UID
  Future<UserProfile?> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Stream profile untuk real-time updates
  Stream<UserProfile?> getProfileStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Update profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete profile
  Future<void> deleteProfile(String uid) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(uid)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Check if profile exists
  Future<bool> profileExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }
}

