import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import '../../const/constants.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../widgets/layout/widget_tree.dart';
import '../widgets/inputs/glass_text_field.dart';
import '../widgets/buttons/animated_signup_button.dart';
import '../data/notifiers.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Contrôleurs pour les champs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Validation Logic ---
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le nom est requis';
    if (value.trim().length < 2) return 'Le nom doit contenir au moins 2 caractères';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est requis';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Format d\'email invalide';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le téléphone est requis';
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{8,}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Format de téléphone invalide';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'adresse est requise';
    if (value.trim().length < 5) return 'L\'adresse doit contenir au moins 5 caractères';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'La confirmation du mot de passe est requise';
    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _fieldErrors = {});

    final nameError = _validateName(_nameController.text);
    final emailError = _validateEmail(_emailController.text);
    final phoneError = _validatePhone(_phoneController.text);
    final addressError = _validateAddress(_addressController.text);
    final passwordError = _validatePassword(_passwordController.text);
    final confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);

    if (nameError != null) _fieldErrors['name'] = nameError;
    if (emailError != null) _fieldErrors['email'] = emailError;
    if (phoneError != null) _fieldErrors['phone'] = phoneError;
    if (addressError != null) _fieldErrors['address'] = addressError;
    if (passwordError != null) _fieldErrors['password'] = passwordError;
    if (confirmPasswordError != null) _fieldErrors['confirmPassword'] = confirmPasswordError;

    if (_fieldErrors.isNotEmpty) {
      setState(() {});
      _showError('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        final userService = UserService();
        final profile = UserProfile(
          uid: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        );
        await userService.saveUserProfile(profile);
      }

      if (!mounted) return;
      selectedIndexNotifier.value = 0;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WidgetTree()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyMessage(e));
    } catch (e) {
      _showError('Une erreur est survenue. Réessayez.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'Cet email est déjà utilisé.';
      case 'weak-password': return 'Le mot de passe est trop faible (min 6 caractères).';
      case 'invalid-email': return 'Format d\'email invalide.';
      default: return 'Erreur : ${e.message ?? e.code}';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           // Background with Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.darkGradient,
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.glassBox(
                        radius: 50, 
                        tint: AppColors.primary.withOpacity(0.1)
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('CREATE ACCOUNT', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Join our futuristic community today',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 40),

                    // Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppDecorations.glassBox(radius: 20),
                      child: Column(
                        children: [
                          GlassTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'John Doe',
                            prefixIcon: Icons.person_outline,
                          ),
                          if (_fieldErrors.containsKey('name')) ...[
                              const SizedBox(height: 5),
                              Text(_fieldErrors['name']!, style: TextStyle(color: AppColors.error, fontSize: 12))
                          ],
                          const SizedBox(height: 16),
                          
                          GlassTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'name@example.com',
                            prefixIcon: Icons.email_outlined,
                          ),
                          if (_fieldErrors.containsKey('email')) ...[
                              const SizedBox(height: 5),
                              Text(_fieldErrors['email']!, style: TextStyle(color: AppColors.error, fontSize: 12))
                          ],
                          const SizedBox(height: 16),
                          
                          GlassTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            hint: '+1234567890',
                            prefixIcon: Icons.phone_outlined,
                          ),
                          if (_fieldErrors.containsKey('phone')) ...[
                              const SizedBox(height: 5),
                              Text(_fieldErrors['phone']!, style: TextStyle(color: AppColors.error, fontSize: 12))
                          ],
                          const SizedBox(height: 16),
                          
                          GlassTextField(
                            controller: _addressController,
                            label: 'Address',
                            hint: '123 Cyber St',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          if (_fieldErrors.containsKey('address')) ...[
                              const SizedBox(height: 5),
                              Text(_fieldErrors['address']!, style: TextStyle(color: AppColors.error, fontSize: 12))
                          ],
                          const SizedBox(height: 16),
                          
                          GlassTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          if (_fieldErrors.containsKey('password')) ...[
                              const SizedBox(height: 5),
                              Text(_fieldErrors['password']!, style: TextStyle(color: AppColors.error, fontSize: 12))
                          ],
                          const SizedBox(height: 16),
                          
                          GlassTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          if (_fieldErrors.containsKey('confirmPassword')) ...[
                              const SizedBox(height: 5),
                              Text(_fieldErrors['confirmPassword']!, style: TextStyle(color: AppColors.error, fontSize: 12))
                          ],
                          const SizedBox(height: 30),
                          
                          AnimatedSignupButton(
                            onTap: _submit,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: AppTextStyles.bodyMedium),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Log In",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

