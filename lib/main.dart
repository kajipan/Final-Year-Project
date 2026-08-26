import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'translations.dart';
import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'screens/ai_chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MechNowApp());
}

class MechNowApp extends StatelessWidget {
  const MechNowApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B00)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ============ SPLASH SCREEN ============
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon.png', width: 150, height: 150),
            const SizedBox(height: 20),
            const Text('On-Demand Vehicle Repair',
                style: TextStyle(fontSize: 16, color: Color(0xFFFF6B00))),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFFFF6B00)),
          ],
        ),
      ),
    );
  }
}

// ============ LOGIN SCREEN ============
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'user';
  String _selectedLanguage = 'en'; 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset('assets/icon.png', width: 60, height: 60),
                ),
                const SizedBox(height: 12),
                const Text('MechNow',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
                const Text('Welcome Back!',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'user'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'user' ? const Color(0xFFFF6B00) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            Icon(Icons.person, color: _selectedRole == 'user' ? Colors.white : Colors.grey),
                            Text('Vehicle Owner', style: TextStyle(color: _selectedRole == 'user' ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'mechanic'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'mechanic' ? const Color(0xFFFF6B00) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            Icon(Icons.build, color: _selectedRole == 'mechanic' ? Colors.white : Colors.grey),
                            Text('Mechanic', style: TextStyle(color: _selectedRole == 'mechanic' ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Language Selector
                Row(
                  children: [
                    const Text('Language: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
                          DropdownMenuItem(value: 'si', child: Text('සිංහල')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (v) => v!.isEmpty ? 'Please enter email' : null,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  validator: (v) => v!.isEmpty ? 'Please enter password' : null,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                    child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final response = await http.post(
                            Uri.parse('http://10.0.2.2:8081/api/users/login'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({'email': _emailController.text.trim(), 'password': _passwordController.text.trim(),'language': _selectedLanguage,}),
                          );
                          if (response.statusCode == 200) {
                            final user = jsonDecode(response.body);
                            if (!context.mounted) return;
                            Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => _selectedRole == 'user'
                                  ? UserHomeScreen(userName: user['name'], userEmail: user['email'], userId: user['id'], userLanguage: _selectedLanguage)
                                  : MechanicHomeScreen(mechanicName: user['name'], mechanicId: user['id'], mechanicLanguage: _selectedLanguage),
                            ));
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body), backgroundColor: Colors.red));
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error!'), backgroundColor: Colors.red));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No account? '),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: const Text('Register Here', style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ FORGOT PASSWORD SCREEN ============
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.lock_reset, size: 60, color: Color(0xFFFF6B00)),
              const SizedBox(height: 16),
              const Text('Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter your email to receive OTP', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                enabled: !_otpSent,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))),
                ),
              ),
              const SizedBox(height: 16),
              if (!_otpSent)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      try {
                        final response = await http.post(
                          Uri.parse('http://10.0.2.2:8081/api/users/forgot-password'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({'email': _emailController.text.trim()}),
                        );
                        if (!context.mounted) return;
                        if (response.statusCode == 200) {
                          setState(() => _otpSent = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP sent to your email!'), backgroundColor: Colors.green)
                            );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response.body), backgroundColor: Colors.red));
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connection error!'), backgroundColor: Colors.red));
                      }
                      setState(() => _isLoading = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    
                    child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Send OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (_otpSent && !_otpVerified) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit OTP',
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), 
                      borderSide: const BorderSide(color: Color(0xFFFF6B00))
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final response = await http.post(
                          Uri.parse('http://10.0.2.2:8081/api/users/verify-otp'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': _emailController.text.trim(), 
                            'otp': _otpController.text.trim()
                          }),
                        );
                        if (!context.mounted) return;
                        if (response.statusCode == 200) {
                          setState(() => _otpVerified = true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response.body), backgroundColor: Colors.red)
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connection error!'), backgroundColor: Colors.red)
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    child: const Text('Verify OTP', style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              if (_otpVerified) ...[
                const SizedBox(height: 16),
                const Text('Set New Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPasswordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: 'New Password (min 8 characters)',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFFF6B00))
                      ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_newPasswordController.text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Min 8 characters required!'), backgroundColor: Colors.red));
                        return;
                      }
                      if (_newPasswordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.red));
                        return;
                      }
                      try {
                        final response = await http.post(
                          Uri.parse('http://10.0.2.2:8081/api/users/reset-password'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': _emailController.text.trim(), 
                            'otp': _otpController.text.trim(), 
                            'newPassword': _newPasswordController.text.trim()
                          }),
                        );
                        if (!context.mounted) return;
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset successful!'), backgroundColor: Colors.green)
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response.body), backgroundColor: Colors.red)
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connection error!'), backgroundColor: Colors.red)
                          );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    child: const Text('Reset Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============ REGISTER SCREEN ============
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  String _selectedRole = 'user';
  String? _selectedVehicleType;
  String? _selectedVehicleModel;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Tuk-Tuk', 'Van', 'Truck'];
  final Map<String, List<String>> _vehicleModels = {
    'Car': ['Toyota Corolla', 'Honda Fit', 'Suzuki Alto', 'Nissan Sunny', 'Hyundai i10'],
    'Motorcycle': ['Honda CB', 'Yamaha FZ', 'Bajaj Pulsar', 'TVS Apache'],
    'Tuk-Tuk': ['Bajaj RE', 'TVS King', 'Piaggio Ape'],
    'Van': ['Toyota HiAce', 'Mitsubishi L300', 'Ford Transit'],
    'Truck': ['Isuzu', 'Ashok Leyland', 'TATA'],
  };

  Future<void> _sendOTP() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email first!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/api/users/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email!'), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error!'), backgroundColor: Colors.red)
        );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _verifyOTP() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/api/users/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(), 
          'otp': _otpController.text.trim()
        }),
      );
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        setState(() => _otpVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified!'), backgroundColor: Colors.green)
          );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error!'), backgroundColor: Colors.red));
    }
  }

  Future<void> _register({bool skipVehicle = false}) async {
    if (!_otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email first!'), backgroundColor: Colors.red)
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8081/api/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'role': _selectedRole,
            'vehicleType': skipVehicle ? '' : (_selectedVehicleType ?? ''),
            'vehicleModel': skipVehicle ? '' : (_selectedVehicleModel ?? ''),
          }),
        );
        if (!context.mounted) return;
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registered Successfully! Please Login'), backgroundColor: Colors.green)
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.body), backgroundColor: Colors.red)
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error!'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('Register',
         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Register As', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'user'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'user' ? const Color(0xFFFF6B00) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            Icon(Icons.person, color: _selectedRole == 'user' ? Colors.white : Colors.grey),
                            Text('Vehicle Owner', style: TextStyle(color: _selectedRole == 'user' ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'mechanic'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'mechanic' ? const Color(0xFFFF6B00) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            Icon(Icons.build, color: _selectedRole == 'mechanic' ? Colors.white : Colors.grey),
                            Text('Mechanic', style: TextStyle(color: _selectedRole == 'mechanic' ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? 'Please enter name' : null,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outlined), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00)))
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Please enter phone number' : null,
                  decoration: InputDecoration(
                    hintText: 'Phone Number', 
                    prefixIcon: const Icon(Icons.phone_outlined), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00)))
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        enabled: !_otpVerified,
                        validator: (v) => v!.isEmpty ? 'Please enter email' : null,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          suffixIcon: _otpVerified 
                          ? const Icon(Icons.verified, color: Colors.green) 
                          : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_otpVerified)
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12)
                        ),
                        child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Text('Send OTP', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ],
                ),
                if (_otpSent && !_otpVerified) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter OTP', 
                            prefixIcon: const Icon(Icons.security), 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00)))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12)
                        ),
                        child: const Text('Verify', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  validator: (v) {
                    if (v!.isEmpty) return 'Please enter password';
                    if (v.length < 8) return 'Min 8 characters required';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password (min 8 characters)',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off), 
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible)
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  validator: (v) {
                    if (v!.isEmpty) return 'Please confirm password';
                    if (v != _passwordController.text) return 'Passwords do not match!';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off), 
                      onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible)
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedRole == 'user') ...[
                  const Text('Vehicle Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    hint: const Text('Select Vehicle Type'),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.directions_car), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00)))
                    ),
                    items: _vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() { 
                      _selectedVehicleType = val; 
                      _selectedVehicleModel = null; 
                    }),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedVehicleType != null)
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleModel,
                      hint: const Text('Select Vehicle Model'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.car_repair), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00)))
                      ),
                      items: _vehicleModels[_selectedVehicleType]!.map((model) => DropdownMenuItem(value: model, child: Text(model))).toList(),
                      onChanged: (val) => setState(() => _selectedVehicleModel = val),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _register(skipVehicle: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _register(skipVehicle: true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B00)), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text('Skip Vehicle & Register', style: TextStyle(fontSize: 16, color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _register(skipVehicle: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ USER HOME SCREEN ============
class UserHomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userLanguage;
  final int userId;
  const UserHomeScreen({super.key, required this.userName, required this.userEmail, required this.userId, this.userLanguage = 'en',});
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _requestSent = false;
  String? _selectedIssue;
  String? _selectedVehicleType;
  String? _selectedVehicleModel;
  bool _vehicleSelected = false;
  List<dynamic> _mechanics = [];
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  StompClient? _stompClient;
  String _requestStatus = '';
  String _mechanicStage = 'accepted'; // accepted -> arrived -> in_progress
  int? _requestedMechanicId;
  String _mechanicDistanceText = '';
  String _requestedMechanicName = '';
  String? _activeRequestId;
  StreamSubscription<Position>? _locationSendSub;

  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Tuk-Tuk', 'Van', 'Truck'];
  final Map<String, List<String>> _vehicleModels = {
    'Car': ['Toyota Corolla', 'Honda Fit', 'Suzuki Alto', 'Nissan Sunny', 'Hyundai i10'],
    'Motorcycle': ['Honda CB', 'Yamaha FZ', 'Bajaj Pulsar', 'TVS Apache'],
    'Tuk-Tuk': ['Bajaj RE', 'TVS King', 'Piaggio Ape'],
    'Van': ['Toyota HiAce', 'Mitsubishi L300', 'Ford Transit'],
    'Truck': ['Isuzu', 'Ashok Leyland', 'TATA'],
  };

  final List<Map<String, dynamic>> _issues = [
    {'icon': '🔋', 'label': 'Battery'},
    {'icon': '🔄', 'label': 'Tyre'},
    {'icon': '⚙️', 'label': 'Engine'},
    {'icon': '🌡️', 'label': 'Overheating'},
    {'icon': '🛑', 'label': 'Brake'},
    {'icon': '🔊', 'label': 'Strange Noise'},
    {'icon': '💡', 'label': 'Electrical'},
    {'icon': '🔧', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
    _getCurrentLocation();
    _connectWebSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVehicleDialog();
    });
  }

  Future<void> _fetchMechanics() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8081/api/users/mechanics'));
      if (response.statusCode == 200) {
        setState(() => _mechanics = jsonDecode(response.body));
      }
    } catch (e) {
       print('Error fetching mechanics: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    setState(() {
      _currentPosition = position;
      _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange),
      ));
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude)
      ),
    );
  }
   
 

  void _connectWebSocket() {
  _stompClient = StompClient(
    config: StompConfig(
      url: 'ws://10.0.2.2:8081/ws/websocket',
      onConnect: (frame) {
        _stompClient!.subscribe(
          destination: '/topic/user/${widget.userId}',
          callback: (frame) {
            final data = jsonDecode(frame.body!);
            if (data['type'] == 'REQUEST_CANCELLED') {
              _locationSendSub?.cancel();
              setState(() {
                _requestSent = false;
                _requestStatus = '';
                _activeRequestId = null;
                _requestedMechanicId = null;
                _markers.removeWhere((m) => m.markerId.value == 'mechanic');
              });
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('❌ Request Cancelled'),
                  content: Text('Mechanic cancelled the job.\nReason: ${data['reason']}'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              return;
            }

           if (data['type'] == 'MECHANIC_ARRIVED') {
              setState(() => _mechanicStage = 'arrived');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔧 Mechanic has reached your location!'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 4),
                ),
              );
              return;
            }

            if (data['type'] == 'WORK_STARTED') {
              setState(() => _mechanicStage = 'in_progress');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚙️ Mechanic has started the work!'),
                  backgroundColor: Colors.deepOrange,
                  duration: Duration(seconds: 4),
                ),
              );
              return;
            }

            if (data['type'] == 'PAYMENT_CONFIRMED') {
              return;
            }

            if (data['type'] == 'BILL_RECEIVED') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('🧾 Bill Received'),
                  content: Text('Amount: Rs. ${data['amount']}\nService: ${data['issue']}'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            mechanicName: _requestedMechanicName,
                            issue: data['issue'].toString(),
                            amount: double.parse(data['amount'].toString()),
                            requestId: data['requestId'].toString(),
                            stompClient: _stompClient!,
                            userId: widget.userId,
                            userName: widget.userName,
                            userEmail: widget.userEmail,
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                      child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              return;
            }
            setState(() {
              _requestStatus = data['type'] == 'REQUEST_ACCEPTED' ? 'accepted' : 'rejected';
            });
            _showNotificationDialog(data['type']);
            if (data['type'] == 'REQUEST_ACCEPTED') {
              _startSendingLocationToMechanic();
            }
          },
        );

        _stompClient!.subscribe(
          destination: '/topic/call/user/${widget.userId}',
          callback: (frame) {
            final data = jsonDecode(frame.body!);
            if (data['type'] == 'OFFER') {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('📞 Incoming Call'),
                  content: Text('${widget.userName == data['callerName'] ? _requestedMechanicName : _requestedMechanicName} is calling...'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Decline', style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => CallScreen(
                            stompClient: _stompClient!,
                            isCaller: false,
                            myType: 'user',
                            myId: widget.userId,
                            peerType: 'mechanic',
                            peerId: _requestedMechanicId ?? 0,
                            peerName: _requestedMechanicName,
                            incomingOffer: data,
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
          },
        );

        _stompClient!.subscribe(
          destination: '/topic/tracking/${widget.userId}',
          callback: (frame) {
            print('📍 USER received tracking data: ${frame.body}');
            final data = jsonDecode(frame.body!);
            // Optional: Check requestId if backend sends it
            setState(() {
              _markers.removeWhere((m) => m.markerId.value == 'mechanic');
              _markers.add(Marker(
                markerId: const MarkerId('mechanic'),
                position: LatLng(data['lat'] as double, data['lng'] as double),
                infoWindow: InfoWindow(title: '${data['mechanicName']} - On the way!'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ));
              if (_currentPosition != null) {
                final meters = Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  data['lat'] as double,
                  data['lng'] as double,
                );
                _mechanicDistanceText = '${(meters / 1000).toStringAsFixed(1)} km away';
              }
            });
          },
        );
      },
      onWebSocketError: (error) => print('WebSocket error: $error'),
    ),
  );
  _stompClient!.activate();
}

