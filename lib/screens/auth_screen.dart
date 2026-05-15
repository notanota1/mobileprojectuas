import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginPasswordVisible = false;

  // Register controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmController = TextEditingController();
  bool _registerPasswordVisible = false;
  bool _registerConfirmVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.cinemaRed : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _login() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Email dan password tidak boleh kosong');
      return;
    }
    if (!email.contains('@')) {
      _showSnack('Format email tidak valid');
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.login(email, password);
    setState(() => _isLoading = false);

    if (result == null) {
      // success
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      _showSnack(result);
    }
  }

  Future<void> _register() async {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;
    final confirm = _registerConfirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Semua field harus diisi');
      return;
    }
    if (!email.contains('@')) {
      _showSnack('Format email tidak valid');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password minimal 6 karakter');
      return;
    }
    if (password != confirm) {
      _showSnack('Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.register(name, email, password);
    setState(() => _isLoading = false);

    if (result == null) {
      _showSnack('Akun berhasil dibuat! Silakan login.', isError: false);
      _tabController.animateTo(0);
      _loginEmailController.text = email;
    } else {
      _showSnack(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.goldLight, AppColors.goldDark],
                    ),
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'CINEMAX',
                  style: GoogleFonts.cinzel(
                    color: AppColors.gold,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Temukan film favoritmu',
                  style: GoogleFonts.raleway(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 40),
                // Tab bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, AppColors.goldDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    labelColor: Colors.black,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                    unselectedLabelStyle: GoogleFonts.cinzel(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                    tabs: const [
                      Tab(text: 'MASUK'),
                      Tab(text: 'DAFTAR'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Tab content
                SizedBox(
                  height: 440,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginForm(),
                      _buildRegisterForm(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang Kembali',
          style: GoogleFonts.cinzel(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Masuk untuk melanjutkan',
          style: GoogleFonts.raleway(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 28),
        _buildTextField(
          controller: _loginEmailController,
          label: 'Email',
          hint: 'email@contoh.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _loginPasswordController,
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          passwordVisible: _loginPasswordVisible,
          onTogglePassword: () =>
              setState(() => _loginPasswordVisible = !_loginPasswordVisible),
        ),
        const SizedBox(height: 32),
        _buildActionButton(label: 'MASUK', onTap: _login),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => _tabController.animateTo(1),
            child: RichText(
              text: TextSpan(
                text: 'Belum punya akun? ',
                style: GoogleFonts.raleway(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Daftar sekarang',
                    style: GoogleFonts.raleway(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Akun Baru',
          style: GoogleFonts.cinzel(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daftarkan dirimu untuk mulai menonton',
          style: GoogleFonts.raleway(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _registerNameController,
          label: 'Nama Lengkap',
          hint: 'John Doe',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerEmailController,
          label: 'Email',
          hint: 'email@contoh.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerPasswordController,
          label: 'Password',
          hint: 'Min. 6 karakter',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          passwordVisible: _registerPasswordVisible,
          onTogglePassword: () =>
              setState(() => _registerPasswordVisible = !_registerPasswordVisible),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerConfirmController,
          label: 'Konfirmasi Password',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          passwordVisible: _registerConfirmVisible,
          onTogglePassword: () =>
              setState(() => _registerConfirmVisible = !_registerConfirmVisible),
        ),
        const SizedBox(height: 24),
        _buildActionButton(label: 'DAFTAR', onTap: _register),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? passwordVisible,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword && !(passwordVisible ?? false),
          keyboardType: keyboardType,
          style: GoogleFonts.raleway(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.raleway(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      passwordVisible ?? false
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldDark],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.cinzel(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}