import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../widgets/custom_elements.dart';
import '../auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isAgreed = false;
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= VALIDATION =================
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (value.trim().length < 3) return 'Nama tidak boleh kosong'; 
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi minimal 8 karakter';
    if (value.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Konfirmasi kata sandi tidak cocok';
    if (value != _passwordController.text) return 'Konfirmasi kata sandi tidak cocok';
    return null;
  }

  // ================= DIALOG =================
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Syarat & Ketentuan'),
        content: const Text('Silakan baca dan setujui ketentuan kami sebelum melanjutkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  // ================= REGISTER =================
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu harus menyetujui ketentuan terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService().register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil! Selamat datang di Litera.'))
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    // Auth pages selalu light mode
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Text(
            'Buat Akun',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Bergabung dengan Litera sekarang',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Material(
              color: const Color(0xFFF2F1ED),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        buildInputField(
                          label: 'Nama Lengkap',
                          hint: "John Doe",
                          controller: _nameController,
                          validator: _validateName,
                        ),
                        buildInputField(
                          label: 'Email',
                          hint: "email@litera.com",
                          controller: _emailController,
                          validator: _validateEmail,
                        ),
                        buildInputField(
                          label: 'Kata Sandi',
                          hint: "Min. 8 karakter",
                          isPassword: true,
                          isObscured: _isPasswordObscured,
                          controller: _passwordController,
                          validator: _validatePassword,
                          onToggleVisibility: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                        ),
                        buildInputField(
                          label: 'Konfirmasi Kata Sandi',
                          hint: 'Konfirmasi Kata Sandi',
                          isPassword: true,
                          isObscured: _isConfirmObscured,
                          controller: _confirmPasswordController,
                          validator: _validateConfirmPassword,
                          onToggleVisibility: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                        ),

                        // Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isAgreed,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _isAgreed = v ?? false),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: "Saya setuju dengan ",
                                  children: [
                                    TextSpan(
                                      text: 'Syarat & Ketentuan',
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = _showTermsDialog,
                                    ),
                                  ],
                                ),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        buildDivider('ATAU'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun? "),
                            buildClickableText(
                              text: 'Masuk',
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