void _showNotificationDialog(String type) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(type == 'REQUEST_ACCEPTED' ? '✅ Request Accepted!' : '❌ Request Rejected'),
      content: Text(type == 'REQUEST_ACCEPTED' ? 'Mechanic is on his way!' : 'Try another mechanic.'),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _showCancelDialog() {
  final reasons = ['Mechanic taking too long', 'Found another mechanic', 'Changed my mind', 'Other'];
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Request?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: reasons.map((reason) => ListTile(
          title: Text(reason),
          onTap: () {
            Navigator.pop(context);
            _cancelTrip(reason);
          },
        )).toList(),
      ),
    ),
  );
}

void _cancelTrip(String reason) {
  if (_activeRequestId == null || _stompClient == null) return;
  _stompClient!.send(
    destination: '/app/request.cancel',
    body: jsonEncode({
      'requestId': _activeRequestId,
      'cancelledBy': 'user',
      'reason': reason,
    }),
  );
  _locationSendSub?.cancel();
  setState(() {
    _requestSent = false;
    _requestStatus = '';
    _mechanicStage = 'accepted';
    _activeRequestId = null;
    _requestedMechanicId = null;
    _markers.removeWhere((m) => m.markerId.value == 'mechanic');
  });
}

void _startSendingLocationToMechanic() {
  _locationSendSub?.cancel();
  _locationSendSub = Geolocator.getPositionStream().listen((position) {
    if (_stompClient == null || !_stompClient!.connected || _requestedMechanicId == null) return;
    _stompClient!.send(
      destination: '/app/user.location.update',
      body: jsonEncode({
        'mechanicId': _requestedMechanicId,
        'userName': widget.userName,
        'lat': position.latitude,
        'lng': position.longitude,
      }),
    );
  });
}

