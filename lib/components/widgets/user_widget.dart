import 'package:flutter/material.dart';
import 'package:bdoneapp/screens/auth/domain/user_model.dart';
import 'package:bdoneapp/core/styles.dart';

class UserWidget extends StatelessWidget {
  final User user;
  final VoidCallback? onEditProfile;
  final double? profileImageSize;
  final EdgeInsets? padding;

  const UserWidget({
    super.key,
    required this.user,
    this.onEditProfile,
    this.profileImageSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Generate username from email if not available
    final username = _generateUsername(user.email);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // Profile Picture
          _buildProfilePicture(),

          const SizedBox(height: 4),

          // User Name
          _buildUserName(),

          const SizedBox(height: 4),

          // Username
          _buildUsername(username),

          const SizedBox(height: 10),

          // Edit Profile Button
          _buildEditProfileButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    final size = profileImageSize ?? 60.0;

    // Check for profile image (assuming user has a 'profileImage' property)
    final String? profileImage = (user as dynamic).profileImage;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: profileImage != null && profileImage.isNotEmpty
          ? CircleAvatar(
              radius: (size - 2) / 2,
              backgroundColor: AppColors.surface,
              backgroundImage: NetworkImage(profileImage),
            )
          : CircleAvatar(
              radius: (size - 2) / 2,
              backgroundColor: AppColors.surface,
              child: user.name.isNotEmpty
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF9CA3AF),
                    ),
            ),
    );
  }

  Widget _buildUserName() {
    return Text(
      user.name.isNotEmpty ? user.name : 'User',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUsername(String username) {
    return Text(
      '@$username',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Color(0xFF6B7280),
        letterSpacing: 0.25,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onEditProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
          ),
        ),
        child: const Text('Edit Profile'),
      ),
    );
  }

  String _generateUsername(String email) {
    if (email.isEmpty) return 'user';

    // Extract the part before @ from email
    final emailParts = email.split('@');
    if (emailParts.isNotEmpty) {
      return emailParts[0].toLowerCase();
    }

    return 'user';
  }
}
