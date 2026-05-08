import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../l10n/app_localizations.dart';
import 'profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _bioController = TextEditingController(text: profile.bio);
    _selectedImagePath = profile.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      ref
          .read(profileProvider.notifier)
          .updateProfile(
            name: _nameController.text,
            email: _emailController.text,
            bio: _bioController.text,
            avatarPath: _selectedImagePath,
            removeImage: _removeImage,
          );

      AppSnackbar.showSuccess(context, l10n.profileUpdated);
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        if (await file.exists()) {
          setState(() {
            _selectedImagePath = image.path;
          });
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Image selected successfully');
          }
        } else {
          throw Exception('Selected file not found');
        }
      }
    } on Exception catch (e) {
      print('Image picker error: $e');
      if (mounted) {
        _showPermissionHelpDialog();
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Choose Profile Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from Gallery', 
                style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context, 'gallery');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take a Photo', 
                style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context, 'camera');
              },
            ),
            if (_selectedImagePath != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('Remove Photo', 
                  style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context, 'remove');
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (result == 'gallery') {
      await _pickImage();
    } else if (result == 'camera') {
      await _takePhoto();
    } else if (result == 'remove') {
      setState(() {
        _selectedImagePath = null;
        _removeImage = true;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        if (await file.exists()) {
          setState(() {
            _selectedImagePath = image.path;
          });
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Photo taken successfully');
          }
        }
      }
    } on Exception catch (e) {
      print('Camera error: $e');
      if (mounted) {
        _showPermissionHelpDialog();
      }
    }
  }

  void _showPermissionHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          title: const Text(
            'Permission Required',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'TruthLens needs permission to access your photos and camera.\n\nPlease enable Camera and Photos permissions in your device settings.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020617), Color(0xFF0A2540)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Edit Profile',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                            FutureBuilder<SharedPreferences>(
                              future: SharedPreferences.getInstance(),
                              builder: (context, snapshot) {
                                final lastKnown = snapshot.data?.getString('last_known_avatar');
                                final localVault = snapshot.data?.getString('local_avatar_vault');
                                final finalPath = (_selectedImagePath != null && _selectedImagePath!.isNotEmpty && !_selectedImagePath!.endsWith('/storage/'))
                                    ? _selectedImagePath
                                    : (lastKnown != null && lastKnown.isNotEmpty && !lastKnown.endsWith('/storage/') ? lastKnown : localVault);

                                return Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: finalPath != null
                                          ? ClipOval(
                                              child: Image(
                                                image: finalPath.startsWith('http')
                                                    ? NetworkImage(finalPath)
                                                    : FileImage(File(finalPath)) as ImageProvider,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  // Fallback to local vault if network fails
                                                  if (localVault != null) {
                                                    return ClipOval(
                                                      child: Image.file(
                                                        File(localVault),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (c, e, s) => const Icon(Icons.person, size: 60, color: Colors.white),
                                                      ),
                                                    );
                                                  }
                                                  return const Icon(Icons.person, size: 60, color: Colors.white);
                                                },
                                              ),
                                            )
                                          : const Icon(Icons.person, size: 60, color: Colors.white),
                                    ),
                                if (finalPath != null)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImagePath = null;
                                          _removeImage = true;
                                        });
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.9),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _showImageSourceDialog,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.primary,
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your email';
                            }
                            if (!value!.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _bioController,
                          label: 'Bio',
                          icon: Icons.info_outline,
                          maxLines: 4,
                          hint: 'Tell us about yourself...',
                        ),

                        const SizedBox(height: 32),

                        GestureDetector(
                          onTap: _saveProfile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly ? Colors.white.withValues(alpha: 0.5) : Colors.white,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: AppColors.secondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }
}