void _sendRequest(int mechanicId, String mechanicName) {
  _requestedMechanicId = mechanicId;
  _requestedMechanicName = mechanicName;
  if (_currentPosition == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location not available')),
    );
    return;
  }

  if (_stompClient == null || !_stompClient!.connected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting to server. Please try again in a moment.'),
        backgroundColor: Colors.red,
      ),
    );
    _connectWebSocket();
    return;
  }

  final newRequestId = DateTime.now().millisecondsSinceEpoch.toString();
    _activeRequestId = newRequestId;
    _stompClient!.send(
      destination: '/app/request.send',
      body: jsonEncode({
      'requestId': newRequestId,
      'userId': widget.userId,
      'mechanicId': mechanicId,
      'userName': widget.userName,
      'issue': _selectedIssue ?? 'Other',
      'vehicleModel': _selectedVehicleModel ?? '',
      'userLat': _currentPosition!.latitude,
      'userLng': _currentPosition!.longitude,
    }),
  );

  setState(() {
    _requestSent = true;
    _requestStatus = 'pending';
  });
}

  void _showVehicleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Your Vehicle', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Which vehicle are you using today?'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedVehicleType,
                  hint: const Text('Vehicle Type'),
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: _vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (val) => setDialogState(() { 
                    _selectedVehicleType = val; 
                    _selectedVehicleModel = null; 
                  }),
                ),
                const SizedBox(height: 12),
                if (_selectedVehicleType != null)
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleModel,
                    hint: const Text('Vehicle Model'),
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    items: _vehicleModels[_selectedVehicleType]!.map((model) => DropdownMenuItem(value: model, child: Text(model))).toList(),
                    onChanged: (val) => setDialogState(() => _selectedVehicleModel = val),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () { 
              setState(() => _vehicleSelected = false); 
              Navigator.pop(context); 
            }, 
            child: const Text('Skip', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedVehicleType != null && _selectedVehicleModel != null) {
                  setState(() => _vehicleSelected = true);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        automaticallyImplyLeading: false,
        title: Text('Hi, ${widget.userName}!', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_vehicleSelected)
            IconButton(icon: const Icon(Icons.directions_car, color: Colors.white), 
            onPressed: _showVehicleDialog),
          IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => AiChatScreen(userId: widget.userId, userName: widget.userName),
              )),
            ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userName: widget.userName, userEmail: widget.userEmail, userId: widget.userId))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_vehicleSelected && _selectedVehicleModel != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.orange[50],
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: Color(0xFFFF6B00), size: 18),
                    const SizedBox(width: 8),
                    Text('Current Vehicle: $_selectedVehicleModel', 
                      style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showVehicleDialog, 
                      child: const Text('Change', style: TextStyle(color: Color(0xFFFF6B00), decoration: TextDecoration.underline))
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 250,
              child: _currentPosition == null
                  ? Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.green[100]!], 
                          begin: Alignment.topLeft, 
                          end: Alignment.bottomRight
                        )
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFF6B00)), 
                            SizedBox(height: 10), Text('Getting your location...')
                          ],
                        ),
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), zoom: 14),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapType: MapType.normal,
                      markers: _markers,
                      onMapCreated: (controller) => _mapController = controller,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    AppTranslations.getText('selectIssue', widget.userLanguage),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.9),
                    itemCount: _issues.length,
                    itemBuilder: (context, index) {
                      final issue = _issues[index];
                      final isSelected = _selectedIssue == issue['label'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIssue = issue['label']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF6B00) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[300]!),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(issue['icon'], style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(issue['label'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_requestSent)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _requestStatus == 'accepted' ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _requestStatus == 'accepted' ? Colors.green : Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(
                      _requestStatus == 'accepted' ? Icons.check_circle : Icons.hourglass_empty,
                      color: _requestStatus == 'accepted' ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _requestStatus != 'accepted'
                          ? '⏳ Finding mechanic for $_selectedIssue...'
                          : _mechanicStage == 'in_progress'
                              ? '⚙️ Mechanic is working on your vehicle!'
                              : _mechanicStage == 'arrived'
                                  ? '🔧 Mechanic has reached your location!'
                                  : '✅ Mechanic is on the way! $_mechanicDistanceText',
                        style: TextStyle(
                          color: _requestStatus == 'accepted' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_requestStatus == 'accepted')
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => CallScreen(
                              stompClient: _stompClient!,
                              isCaller: true,
                              myType: 'user',
                              myId: widget.userId,
                              peerType: 'mechanic',
                              peerId: _requestedMechanicId ?? 0,
                              peerName: _requestedMechanicName,
                            ),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.call, color: Colors.white, size: 20),
                        ),
                      ),

                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showCancelDialog,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
            

                  ],
                ),
              ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
     s   padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () {
            if (_selectedIssue == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an issue first!'), backgroundColor: Colors.red),
              );
            } else {
              if (_mechanics.isNotEmpty) {
                _sendRequest(
                  _mechanics[0]['id'] as int,
                  _mechanics[0]['name'] as String,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No mechanics available!'), backgroundColor: Colors.red),
                );
                return;
              }
            }
          },
          icon: const Icon(Icons.build, color: Colors.white),
          label: Text(
                    AppTranslations.getText('requestMechanic', widget.userLanguage),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _mechanicCard(String name, String distance, String rating, String skills) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFFF6B00), child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(skills, style: TextStyle(color: Colors.grey[600], fontSize: 12))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('⭐ $rating'), Text(distance, style: const TextStyle(color: Color(0xFFFF6B00)))]),
        ],
      ),
    );
  }
}

