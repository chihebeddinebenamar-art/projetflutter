import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../const/constants.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import 'welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _userService.getCurrentUserProfile();
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone ?? '';
          _addressController.text = profile.address ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Invalid email format';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9+\-\s()]{8,}$');
      if (!phoneRegex.hasMatch(value.trim())) return 'Invalid phone format';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    setState(() => _fieldErrors = {});

    final nameError = _validateName(_nameController.text);
    final emailError = _validateEmail(_emailController.text);
    final phoneError = _validatePhone(_phoneController.text);
    final addressError = _validateAddress(_addressController.text);

    if (nameError != null) _fieldErrors['name'] = nameError;
    if (emailError != null) _fieldErrors['email'] = emailError;
    if (phoneError != null) _fieldErrors['phone'] = phoneError;
    if (addressError != null) _fieldErrors['address'] = addressError;

    if (_fieldErrors.isNotEmpty) {
      setState(() {});
      _showError('Please fix the errors in the form');
      return;
    }

    if (_userProfile == null) return;

    setState(() => _isSaving = true);

    try {
      final updatedProfile = UserProfile(
        uid: _userProfile!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );

      await _userService.updateUserProfile(updatedProfile);
      
      if (mounted) {
        setState(() {
          _userProfile = updatedProfile;
          _isEditing = false;
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Error updating profile: $e');
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? fieldKey,
  }) {
    final hasError = fieldKey != null && _fieldErrors.containsKey(fieldKey);
    final errorMessage = fieldKey != null ? _fieldErrors[fieldKey] : null;
    final isEditable = enabled && _isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: AppDecorations.glassBox(
            radius: 16, 
            tint: hasError ? AppColors.error.withOpacity(0.1) : AppColors.glassWhite,
            border: false,
          ),
          child: TextFormField(
            controller: controller,
            enabled: isEditable,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: AppColors.primary),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.glassWhite.withOpacity(0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.glassWhite.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.primary,
                  width: 1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              if (fieldKey != null && _fieldErrors.containsKey(fieldKey)) {
                setState(() {
                  _fieldErrors.remove(fieldKey);
                });
              }
            },
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
           Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.darkGradient,
              ),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _userProfile == null
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                              const SizedBox(height: 16),
                              const Text('Error loading profile', style: TextStyle(color: AppColors.textPrimary)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadUserProfile,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                      )
                    : CustomScrollView(
                        slivers: [
                          // Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.primaryGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.5),
                                          blurRadius: 20,
                                        )
                                      ]
                                    ),
                                    child: const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppColors.backgroundDark,
                                      child: Icon(Icons.person, size: 50, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _userProfile!.name,
                                    style: AppTextStyles.titleLarge.copyWith(fontSize: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userProfile!.email,
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Form
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(20),
                              decoration: AppDecorations.glassBox(radius: 20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with Edit Button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Personal Info',
                                          style: AppTextStyles.titleLarge,
                                        ),
                                        if (!_isEditing)
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isEditing = true;
                                                _fieldErrors = {};
                                              });
                                            },
                                            icon: const Icon(Icons.edit, color: AppColors.primary),
                                            tooltip: 'Edit Profile',
                                          )
                                        else
                                          Row(
                                            children: [
                                              TextButton(
                                                onPressed: _isSaving
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _isEditing = false;
                                                          _fieldErrors = {};
                                                          _nameController.text = _userProfile!.name;
                                                          _emailController.text = _userProfile!.email;
                                                          _phoneController.text = _userProfile!.phone ?? '';
                                                          _addressController.text = _userProfile!.address ?? '';
                                                        });
                                                      },
                                                child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: _isSaving ? null : _saveProfile,
                                                icon: _isSaving
                                                    ? const SizedBox(
                                                        width: 16, height: 16,
                                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.success),
                                                      )
                                                    : const Icon(Icons.check_circle, color: AppColors.success),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    _buildTextField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      hint: 'Enter your full name',
                                      icon: Icons.person_outline,
                                      validator: _validateName,
                                      fieldKey: 'name',
                                    ),
                                    _buildTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      hint: 'Enter your email',
                                      icon: Icons.email_outlined,
                                      validator: _validateEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      fieldKey: 'email',
                                    ),
                                    _buildTextField(
                                      controller: _phoneController,
                                      label: 'Phone',
                                      hint: 'Enter your phone number',
                                      icon: Icons.phone_outlined,
                                      validator: _validatePhone,
                                      keyboardType: TextInputType.phone,
                                      fieldKey: 'phone',
                                    ),
                                    _buildTextField(
                                      controller: _addressController,
                                      label: 'Address',
                                      hint: 'Enter your address',
                                      icon: Icons.location_on_outlined,
                                      validator: _validateAddress,
                                      fieldKey: 'address',
                                    ),
                                    
                                    const SizedBox(height: 30),
                                    
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: OutlinedButton.icon(
                                        onPressed: _logout,
                                        icon: const Icon(Icons.logout),
                                        label: const Text('Logout'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          side: const BorderSide(color: AppColors.error),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }
}
