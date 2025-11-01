import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/barca_background.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    String? message;
    if (_isLogin) {
      message = await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
      if (message != null) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      message = await auth.signUp(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (message != null) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan masuk.')),
        );
        setState(() {
          _isLogin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BarcaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Consumer<AuthService>(
              builder: (context, auth, _) {
                return Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.garnet.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.gold,
                                ),
                                child: const Icon(Icons.shield, color: Colors.black),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Visca Tasks',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isLogin
                                ? 'Masuk dulu untuk mengelola to-do kamu.'
                                : 'Buat akun baru dan mulai menuliskan misi harianmu.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          const SizedBox(height: 24),
                          if (!_isLogin)
                            Column(
                              children: [
                                TextFormField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama lengkap',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (!_isLogin && (value == null || value.trim().isEmpty)) {
                                      return 'Nama tidak boleh kosong.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email wajib diisi.';
                              }
                              if (!value.contains('@')) {
                                return 'Masukkan format email yang valid.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password wajib diisi.';
                              }
                              if (value.trim().length < 6) {
                                return 'Minimal 6 karakter.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: auth.isLoading ? null : () => _submit(auth),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppTheme.garnet,
                              foregroundColor: Colors.white,
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(_isLogin ? 'Masuk' : 'Daftar'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: auth.isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                            child: Text(
                              _isLogin
                                  ? 'Belum punya akun? Daftar di sini.'
                                  : 'Sudah punya akun? Masuk sekarang.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