// ============ MECHANIC HOME SCREEN ============
class MechanicHomeScreen extends StatefulWidget {
  final String mechanicName;
  final String mechanicLanguage;
  final int mechanicId;
  const MechanicHomeScreen({super.key, required this.mechanicName, required this.mechanicId, this.mechanicLanguage = 'en', });
  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  bool _isOnline = true;
  StompClient? _stompClient;
  Position? _myPosition;
  LatLng? _activeUserLocation;
  String? _activeUserName;
  StreamSubscription<Position>? _locationStreamSub;
  int? _activeUserId;
  String? _activeRequestId;
  String _jobStage = 'ACCEPTED';
  final TextEditingController _billController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _getMyLocation();
  }

  Future<void> _getMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() => _myPosition = position);
  }

  final List<Map<String, dynamic>> _requests = [];

  void _connectWebSocket() {
  _stompClient = StompClient(
    config: StompConfig(
      url: 'ws://10.0.2.2:8081/ws/websocket',
      onConnect: (frame) {
        _stompClient!.subscribe(
          destination: '/topic/mechanic/${widget.mechanicId}',
          callback: (frame) {
            final data = jsonDecode(frame.body!);
            if (data['type'] == 'NEW_REQUEST') {
              setState(() {
                String distanceText = '-- km';
                if (_myPosition != null && data['userLat'] != null && data['userLng'] != null) {
                  final meters = Geolocator.distanceBetween(
                    _myPosition!.latitude,
                    _myPosition!.longitude,
                    double.parse(data['userLat'].toString()),
                    double.parse(data['userLng'].toString()),
                  );
                  distanceText = '${(meters / 1000).toStringAsFixed(1)} km';
                }

                _requests.insert(0, {
                  'requestId': data['requestId'].toString(),
                  'userId': data['userId'],
                  'name': data['userName'].toString(),
                  'issue': data['issue'].toString(),
                  'distance': distanceText,
                  'time': 'Just now',
                  'vehicle': data['vehicleModel']?.toString() ?? 'Unknown',
                });
              });
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('🔔 New Request!'),
                  content: Text('${data['userName']} needs help!\nIssue: ${data['issue']}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('View', style: TextStyle(color: Color(0xFFFF6B00))),
                    ),
                  ],
                ),
              );
            } else if (data['type'] == 'REQUEST_CANCELLED') {
              setState(() {
                _activeUserLocation = null;
                _activeUserName = null;
                _activeUserId = null;
                _activeRequestId = null;
              });
              _locationStreamSub?.cancel();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('❌ Request Cancelled'),
                  content: Text('Customer cancelled the request.\nReason: ${data['reason']}'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

                        } else if (data['type'] == 'CASH_PAYMENT_SELECTED') {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('💵 Cash Payment'),
                  content: Text('Customer selected Cash Payment.\nAmount: Rs. ${data['amount']}\n\nCollect the cash, then confirm below.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _stompClient?.send(
                          destination: '/app/payment.cash.confirm',
                          body: jsonEncode({'requestId': data['requestId']}),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Cash Received', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            
            } else if (data['type'] == 'PAYMENT_RECEIVED') {
              setState(() {
                _activeUserLocation = null;
                _activeUserName = null;
                _activeUserId = null;
                _activeRequestId = null;
              });
              _locationStreamSub?.cancel();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('💰 Payment Received!'),
                  content: Text('Rs. ${data['amount']} via ${data['method']}'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
          },
        );
        _stompClient!.subscribe(
          destination: '/topic/mechanic-tracking/${widget.mechanicId}',
          callback: (frame) {
            if (_activeRequestId == null) return;
            final data = jsonDecode(frame.body!);
            setState(() {
              _activeUserLocation = LatLng(data['lat'] as double, data['lng'] as double);
              _activeUserName = data['userName']?.toString();
            });
          },
        );

        _stompClient!.subscribe(
          destination: '/topic/call/mechanic/${widget.mechanicId}',
          callback: (frame) {
            final data = jsonDecode(frame.body!);
            if (data['type'] == 'OFFER') {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('📞 Incoming Call'),
                  content: Text('${_activeUserName ?? "Customer"} is calling...'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Decline', style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => CallScreen(
                            stompClient: _stompClient!,
                            isCaller: false,
                            myType: 'mechanic',
                            myId: widget.mechanicId,
                            peerType: 'user',
                            peerId: _activeUserId ?? 0,
                            peerName: _activeUserName ?? 'Customer',
                            incomingOffer: data,
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
      onWebSocketError: (error) => print('WebSocket error: $error'),
    ),
  );
  _stompClient!.activate();
}

 @override
  void dispose() {
    _locationStreamSub?.cancel();
    super.dispose();
  }

void _acceptRequest(String requestId, int userId, String mechanicName) {
  // First send accept response
  _locationStreamSub?.cancel();
  _activeUserId = userId;
  _activeRequestId = requestId;
  _jobStage = 'ACCEPTED';
  _stompClient?.send(
    destination: '/app/request.respond',
    body: jsonEncode({
      'requestId': requestId,
      'status': 'ACCEPTED',
      'mechanicId': widget.mechanicId,
      'userId': userId,
    }),
  );
  
  // Then start location streaming
// Then start location streaming
  _locationStreamSub = Geolocator.getPositionStream().listen((position) {
        print('📍 MECHANIC sending location: ${position.latitude}, ${position.longitude} to userId=$userId');
    _stompClient?.send(
      destination: '/app/location.update',
      body: jsonEncode({
        'requestId': requestId,
        'userId': userId,
        'lat': position.latitude,
        'lng': position.longitude,
        'mechanicName': mechanicName,
      }),
    );
  });
}


void _rejectRequest(String requestId, int userId) {
  _locationStreamSub?.cancel();
  _stompClient?.send(
    destination: '/app/request.respond',
    body: jsonEncode({
      'requestId': requestId,
      'status': 'REJECTED',
      'mechanicId': widget.mechanicId,
      'userId': userId,
    }),
  );
}

void _markArrived() {
  if (_activeRequestId == null || _stompClient == null) return;
  _stompClient!.send(
    destination: '/app/request.arrived',
    body: jsonEncode({'requestId': _activeRequestId}),
  );
  setState(() => _jobStage = 'ARRIVED');
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Marked as reached!'), backgroundColor: Colors.green),
  );
}

void _startWork() {
  if (_activeRequestId == null || _stompClient == null) return;
  _stompClient!.send(
    destination: '/app/request.startwork',
    body: jsonEncode({'requestId': _activeRequestId}),
  );
  setState(() => _jobStage = 'IN_PROGRESS');
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Work started!'), backgroundColor: Colors.green),
  );
}


void _showCancelJobDialog() {
  final reasons = ['Vehicle too far', 'Emergency came up', 'Unable to reach location', 'Other'];
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Job?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: reasons.map((reason) => ListTile(
          title: Text(reason),
          onTap: () {
            Navigator.pop(context);
            _cancelJob(reason);
          },
        )).toList(),
      ),
    ),
  );
}

void _showBillDialog() {
  _billController.clear();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Complete Job - Send Bill'),
      content: TextField(
        controller: _billController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          prefixText: 'Rs. ',
          hintText: 'Enter bill amount',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_billController.text.trim());
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid amount'), backgroundColor: Colors.red),
              );
              return;
            }
            Navigator.pop(context);
            _sendBill(amount);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
          child: const Text('Send Bill', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _sendBill(double amount) {
  if (_activeRequestId == null || _stompClient == null) return;
  _stompClient!.send(
    destination: '/app/bill.send',
    body: jsonEncode({'requestId': _activeRequestId, 'amount': amount}),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Bill sent to customer!'), backgroundColor: Colors.green),
  );
}

void _cancelJob(String reason) {
  if (_activeRequestId == null || _stompClient == null) return;
  _stompClient!.send(
    destination: '/app/request.cancel',
    body: jsonEncode({
      'requestId': _activeRequestId,
      'cancelledBy': 'mechanic',
      'reason': reason,
    }),
  );
  _locationStreamSub?.cancel();
  setState(() {
    _activeUserLocation = null;
    _activeUserName = null;
    _activeUserId = null;
    _activeRequestId = null;
    _jobStage = 'ACCEPTED';
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        automaticallyImplyLeading: false,
        title: Text('Hi, ${widget.mechanicName}!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MechanicProfileScreen(mechanicName: widget.mechanicName, mechanicId: widget.mechanicId))),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFFFF6B00), radius: 25, child: Text(widget.mechanicName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.mechanicName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_isOnline ? 'Online - Accepting Jobs' : 'Offline', style: TextStyle(color: _isOnline ? Colors.green : Colors.red)),
                ])),
                Switch(value: _isOnline, onChanged: (val) => setState(() => _isOnline = val), activeColor: const Color(0xFFFF6B00)),
              ],
            ),
          ),

         if (_activeUserLocation != null)
            Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: _activeUserLocation!, zoom: 14),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId('activeUser'),
                      position: _activeUserLocation!,
                      infoWindow: InfoWindow(title: _activeUserName ?? 'Customer'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                    ),
                  },
                ),
              ),
            ),
          if (_activeUserLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CallScreen(
                        stompClient: _stompClient!,
                        isCaller: true,
                        myType: 'mechanic',
                        myId: widget.mechanicId,
                        peerType: 'user',
                        peerId: _activeUserId ?? 0,
                        peerName: _activeUserName ?? 'Customer',
                      ),
                    ));
                  },
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: Text('Call ${_activeUserName ?? "Customer"}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ),

                    if (_activeUserLocation != null && _jobStage == 'ACCEPTED')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _markArrived,
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text("I've Reached", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ),
          if (_activeUserLocation != null && _jobStage == 'ARRIVED')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startWork,
                  icon: const Icon(Icons.build, color: Colors.white),
                  label: const Text('Start Work', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ),
         

          if (_activeUserLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showBillDialog,
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  label: const Text('Complete Job & Send Bill', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ),
          if (_activeUserLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showCancelJobDialog,
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Cancel Job', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text('Incoming Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isOnline
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final req = _requests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(req['vehicle']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 6),
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)), child: Text(req['issue']!)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.location_on, color: Color(0xFFFF6B00), size: 14),
                              Text(req['distance']!, style: const TextStyle(color: Color(0xFFFF6B00))),
                              const Spacer(),
                              Text(req['time']!, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                            ]),
                            const SizedBox(height: 8),
                            Row(
                              children: [Expanded(child: OutlinedButton( 
                                onPressed: () {
                                    _rejectRequest(_requests[index]['requestId'] ?? '1', _requests[index]['userId'] as int);
                                    setState(() => _requests.removeAt(index));
                                  },
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)), child: const Text('Decline', style: TextStyle(color: Colors.red)))),
                                const SizedBox(width: 10),
                                Expanded(child: ElevatedButton(
                                  onPressed: () {
                                      _acceptRequest(
                                          _requests[index]['requestId'] ?? '1',
                                          _requests[index]['userId'] as int,
                                          widget.mechanicName,
                                        );
                                      setState(() => _requests.removeAt(index));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Job Accepted! Navigating to customer.'), backgroundColor: Colors.green),
                                      );
                                    },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                                  child: const Text('Accept', style: TextStyle(color: Colors.white)),
                                )),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.wifi_off, size: 60, color: Colors.grey[400]), const SizedBox(height: 10), Text('You are Offline', style: TextStyle(color: Colors.grey[500]))])),
          ),
        ],
      ),
    );
  }
}

