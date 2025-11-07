import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      return image;
    } catch (e) {
      print('Error picking image from gallery: $e');
      rethrow;
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      return image;
    } catch (e) {
      print('Error picking image from camera: $e');
      rethrow;
    }
  }

  // Upload image to Firebase Storage and update user profile
  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Create a reference to the location where we want to upload the file
      final storageRef = _storage.ref().child('profile_images/${user.uid}.jpg');

      // Upload the file
      final File file = File(imageFile.path);
      await storageRef.putFile(file);

      // Get the download URL
      final String downloadURL = await storageRef.getDownloadURL();

      // Update user profile with the photo URL
      await user.updatePhotoURL(downloadURL);
      await user.reload();

      return downloadURL;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Get current user's profile image URL
  String? getCurrentUserPhotoURL() {
    return _auth.currentUser?.photoURL;
  }

  // Delete profile image
  Future<void> deleteProfileImage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Delete from storage
      final storageRef = _storage.ref().child('profile_images/${user.uid}.jpg');
      await storageRef.delete();

      // Remove from user profile
      await user.updatePhotoURL(null);
      await user.reload();
    } catch (e) {
      print('Error deleting profile image: $e');
      rethrow;
    }
  }
}
