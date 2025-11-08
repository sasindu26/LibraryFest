import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _studentIndexController = TextEditingController();
  bool _isLoading = false;
  bool _hasExistingIndex = false;
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
      
      // Load additional data from Firestore
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          _phoneController.text = data?['phone'] ?? '';
          _addressController.text = data?['address'] ?? '';
          _studentIndexController.text = data?['studentIndex'] ?? '';
          _hasExistingIndex = (data?['studentIndex'] ?? '').isNotEmpty;
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Upload immediately after selecting
        await _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      // Upload the file
      await storageRef.putFile(_selectedImage!);

      // Get the download URL
      final downloadURL = await storageRef.getDownloadURL();

      // Update user's photoURL in Firebase Auth
      await user.updatePhotoURL(downloadURL);

      // Update photoURL in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoURL': downloadURL});

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Change Profile Photo',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF007AFF),
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5856D6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF5856D6),
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (FirebaseAuth.instance.currentUser?.photoURL != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF3B30),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removeProfilePhoto();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeProfilePhoto() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Delete from Firebase Storage if exists
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        await storageRef.delete();
      } catch (e) {
        // File might not exist, ignore error
      }

      // Remove photoURL from Firebase Auth
      await user.updatePhotoURL(null);

      // Remove photoURL from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoURL': FieldValue.delete()});

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final studentIndex = _studentIndexController.text.trim();
          
          // Check if user is admin
          final isAdmin = user.email?.toLowerCase().contains('admin') ?? false;
          
          // Check if student index is unique (if it's being set for the first time or changed)
          // Skip this check for admins as they don't need student index
          if (!isAdmin && studentIndex.isNotEmpty && !_hasExistingIndex) {
            final existingIndex = await FirebaseFirestore.instance
                .collection('users')
                .where('studentIndex', isEqualTo: studentIndex)
                .limit(1)
                .get();
            
            if (existingIndex.docs.isNotEmpty) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This university index number is already registered!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              setState(() {
                _isLoading = false;
              });
              return;
            }
          }
          
          // Update display name in Firebase Auth
          await user.updateDisplayName(_displayNameController.text.trim());

          // Update all fields in Firestore
          final updateData = {
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'displayName': _displayNameController.text.trim(),
            'email': user.email,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          
          // Only set student index if it's new (can't change once set)
          // For admins, set empty string if not provided
          if (!_hasExistingIndex) {
            if (isAdmin) {
              // Admins don't need student index
              updateData['studentIndex'] = studentIndex.isNotEmpty ? studentIndex : '';
            } else if (studentIndex.isNotEmpty) {
              // Regular users must provide student index
              updateData['studentIndex'] = studentIndex;
            }
          }
          
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(updateData, SetOptions(merge: true));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Return true to indicate successful save
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _studentIndexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email?.toLowerCase().contains('admin') ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.35,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.white,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (user?.photoURL != null
                                    ? NetworkImage(user!.photoURL!)
                                    : null) as ImageProvider?,
                            child: _isUploadingImage
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                                  )
                                : (user?.photoURL == null && _selectedImage == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 56,
                                        color: Color(0xFF007AFF),
                                      )
                                    : null),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploadingImage ? null : _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007AFF).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'User',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.36,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: user?.email?.toLowerCase().contains('admin') ?? false
                            ? const Color(0xFF5856D6).withOpacity(0.1)
                            : const Color(0xFF007AFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: user?.email?.toLowerCase().contains('admin') ?? false
                              ? const Color(0xFF5856D6)
                              : const Color(0xFF007AFF),
                        ),
                      ),
                      child: Text(
                        user?.email?.toLowerCase().contains('admin') ?? false
                            ? 'Admin Account'
                            : 'Member Account',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: user?.email?.toLowerCase().contains('admin') ?? false
                              ? const Color(0xFF5856D6)
                              : const Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account Information Section
              Text(
                'Account Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 16),

              // Email (read-only)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  initialValue: user?.email ?? '',
                  enabled: false,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      letterSpacing: -0.08,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.email_rounded,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                    ),
                    suffixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Display Name
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _displayNameController,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      letterSpacing: -0.08,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF007AFF),
                        size: 22,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF007AFF),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF3B30),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your display name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      letterSpacing: -0.08,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.phone_rounded,
                        color: Color(0xFF34C759),
                        size: 22,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF34C759),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Address
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      letterSpacing: -0.08,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Color(0xFFFF9500),
                        size: 22,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF9500),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Student Index Number
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _studentIndexController,
                  enabled: !_hasExistingIndex,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: _hasExistingIndex ? Colors.grey[700] : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: isAdmin 
                        ? 'University Index Number (Optional)' 
                        : 'University Index Number',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                      letterSpacing: -0.08,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.badge_rounded,
                        color: _hasExistingIndex ? Colors.grey[400] : const Color(0xFF5856D6),
                        size: 22,
                      ),
                    ),
                    suffixIcon: _hasExistingIndex ? Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ) : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF5856D6),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF3B30),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: _hasExistingIndex ? Colors.grey[50] : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    // For admins, university index is optional
                    if (isAdmin) {
                      // If provided, validate format
                      if (value != null && value.isNotEmpty && value.length < 5) {
                        return 'Please enter a valid index number';
                      }
                      return null; // Optional for admins
                    }
                    
                    // For regular users, university index is required
                    if (value == null || value.isEmpty) {
                      return 'Please enter your university index number';
                    }
                    if (value.length < 5) {
                      return 'Please enter a valid index number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Info message about student index
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF007AFF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Color(0xFF007AFF),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _hasExistingIndex 
                            ? 'Your university index number cannot be changed. Contact library officers if you need assistance.'
                            : isAdmin
                                ? 'As an admin, the university index is optional. If you provide one, it can only be set once.'
                                : 'Your index number can only be set once and cannot be changed. Each index number can only have one account.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF007AFF),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Info Card - Moved above Save Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF007AFF).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Color(0xFF007AFF),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your email cannot be changed. Contact support if you need assistance.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF007AFF),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Save Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Save Changes',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.41,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