// ============ CHAT SCREEN ============
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! I am MechNow AI Assistant. Please describe your vehicle issue!', 'isBot': true},
  ];
  int _headlightStep = 0;
  final Map<String, String> _headlightAnswers = {};

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add({'text': text, 'isBot': false}));
    _controller.clear();
    final lower = text.toLowerCase();
    String reply = '';
    if (_headlightStep > 0) {
      reply = _handleHeadlightFlow(lower);
    } else if (lower.contains('headlight') || lower.contains('head light') || lower.contains('light not working')) {
      _headlightStep = 1;
      reply = '💡 Headlight Issue Detected!\n\nQuestion 1️⃣:\nIs it one headlight or both headlights not working?';
    } else if (lower.contains('battery') || lower.contains('not starting')) {
      reply = '🔋 Battery Issue!\n\n1. Does engine make clicking sound?\n2. Are headlights dim?\n3. How old is battery?';
    } else if (lower.contains('tyre') || lower.contains('tire') || lower.contains('flat')) {
      reply = '🔄 Tyre Issue!\n\n1. Completely flat or low pressure?\n2. Did you hear a loud pop?\n3. Are you in safe location?';
    } else if (lower.contains('engine') || lower.contains('knocking')) {
      reply = '⚙️ Engine Issue!\n\n1. What type of noise?\n2. When does it occur?\n3. Any warning lights?';
    } else if (lower.contains('overheat') || lower.contains('hot') || lower.contains('smoke')) {
      reply = '🌡️ Overheating - URGENT!\n\n1. Pull over safely\n2. Turn OFF AC\n3. Turn ON heater\n4. Wait 30 minutes\n\nShall I find a mechanic?';
    } else if (lower.contains('brake')) {
      reply = '🛑 Brake Issue - CRITICAL!\n\n1. Completely failed or just weak?\n2. Hear grinding/squeaking?\n3. Car pulls to one side?\n\nDo NOT drive if brakes failed!';
    } else if (lower.contains('thank') || lower.contains('ok') || lower.contains('great')) {
      reply = '✅ Glad I could help! Stay safe! 🚗';
    } else {
      reply = 'I understand. Can you describe your vehicle issue?\n\nCommon issues:\n• Headlight\n• Battery\n• Tyre\n• Engine\n• Overheating\n• Brake';
    }
    Future.delayed(const Duration(milliseconds: 800), () => setState(() => _messages.add({'text': reply, 'isBot': true})));
  }

  String _handleHeadlightFlow(String lower) {
    String reply = '';
    if (_headlightStep == 1) {
      _headlightAnswers['sides'] = lower.contains('both') || lower.contains('two') ? 'both' : 'one';
      _headlightStep = 2;
      reply = '✅ Got it!\n\nQuestion 2️⃣:\nDid it stop suddenly or gradually?';
    } else if (_headlightStep == 2) {
      _headlightAnswers['stop'] = lower.contains('sudden') ? 'sudden' : 'gradual';
      _headlightStep = 3;
      reply = '✅ Understood!\n\nQuestion 3️⃣:\nHave you checked the fuse box? (Yes/No)';
    } else if (_headlightStep == 3) {
      _headlightAnswers['fuse'] = lower.contains('yes') ? 'yes' : 'no';
      _headlightStep = 4;
      reply = '✅ OK!\n\nQuestion 4️⃣:\nAre brake lights, horn, indicators still working? (Yes/No)';
    } else if (_headlightStep == 4) {
      _headlightAnswers['others'] = lower.contains('yes') ? 'yes' : 'no';
      _headlightStep = 5;
      if (_headlightAnswers['sides'] == 'both' && _headlightAnswers['stop'] == 'sudden' && _headlightAnswers['fuse'] == 'yes' && _headlightAnswers['others'] == 'yes') {
        reply = '🔍 Diagnosis: Bulb Issue!\n\nHave you checked the bulb itself?\n(Yes / No / How to check?)';
      } else if (_headlightAnswers['sides'] == 'one') {
        reply = '🔍 Diagnosis: Most likely Bulb burnout!\n\nHave you checked the bulb?\n(Yes / No / How to check?)';
      } else {
        reply = '🔍 Could be wiring or fuse issue.\n\nShall I find a mechanic? (Yes/No)';
      }
    } else if (_headlightStep == 5) {
      if (lower.contains('how')) {
        reply = '🔧 How to Check Bulb:\n\n1. Open the hood\n2. Locate headlight assembly\n3. Remove the bulb\n4. Look at tungsten filament\n5. If filament is BROKEN = Bulb dead!\n\nIs the filament broken? (Yes/No)';
      } else if (lower.contains('yes') || lower.contains('broken')) {
        _headlightStep = 6;
        reply = '✅ Bulb filament is broken!\n\n🔧 Solution: Replace the bulb!\n💰 Cost: Rs. 200-500\n\nWould you like mechanic service? (Yes/No)';
      } else if (lower.contains('no')) {
        _headlightStep = 7;
        reply = '🔍 Bulb seems fine.\nCould be loose wiring or relay issue.\n\nShall I find a mechanic? (Yes/No)';
      }
    } else if (_headlightStep == 6) {
      _headlightStep = 0;
      _headlightAnswers.clear();
      if (lower.contains('yes')) {
        reply = '✅ Finding mechanic...\n\n📍 Nearest:\n🔧 Rajan Kumar - 0.8km ⭐4.8\n\nGo to Home and tap "Request Mechanic"!';
      } else {
        reply = '✅ Solution:\n• Remove headlight bulb\n• Filament is broken\n• Replace with new bulb (Rs.200-500)\n\nHave a great day! 🚗';
      }
    } else if (_headlightStep == 7) {
      _headlightStep = 0;
      _headlightAnswers.clear();
      reply = lower.contains('yes') ? '✅ Finding mechanic...\n\n📍 Rajan Kumar - 0.8km ⭐4.8\n\nGo to Home and tap "Request Mechanic"!' : '✅ Try checking wiring connections. Feel free to come back! 🚗';
    }
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('MechNow AI Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.orange[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Headlight', 'Battery', 'Tyre', 'Engine', 'Overheat', 'Brake'].map((label) => GestureDetector(
                  onTap: () { _controller.text = label; _send(); },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFF6B00), borderRadius: BorderRadius.circular(20)),
                    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isBot'] ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(color: msg['isBot'] ? Colors.grey[200] : const Color(0xFFFF6B00), borderRadius: BorderRadius.circular(12)),
                    child: Text(msg['text'], style: TextStyle(color: msg['isBot'] ? Colors.black : Colors.white)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Describe your issue...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey[100]), onSubmitted: (_) => _send())),
                const SizedBox(width: 8),
                GestureDetector(onTap: _send, child: Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFFF6B00), shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.white, size: 20))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ PROFILE SCREEN ============
