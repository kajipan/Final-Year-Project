import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

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
                            body: jsonEncode({'email': _emailController.text.trim(), 'password': _passwordController.text.trim()}),
                          );
                          if (response.statusCode == 200) {
                            final user = jsonDecode(response.body);
                            if (!context.mounted) return;
                            Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => _selectedRole == 'user'
                                  ? UserHomeScreen(userName: user['name'], userEmail: user['email'])
                                  : MechanicHomeScreen(mechanicName: user['name']),
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
  const UserHomeScreen({super.key, required this.userName, required this.userEmail});
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userName: widget.userName, userEmail: widget.userEmail))),
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
                  const Text('Select Your Vehicle Issue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Mechanic found! Rajan is on his way for $_selectedIssue - ETA 8 mins', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nearby Mechanics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _mechanics.isEmpty
                      ? const Center(child: Text('No mechanics available nearby', style: TextStyle(color: Colors.grey)))
                      : Column(
                          children: _mechanics.map<Widget>((mechanic) {
                            return Column(children: [
                              _mechanicCard(mechanic['name'] ?? 'Unknown', '${(_mechanics.indexOf(mechanic) + 1) * 0.8} km', '4.8', 'All Vehicles'),
                              const SizedBox(height: 10),
                            ]);
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () {
            if (_selectedIssue == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an issue first!'), backgroundColor: Colors.red));
            } else {
              setState(() {
                _requestSent = true;
                if (_currentPosition != null) {
                  _markers.add(Marker(
                    markerId: const MarkerId('mechanic'),
                    position: LatLng(_currentPosition!.latitude + 0.005, _currentPosition!.longitude + 0.005),
                    infoWindow: const InfoWindow(title: 'Rajan Kumar - Mechanic'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  ));
                }
              });
              Future.delayed(const Duration(seconds: 5), () {
                if (mounted) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(mechanicName: 'Rajan Kumar', issue: _selectedIssue ?? 'Other')));
                }
              });
            }
          },
          icon: const Icon(Icons.build, color: Colors.white),
          label: const Text('Request Mechanic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
  const MechanicHomeScreen({super.key, required this.mechanicName});
  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  bool _isOnline = true;
  final List<Map<String, String>> _requests = [
    {'name': 'Arun Kumar', 'issue': 'Battery issue', 'distance': '0.8 km', 'time': '2 mins ago', 'vehicle': 'Toyota Corolla 2019'},
    {'name': 'Priya S', 'issue': 'Flat tyre', 'distance': '1.5 km', 'time': '5 mins ago', 'vehicle': 'Honda Fit 2020'},
    {'name': 'Mohan R', 'issue': 'Overheating', 'distance': '2.3 km', 'time': '8 mins ago', 'vehicle': 'Suzuki Alto 2018'},
  ];

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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MechanicProfileScreen(mechanicName: widget.mechanicName))),
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
                              children: [
                                Expanded(child: OutlinedButton(onPressed: () => setState(() => _requests.removeAt(index)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)), child: const Text('Decline', style: TextStyle(color: Colors.red)))),
                                const SizedBox(width: 10),
                                Expanded(child: ElevatedButton(
                                  onPressed: () {
                                    setState(() => _requests.removeAt(index));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Accepted!'), backgroundColor: Colors.green));
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
  const ProfileScreen({super.key, required this.userName, required this.userEmail});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  final List<Map<String, dynamic>> _activities = [
    {'icon': '🔧', 'title': 'Mechanic Requested', 'subtitle': 'Battery issue - Rajan Kumar', 'time': '2 hours ago', 'color': Colors.orange},
    {'icon': '✅', 'title': 'Service Completed', 'subtitle': 'Tyre replacement - Suresh M', 'time': 'Yesterday', 'color': Colors.green},
    {'icon': '💬', 'title': 'AI Chat Session', 'subtitle': 'Engine overheating query', 'time': '2 days ago', 'color': Colors.blue},
    {'icon': '🔧', 'title': 'Mechanic Requested', 'subtitle': 'Brake issue - Anbu S', 'time': '1 week ago', 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
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
  const MechanicProfileScreen({super.key, required this.mechanicName});
  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isOnline = true;
  final List<String> _skills = ['Engine', 'Electrical', 'Tyre', 'Battery', 'Brake', 'AC'];
  final List<String> _selectedSkills = ['Engine', 'Electrical'];

  final List<Map<String, dynamic>> _activities = [
    {'icon': '✅', 'title': 'Job Completed', 'subtitle': 'Battery - Arun Kumar', 'time': '1 hour ago', 'color': Colors.green},
    {'icon': '✅', 'title': 'Job Completed', 'subtitle': 'Tyre - Priya S', 'time': 'Yesterday', 'color': Colors.green},
    {'icon': '❌', 'title': 'Job Declined', 'subtitle': 'Engine - Mohan R', 'time': '2 days ago', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.mechanicName;
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
                  Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: const Column(children: [Text('24', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))), Text('Jobs Done', style: TextStyle(color: Colors.grey, fontSize: 12))]))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: const Column(children: [Text('Rs.12,400', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)), Text('Earnings', style: TextStyle(color: Colors.grey, fontSize: 12))]))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: const Column(children: [Text('4.8⭐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)), Text('Rating', style: TextStyle(color: Colors.grey, fontSize: 12))]))),
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
  const RatingScreen({super.key, required this.mechanicName});
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
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
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
              onPressed: _rating == 0 ? null : () => setState(() => _submitted = true),
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
  const PaymentScreen({super.key, required this.mechanicName, required this.issue});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPayment = '';
  bool _paid = false;

  final Map<String, int> _issueCost = {
    'Battery': 2500, 'Tyre': 1500, 'Engine': 5000, 'Overheating': 3000,
    'Brake': 3500, 'Strange Noise': 2000, 'Electrical': 2500, 'Other': 2000,
  };

  @override
  Widget build(BuildContext context) {
    final cost = _issueCost[widget.issue] ?? 2000;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _paid ? _buildSuccess() : _buildPayment(cost),
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RatingScreen(mechanicName: widget.mechanicName))),
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
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Service Charge'), Text('Rs. ${cost - 200}')]),
                const SizedBox(height: 8),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Platform Fee'), Text('Rs. 200')]),
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
              onPressed: _selectedPayment.isEmpty ? null : () => setState(() => _paid = true),
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