// lib/views/pages/profile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_expense/controllers/auth.dart';
import 'package:smart_expense/controllers/profile.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserModel? user;
  bool _isLoading = true;
  bool _isUpdatingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final result = await ProfileController.getProfile();
      if (result.isSuccess && result.results != null) {
        setState(() {
          user = result.results;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        Helper.snackBar(context, message: result.message, isSuccess: false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Helper.snackBar(
        context,
        message: 'Error loading profile: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Profile Image', style: AppStyles.medium(size: 18)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    if (user?.hasProfileImage == true)
                      _buildImageSourceOption(
                        icon: Icons.delete,
                        label: 'Remove',
                        onTap: _deleteProfileImage,
                        color: Colors.red,
                      ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? AppColours.primaryColour).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color ?? AppColours.primaryColour,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.medium(size: 14, color: color ?? Colors.black),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet

    // Check permissions
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isDenied) {
        _showPermissionDialog('Camera');
        return;
      }
    } else {
      final photoStatus = await Permission.storage.request();
      if (photoStatus.isDenied) {
        _showPermissionDialog('Photos');
        return;
      }
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _updateProfileImage(File(image.path));
      }
    } catch (e) {
      Helper.snackBar(
        context,
        message: 'Failed to pick image: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _updateProfileImage(File imageFile) async {
    setState(() => _isUpdatingImage = true);

    try {
      final result = await ProfileController.updateProfileImage(imageFile);

      setState(() => _isUpdatingImage = false);

      if (result.isSuccess && result.results != null) {
        setState(() {
          user = result.results;
        });
        Helper.snackBar(
          context,
          message: 'Profile image updated successfully',
          isSuccess: true,
        );
      } else {
        Helper.snackBar(context, message: result.message, isSuccess: false);
      }
    } catch (e) {
      setState(() => _isUpdatingImage = false);
      Helper.snackBar(
        context,
        message: 'Error updating profile image: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _deleteProfileImage() async {
    Navigator.pop(context); // Close bottom sheet

    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Profile Image'),
            content: Text(
              'Are you sure you want to remove your profile image?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    setState(() => _isUpdatingImage = true);

    try {
      final result = await ProfileController.deleteProfileImage();

      setState(() => _isUpdatingImage = false);

      if (result.isSuccess && result.results != null) {
        setState(() {
          user = result.results;
        });
        Helper.snackBar(
          context,
          message: 'Profile image deleted successfully',
          isSuccess: true,
        );
      } else {
        Helper.snackBar(context, message: result.message, isSuccess: false);
      }
    } catch (e) {
      setState(() => _isUpdatingImage = false);
      Helper.snackBar(
        context,
        message: 'Error deleting profile image: $e',
        isSuccess: false,
      );
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Permission Required'),
            content: Text(
              '$permissionType permission is required to update profile image. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('Settings'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ListView(
                    children: [
                      AppSpacing.vertical(size: 48),
                      Text(AppStrings.profile, style: AppStyles.title1()),
                      AppSpacing.vertical(),
                      _profileImage(),
                      AppSpacing.vertical(),
                      _mainMenu(),
                    ],
                  ),
                ),
      ),
    );
  }

  Container _mainMenu() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.settings,
                      color: AppColours.primaryColour,
                      size: 30,
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(AppStrings.setting, style: AppStyles.medium(size: 18)),
              ],
            ),
          ),
          SizedBox(height: 40, child: Divider(color: Colors.grey.shade300)),
          GestureDetector(
            onTap:
                () => Navigator.of(context).pushNamed(AppRoutes.notification),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.notifications,
                      color: AppColours.primaryColour,
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(
                  AppStrings.notificationSettings,
                  style: AppStyles.medium(size: 18),
                ),
              ],
            ),
          ),
          SizedBox(height: 40, child: Divider(color: Colors.grey.shade300)),
          GestureDetector(
            onTap: () {
              Helper.snackBar(context, message: "Hello", isSuccess: false);
            },
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.subscriptions,
                      color: AppColours.primaryColour,
                    ),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(
                  AppStrings.subscription,
                  style: AppStyles.medium(size: 18),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Divider(height: 40, color: Colors.grey.shade300),
          ),
          GestureDetector(
            onTap: _logout,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.logout, color: Colors.red),
                  ),
                ),
                AppSpacing.horizontal(size: 12),
                Text(
                  AppStrings.logout,
                  style: AppStyles.medium(size: 18, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final result = await AuthController.logout();

    if (!result.isSuccess) {
      Helper.snackBar(context, message: result.message, isSuccess: false);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.walkthrough);
  }

  Container _profileImage() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            user?.hasProfileImage == true
                                ? Image.network(
                                  user!.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                )
                                : _buildDefaultAvatar(),
                      ),
                    ),
                  ),
                  if (_isUpdatingImage)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.horizontal(size: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.username,
                    style: AppStyles.regular1(
                      color: AppColours.light20,
                      size: 14,
                    ),
                  ),
                  Text(
                    user?.name ?? "Loading...",
                    style: AppStyles.medium(size: 24),
                  ),
                  Text(
                    user?.email ?? "Loading...",
                    style: AppStyles.regular1(
                      size: 14,
                      color: AppColours.light20,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 30, color: Colors.black),
            onPressed: _isUpdatingImage ? null : _showImageSourceDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.primaryColour.withAlpha(20),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(Icons.person, size: 40, color: AppColours.primaryColour),
    );
  }
}