class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final int userId;
  const ProfileScreen({super.key, required this.userName, required this.userEmail, required this.userId});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _loadingHistory = true;

  List<Map<String, dynamic>> _activities = [];

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8081/api/requests/user/${widget.userId}/history'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _activities = data.map((item) {
            return {
              'icon': '✅',
              'title': 'Service Completed',
              'subtitle': '${item['issue'] ?? ''} - Rs. ${item['amount'] ?? 0}',
              'time': item['completedAt']?.toString().substring(0, 10) ?? '',
              'color': Colors.green,
            };
          }).toList();
          _loadingHistory = false;
        });
      } else {
        setState(() => _loadingHistory = false);
      }
    } catch (e) {
      setState(() => _loadingHistory = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white), onPressed: () => setState(() => _isEditing = !_isEditing))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFFF6B00), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Text(widget.userName[0].toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)))),
                      Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Color(0xFFFF6B00), size: 20))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(widget.userEmail, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: const Text('Vehicle Owner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Full Name', prefixIcon: const Icon(Icons.person_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))))),
                    const SizedBox(height: 12),
                    TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: 'Phone Number', prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))))),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _profileMenuItem(Icons.lock_outlined, 'Change Password', Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()))),
                  _profileMenuItem(Icons.directions_car, 'My Vehicles', Colors.orange, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!')))),
                  _profileMenuItem(Icons.notifications_outlined, 'Notifications', Colors.purple, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!')))),
                  _profileMenuItem(Icons.help_outline, 'Help & Support', Colors.teal, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!')))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                    const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (_loadingHistory)
                    const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Color(0xFFFF6B00))))
                  else if (_activities.isEmpty)
                    const Padding(padding: EdgeInsets.all(12), child: Text('No completed services yet', style: TextStyle(color: Colors.grey)))
                  else
                    ..._activities.map((activity) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: (activity['color'] as Color).withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(activity['icon'], style: const TextStyle(fontSize: 20)))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(activity['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(activity['subtitle'], style: TextStyle(color: Colors.grey[600], fontSize: 12))])),
                          Text(activity['time'], style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ============ MECHANIC PROFILE SCREEN ============
class MechanicProfileScreen extends StatefulWidget {
  final String mechanicName;
  final int mechanicId;
  const MechanicProfileScreen({super.key, required this.mechanicName, required this.mechanicId});
  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isOnline = true;
  bool _loadingStats = true;
  final List<String> _skills = ['Engine', 'Electrical', 'Tyre', 'Battery', 'Brake', 'AC'];
  final List<String> _selectedSkills = ['Engine', 'Electrical'];

  List<Map<String, dynamic>> _activities = [];
  int _jobsDone = 0;
  double _earnings = 0;
  double _avgRating = 0;

  Future<void> _fetchStats() async {
    try {
      final allResponse = await http.get(Uri.parse('http://10.0.2.2:8081/api/users/all'));
      if (allResponse.statusCode == 200) {
        final List<dynamic> allUsers = jsonDecode(allResponse.body);
        final mech = allUsers.firstWhere(
          (u) => u['id'] == widget.mechanicId,
          orElse: () => null,
        );
        if (mech != null) {
          _jobsDone = mech['jobsDone'] ?? 0;
          _earnings = (mech['totalEarnings'] ?? 0).toDouble();
          final ratingSum = (mech['ratingSum'] ?? 0).toDouble();
          final ratingCount = (mech['ratingCount'] ?? 0);
          _avgRating = ratingCount == 0 ? 0 : ratingSum / ratingCount;
        }
      }

      final historyResponse = await http.get(Uri.parse('http://10.0.2.2:8081/api/requests/mechanic/${widget.mechanicId}/history'));
      if (historyResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(historyResponse.body);
        _activities = data.map((item) {
          return {
            'icon': '✅',
            'title': 'Job Completed',
            'subtitle': '${item['issue'] ?? ''} - ${item['userName'] ?? ''}',
            'time': item['completedAt']?.toString().substring(0, 10) ?? '',
            'color': Colors.green,
          };
        }).toList();
      }
      setState(() => _loadingStats = false);
    } catch (e) {
      setState(() => _loadingStats = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.mechanicName;
    _fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white), onPressed: () => setState(() => _isEditing = !_isEditing))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFFF6B00), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Text(widget.mechanicName[0].toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)))),
                      Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Color(0xFFFF6B00), size: 20))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.mechanicName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Verified Mechanic', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: const Text('⭐ 4.8 Rating', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _isOnline ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          Text(_isOnline ? '🟢 Online' : '🔴 Offline', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Switch(value: _isOnline, onChanged: (val) => setState(() => _isOnline = val), activeColor: Colors.white, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Column(children: [Text('$_jobsDone', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))), const Text('Jobs Done', style: TextStyle(color: Colors.grey, fontSize: 12))]))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Column(children: [Text('Rs.${_earnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)), const Text('Earnings', style: TextStyle(color: Colors.grey, fontSize: 12))]))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Column(children: [Text('${_avgRating.toStringAsFixed(1)}⭐', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)), const Text('Rating', style: TextStyle(color: Colors.grey, fontSize: 12))]))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!_isEditing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, children: _selectedSkills.map((skill) => Chip(label: Text(skill), backgroundColor: const Color(0xFFFF6B00), labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList()),
                  ],
                ),
              ),
            if (_isEditing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Full Name', prefixIcon: const Icon(Icons.person_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))))),
                    const SizedBox(height: 12),
                    TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: 'Phone Number', prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))))),
                    const SizedBox(height: 12),
                    const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _skills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return GestureDetector(
                          onTap: () => setState(() { if (isSelected) { _selectedSkills.remove(skill); } else { _selectedSkills.add(skill); } }),
                          child: Chip(label: Text(skill), backgroundColor: isSelected ? const Color(0xFFFF6B00) : Colors.grey[200], labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                      const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (_loadingStats)
                    const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Color(0xFFFF6B00))))
                  else if (_activities.isEmpty)
                    const Padding(padding: EdgeInsets.all(12), child: Text('No completed jobs yet', style: TextStyle(color: Colors.grey)))
                  else
                    ..._activities.map((activity) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: (activity['color'] as Color).withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(activity['icon'], style: const TextStyle(fontSize: 20)))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(activity['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(activity['subtitle'], style: TextStyle(color: Colors.grey[600], fontSize: 12))])),
                          Text(activity['time'], style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ============ RATING SCREEN ============
class RatingScreen extends StatefulWidget {
  final String mechanicName;
  final String requestId;
  final String userName;
  final String userEmail;
  final int userId;
  final String userLanguage;
  const RatingScreen({
    super.key,
    required this.mechanicName,
    required this.requestId,
    required this.userName,
    required this.userEmail,
    required this.userId,
    this.userLanguage = 'en',
  });
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('Rate Your Mechanic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _submitted ? _buildThankYou() : _buildRatingForm(),
    );
  }

  Widget _buildThankYou() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text('Thank You!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your rating has been submitted!', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UserHomeScreen(
                userName: widget.userName,
                userEmail: widget.userEmail,
                userId: widget.userId,
                userLanguage: widget.userLanguage,
              )),
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(radius: 50, backgroundColor: const Color(0xFFFF6B00), child: Text(widget.mechanicName[0].toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))),
          const SizedBox(height: 16),
          Text(widget.mechanicName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('How was your experience?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => GestureDetector(
              onTap: () => setState(() => _rating = index + 1),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(index < _rating ? Icons.star : Icons.star_border, color: const Color(0xFFFF6B00), size: 48)),
            )),
          ),
          const SizedBox(height: 8),
          Text(
            _rating == 0 ? 'Tap to rate' : _rating == 1 ? '😞 Poor' : _rating == 2 ? '😐 Fair' : _rating == 3 ? '🙂 Good' : _rating == 4 ? '😊 Very Good' : '🤩 Excellent!',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(controller: _commentController, maxLines: 4, decoration: InputDecoration(hintText: 'Add a comment (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B00))))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _rating == 0
                  ? null
                  : () async {
                      try {
                        await http.post(
                          Uri.parse('http://10.0.2.2:8081/api/users/rate'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'requestId': widget.requestId,
                            'rating': _rating,
                            'review': _commentController.text.trim(),
                          }),
                        );
                      } catch (e) {
                        // ignore, still show thank you
                      }
                      if (mounted) setState(() => _submitted = true);
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Submit Rating', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          if (_rating == 0) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Please select a rating first!', style: TextStyle(color: Colors.red, fontSize: 12))),
        ],
      ),
    );
  }
}

