import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/core/widgets/common/app_top_bar.dart';
import 'package:magic_enlish/core/utils/snackbar_utils.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';
import 'package:magic_enlish/data/models/auth/ResponseLogin.dart';
import 'dart:io';
import 'package:magic_enlish/data/services/file_service.dart';
import 'package:magic_enlish/data/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String _avatarUrl = '';
  String _avatarDisplayUrl = '';
  bool _isLocalAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    // Prefer backend-provided avatar (filename or full URL) when available
    final rawAvatar = user?.avatarUrl;
    if (rawAvatar != null && rawAvatar.isNotEmpty) {
      _avatarUrl = rawAvatar; // raw may be filename or full URL
      _avatarDisplayUrl = _computeDisplayUrl(rawAvatar);
      final uri = Uri.tryParse(_avatarDisplayUrl);
      _isLocalAvatar =
          uri == null || uri.scheme.isEmpty || uri.scheme == 'file';
    } else if (user != null && user.name.isNotEmpty) {
      // fallback to generated avatar based on name
      _avatarUrl = _defaultAvatar(user.name);
      _avatarDisplayUrl = _avatarUrl;
      _isLocalAvatar = false;
    } else {
      // fallback placeholder
      _avatarUrl =
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCwjU4CsVdt2VEZUWSxL3Bn7cWu3vczpiZduN16hF5Tinakk5hqQY0APafoANhjTIWQt38yD1hmxuUZnRzF9SOQHQzDKapvXzD6W1wo4od6FEeyio-wAkRmRhBaf0fZGGNlIioVT-_Ec8SzErktYBEQ6QfN-2yhwqvc-qBhud5N7XXDPCj0Ogu9HpsXXsCXodL5l4BlK5N43TyexljZnqhyv3ZPMqTE1GpUCA6NT1j4XL48cGrdl58TipWQd-WuW-Wi_vhGXLwDg5A';
      _avatarDisplayUrl = _avatarUrl;
      _isLocalAvatar = false;
    }
  }

  String _computeDisplayUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    // Use BackendUtils to build URL for filenames
    return BackendUtils.getFullUrl('/storage/avatar/$raw');
  }

  String _defaultAvatar(String name) {
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=4A90E2&color=fff&size=256';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _avatarUrl = picked.path;
          _avatarDisplayUrl = picked.path;
          _isLocalAvatar = true;
        });
      }
    } catch (e) {
      // fallback to URL input dialog if pick fails
      final controller = TextEditingController(text: _avatarUrl);
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Change Photo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Image URL'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          _avatarUrl = result;
          _avatarDisplayUrl = _computeDisplayUrl(result);
          _isLocalAvatar = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty || email.isEmpty) {
      SnackBarUtils.showError(context, 'Name and email cannot be empty');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cur = auth.user;
      if (cur == null) {
        SnackBarUtils.showError(context, 'No logged in user');
        setState(() => _isSaving = false);
        return;
      }

      String? avatarToSave = cur.avatarUrl;

      // If user picked a new image (_isLocalAvatar = true), upload it first
      if (_isLocalAvatar && _avatarUrl.isNotEmpty) {
        try {
          final file = File(_avatarUrl);
          if (!await file.exists()) {
            throw Exception('Selected file does not exist');
          }
          final bytes = await file.readAsBytes();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Upload file to backend
          final fileService = FileService();
          final uploadResp = await fileService.uploadFile(
            cur.accessToken,
            bytes,
            fileName,
            'avatar',
          );

          if (uploadResp.statusCode < 200 ||
              uploadResp.statusCode >= 300 ||
              uploadResp.data == null) {
            throw Exception(uploadResp.message ?? 'Failed to upload avatar');
          }

          // Use the filename returned from backend
          avatarToSave = uploadResp.data!.fileName;
        } catch (e) {
          SnackBarUtils.showError(context, 'Failed to upload avatar: $e');
          setState(() => _isSaving = false);
          return;
        }
      } else if (_avatarUrl.isNotEmpty && !_avatarUrl.startsWith('http')) {
        // If user entered a raw filename or value, use it
        avatarToSave = _avatarUrl;
      } else if (_avatarUrl.isEmpty) {
        // Keep existing avatar if no change
        avatarToSave = cur.avatarUrl;
      }

      // Update user profile
      final userService = UserService();
      final updateResp = await userService.updateUser(
        cur.accessToken,
        cur.id,
        name,
        email,
        avatarToSave,
      );

      if (updateResp.statusCode < 200 ||
          updateResp.statusCode >= 300 ||
          updateResp.data == null) {
        throw Exception(updateResp.message ?? 'Failed to update profile');
      }

      final updated = updateResp.data!;
      final newResp = ResponseLogin(
        id: updated.id,
        name: updated.name,
        email: updated.email,
        accessToken: cur.accessToken,
        avatarUrl: updated.avatarUrl,
      );

      await auth.setUser(newResp);
      SnackBarUtils.showSuccess(context, 'Profile saved');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      SnackBarUtils.showError(context, 'Save failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      //bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'Edit Profile',
              onBackPressed: () => Navigator.of(context).pop(),
              rightAction: _isSaving
                  ? const SizedBox(
                      width: 60,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _save,
                      child: Text(
                        'Save',
                        style: GoogleFonts.lexend(
                          color: const Color(0xFF4A90E2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                height: 112,
                                width: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: _isLocalAvatar
                                        ? FileImage(File(_avatarDisplayUrl))
                                              as ImageProvider
                                        : NetworkImage(_avatarDisplayUrl),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _changePhoto,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A90E2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _changePhoto,
                            child: Text(
                              'Change Photo',
                              style: GoogleFonts.lexend(
                                color: const Color(0xFF4A90E2),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Form fields
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                    // Change password row
                    GestureDetector(
                      onTap: () {
                        // navigate to change password screen if exists
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Change Password',
                              style: GoogleFonts.lexend(fontSize: 15),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