// ============ PAYMENT SCREEN ============
class PaymentScreen extends StatefulWidget {
  final String mechanicName;
  final String issue;
  final double amount;
  final String requestId;
  final StompClient stompClient;
  final int userId;
  final String userName;
  final String userEmail;
  const PaymentScreen({
    super.key,
    required this.mechanicName,
    required this.issue,
    required this.amount,
    required this.requestId,
    required this.stompClient,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPayment = '';
  bool _paid = false;
  bool _waitingCashConfirm = false;

  @override
  void initState() {
    super.initState();
    widget.stompClient.subscribe(
      destination: '/topic/user/${widget.userId}',
      callback: (frame) {
        final data = jsonDecode(frame.body!);
        if (data['type'] == 'PAYMENT_CONFIRMED' && mounted) {
          setState(() {
            _waitingCashConfirm = false;
            _paid = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cost = widget.amount.toInt();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _paid
          ? _buildSuccess()
          : (_waitingCashConfirm ? _buildWaiting() : _buildPayment(cost)),
    );
  }

  Widget _buildWaiting() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFFF6B00)),
          SizedBox(height: 16),
          Text('Waiting for mechanic to confirm\ncash received...', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 16),
          const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Thank you for using MechNow!', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RatingScreen(
              mechanicName: widget.mechanicName,
              requestId: widget.requestId,
              userName: widget.userName,
              userEmail: widget.userEmail,
              userId: widget.userId,
            ))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Rate Your Mechanic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPayment(int cost) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bill Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Service'), Text(widget.issue)]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Mechanic'), Text(widget.mechanicName)]),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Rs. $cost', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF6B00))),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _paymentOption('💵', 'Cash Payment', 'Pay directly to mechanic'),
          _paymentOption('💳', 'Card Payment', 'Visa / MasterCard'),
          _paymentOption('📱', 'Dialog Pay', 'Mobile payment'),
          _paymentOption('🏦', 'Bank Transfer', 'Online banking'),
          const SizedBox(height: 24),
                    SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedPayment.isEmpty
                  ? null
                  : () {
                      if (_selectedPayment == 'Cash Payment') {
                        widget.stompClient.send(
                          destination: '/app/payment.cash.select',
                          body: jsonEncode({'requestId': widget.requestId}),
                        );
                        setState(() => _waitingCashConfirm = true);
                      } else {
                        widget.stompClient.send(
                          destination: '/app/payment.card.complete',
                          body: jsonEncode({'requestId': widget.requestId}),
                        );
                        setState(() => _paid = true);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(_selectedPayment.isEmpty ? 'Select Payment Method' : 'Pay Rs. $cost', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String icon, String title, String subtitle) {
    final isSelected = _selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[300]!, width: isSelected ? 2 : 1), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)]),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12))])),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFFF6B00)),
          ],
        ),
      ),
    );
  }
}


// ============ CALL SCREEN (WebRTC Voice Call) ============
class CallScreen extends StatefulWidget {
  final StompClient stompClient;
  final bool isCaller;
  final String myType; // 'user' or 'mechanic'
  final int myId;
  final String peerType;
  final int peerId;
  final String peerName;
  final Map<String, dynamic>? incomingOffer;

  const CallScreen({
    super.key,
    required this.stompClient,
    required this.isCaller,
    required this.myType,
    required this.myId,
    required this.peerType,
    required this.peerId,
    required this.peerName,
    this.incomingOffer,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _muted = false;
  String _status = 'Connecting...';

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _setupCall();
  }

  Future<void> _setupCall() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _sendSignal({
        'type': 'ICE_CANDIDATE',
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        if (mounted) setState(() => _status = 'Connected');
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        if (mounted) {
          setState(() => _status = 'Call ended');
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    };

    widget.stompClient.subscribe(
      destination: '/topic/call/${widget.myType}/${widget.myId}',
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        if (data['type'] == 'ANSWER' && widget.isCaller) {
          await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'], 'answer'));
        } else if (data['type'] == 'ICE_CANDIDATE') {
          await _peerConnection!.addCandidate(
            RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
          );
        } else if (data['type'] == 'END_CALL') {
          if (mounted) Navigator.pop(context);
        }
      },
    );

    if (widget.isCaller) {
      setState(() => _status = 'Calling ${widget.peerName}...');
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _sendSignal({'type': 'OFFER', 'sdp': offer.sdp});
    } else {
      setState(() => _status = 'Connecting...');
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(widget.incomingOffer!['sdp'], 'offer'));
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendSignal({'type': 'ANSWER', 'sdp': answer.sdp});
    }
  }

  void _sendSignal(Map<String, dynamic> payload) {
    payload['targetType'] = widget.peerType;
    payload['targetId'] = widget.peerId.toString();
    widget.stompClient.send(destination: '/app/call.signal', body: jsonEncode(payload));
  }

  void _toggleMute() {
    _muted = !_muted;
    _localStream?.getAudioTracks().forEach((track) => track.enabled = !_muted);
    setState(() {});
  }

  void _endCall() {
    _sendSignal({'type': 'END_CALL'});
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B00),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Text(
                  widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)),
                ),
              ),
              const SizedBox(height: 24),
              Text(widget.peerName, style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_status, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleMute,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: _muted ? Colors.white : Colors.white24,
                      child: Icon(_muted ? Icons.mic_off : Icons.mic, color: _muted ? const Color(0xFFFF6B00) : Colors.white),
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: _endCall,
                    child: const CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.call_end, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}