import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

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
      backgroundColor: const Color(0xFFFF6B00),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_repair, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text('MechNow',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            const Text('On-Demand Vehicle Repair',
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

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
                  child: const Icon(Icons.car_repair,
                      size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text('MechNow',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B00))),
                const Text('Welcome Back!',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRole = 'user'),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'user'
                                ? const Color(0xFFFF6B00)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.person,
                                  color: _selectedRole == 'user'
                                      ? Colors.white
                                      : Colors.grey),
                              Text('Vehicle Owner',
                                  style: TextStyle(
                                      color: _selectedRole == 'user'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRole = 'mechanic'),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'mechanic'
                                ? const Color(0xFFFF6B00)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.build,
                                  color: _selectedRole == 'mechanic'
                                      ? Colors.white
                                      : Colors.grey),
                              Text('Mechanic',
                                  style: TextStyle(
                                      color: _selectedRole == 'mechanic'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter email' : null,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B00)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter password' : null,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B00)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final response = await http.post(
                            Uri.parse(
                                'http://10.0.2.2:8081/api/users/login'),
                            headers: {
                              'Content-Type': 'application/json'
                            },
                            body: jsonEncode({
                              'email': _emailController.text.trim(),
                              'password':
                                  _passwordController.text.trim(),
                            }),
                          );
                          if (response.statusCode == 200) {
                            final user = jsonDecode(response.body);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    _selectedRole == 'user'
                                        ? UserHomeScreen(
                                            userName: user['name'],
                                            userEmail: user['email'],
                                          )
                                        : MechanicHomeScreen(
                                            mechanicName: user['name']),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.body),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Connection error! Check backend.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Login',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No account? '),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text(
                        'Register Here',
                        style: TextStyle(
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.bold),
                      ),
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
  String _selectedRole = 'user';
  String? _selectedVehicleType;
  String? _selectedVehicleModel;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final List<String> _vehicleTypes = [
    'Car', 'Motorcycle', 'Tuk-Tuk', 'Van', 'Truck'
  ];

  final Map<String, List<String>> _vehicleModels = {
    'Car': ['Toyota Corolla', 'Honda Fit', 'Suzuki Alto', 'Nissan Sunny', 'Hyundai i10'],
    'Motorcycle': ['Honda CB', 'Yamaha FZ', 'Bajaj Pulsar', 'TVS Apache'],
    'Tuk-Tuk': ['Bajaj RE', 'TVS King', 'Piaggio Ape'],
    'Van': ['Toyota HiAce', 'Mitsubishi L300', 'Ford Transit'],
    'Truck': ['Isuzu', 'Ashok Leyland', 'TATA'],
  };

  Future<void> _register({bool skipVehicle = false}) async {
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
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registered Successfully! Please Login'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.body),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error! Check backend.'),
            backgroundColor: Colors.red,
          ),
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
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                const Text('Register As',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRole = 'user'),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'user'
                                ? const Color(0xFFFF6B00)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.person,
                                  color: _selectedRole == 'user'
                                      ? Colors.white
                                      : Colors.grey),
                              Text('Vehicle Owner',
                                  style: TextStyle(
                                      color: _selectedRole == 'user'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRole = 'mechanic'),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'mechanic'
                                ? const Color(0xFFFF6B00)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.build,
                                  color: _selectedRole == 'mechanic'
                                      ? Colors.white
                                      : Colors.grey),
                              Text('Mechanic',
                                  style: TextStyle(
                                      color: _selectedRole == 'mechanic'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Name
                TextFormField(
                  controller: _nameController,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter name' : null,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B00)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter phone number' : null,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B00)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Email
                TextFormField(
                  controller: _emailController,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter email' : null,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B00)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password
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
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B00)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  validator: (v) {
                    if (v!.isEmpty) return 'Please confirm password';
                    if (v != _passwordController.text)
                      return 'Passwords do not match!';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() =>
                          _confirmPasswordVisible =
                              !_confirmPasswordVisible),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B00)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Vehicle Details - only for users
                if (_selectedRole == 'user') ...[
                  const Text('Vehicle Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    hint: const Text('Select Vehicle Type'),
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.directions_car),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFFF6B00)),
                      ),
                    ),
                    items: _vehicleTypes
                        .map((type) => DropdownMenuItem(
                            value: type, child: Text(type)))
                        .toList(),
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFFF6B00)),
                        ),
                      ),
                      items: _vehicleModels[_selectedVehicleType]!
                          .map((model) => DropdownMenuItem(
                              value: model, child: Text(model)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedVehicleModel = val),
                    ),
                  const SizedBox(height: 20),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _register(skipVehicle: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Register',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Skip Vehicle Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _register(skipVehicle: true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B00)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Skip Vehicle & Register',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFFF6B00),
                              fontWeight: FontWeight.bold)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Register',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

class UserHomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  const UserHomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _requestSent = false;
  String? _selectedIssue;
  String? _selectedVehicleType;
  String? _selectedVehicleModel;
  bool _vehicleSelected = false;

  final List<String> _vehicleTypes = [
    'Car', 'Motorcycle', 'Tuk-Tuk', 'Van', 'Truck'
  ];

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
    // Show vehicle selection dialog on login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVehicleDialog();
    });
  }

  void _showVehicleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Your Vehicle',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Which vehicle are you using today?'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedVehicleType,
                  hint: const Text('Vehicle Type'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _vehicleTypes
                      .map((type) => DropdownMenuItem(
                          value: type, child: Text(type)))
                      .toList(),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: _vehicleModels[_selectedVehicleType]!
                        .map((model) => DropdownMenuItem(
                            value: model, child: Text(model)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => _selectedVehicleModel = val),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _vehicleSelected = false);
                Navigator.pop(context);
              },
              child: const Text('Skip',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedVehicleType != null &&
                    _selectedVehicleModel != null) {
                  setState(() => _vehicleSelected = true);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00)),
              child: const Text('Confirm',
                  style: TextStyle(color: Colors.white)),
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
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_vehicleSelected)
            IconButton(
              icon: const Icon(Icons.directions_car, color: Colors.white),
              onPressed: _showVehicleDialog,
              tooltip: 'Change Vehicle',
            ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChatScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Vehicle Info Banner
            if (_vehicleSelected && _selectedVehicleModel != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: Colors.orange[50],
                child: Row(
                  children: [
                    const Icon(Icons.directions_car,
                        color: Color(0xFFFF6B00), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Current Vehicle: $_selectedVehicleModel',
                      style: const TextStyle(
                          color: Color(0xFFFF6B00),
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showVehicleDialog,
                      child: const Text('Change',
                          style: TextStyle(
                              color: Color(0xFFFF6B00),
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),

            // Map Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin,
                            color: Color(0xFFFF6B00), size: 50),
                        Text('Your Location',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.white)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 50,
                    child: _mechanicPin('Rajan', '0.8 km'),
                  ),
                  Positioned(
                    top: 120,
                    right: 40,
                    child: _mechanicPin('Kumar', '1.2 km'),
                  ),
                ],
              ),
            ),

            // Issue Selection
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Your Vehicle Issue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _issues.length,
                    itemBuilder: (context, index) {
                      final issue = _issues[index];
                      final isSelected =
                          _selectedIssue == issue['label'];
                      return GestureDetector(
                        onTap: () => setState(
                            () => _selectedIssue = issue['label']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6B00)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6B00)
                                  : Colors.grey[300]!,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12, blurRadius: 3)
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(issue['icon'],
                                  style:
                                      const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                issue['label'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Mechanic found! Rajan is on his way for $_selectedIssue - ETA 8 mins',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nearby Mechanics',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _mechanicCard('Rajan Kumar', '0.8 km', '4.8',
                      'Engine, Electrical'),
                  const SizedBox(height: 10),
                  _mechanicCard(
                      'Suresh M', '1.2 km', '4.6', 'Tyre, Battery'),
                  const SizedBox(height: 10),
                  _mechanicCard(
                      'Anbu S', '2.1 km', '4.9', 'All Vehicles'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select an issue first!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              setState(() => _requestSent = true);
            }
          },
          icon: const Icon(Icons.build, color: Colors.white),
          label: const Text('Request Mechanic',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _mechanicPin(String name, String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.build, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text('$name\n$distance',
              style:
                  const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _mechanicCard(
      String name, String distance, String rating, String skills) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFF6B00),
            child: Text(name[0],
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(skills,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('⭐ $rating'),
              Text(distance,
                  style: const TextStyle(
                      color: Color(0xFFFF6B00))),
            ],
          ),
        ],
      ),
    );
  }
}

class MechanicHomeScreen extends StatefulWidget {
  final String mechanicName;
  const MechanicHomeScreen({super.key, required this.mechanicName});
  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  bool _isOnline = true;
  final List<Map<String, String>> _requests = [
    {
      'name': 'Arun Kumar',
      'issue': 'Battery issue',
      'distance': '0.8 km',
      'time': '2 mins ago',
      'vehicle': 'Toyota Corolla 2019',
    },
    {
      'name': 'Priya S',
      'issue': 'Flat tyre',
      'distance': '1.5 km',
      'time': '5 mins ago',
      'vehicle': 'Honda Fit 2020',
    },
    {
      'name': 'Mohan R',
      'issue': 'Overheating',
      'distance': '2.3 km',
      'time': '8 mins ago',
      'vehicle': 'Suzuki Alto 2018',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        automaticallyImplyLeading: false,
        title: Text('Hi, ${widget.mechanicName}!',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5)
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF6B00),
                  radius: 25,
                  child: Text(
                    widget.mechanicName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.mechanicName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(
                        _isOnline
                            ? 'Online - Accepting Jobs'
                            : 'Offline',
                        style: TextStyle(
                            color: _isOnline
                                ? Colors.green
                                : Colors.red),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (val) =>
                      setState(() => _isOnline = val),
                  activeColor: const Color(0xFFFF6B00),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Incoming Requests',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isOnline
                ? ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final req = _requests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12, blurRadius: 5)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req['name']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text(req['vehicle']!,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(req['issue']!),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Color(0xFFFF6B00),
                                    size: 14),
                                Text(req['distance']!,
                                    style: const TextStyle(
                                        color: Color(0xFFFF6B00))),
                                const Spacer(),
                                Text(req['time']!,
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(() =>
                                        _requests.removeAt(index)),
                                    style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.red)),
                                    child: const Text('Decline',
                                        style: TextStyle(
                                            color: Colors.red)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() =>
                                          _requests.removeAt(index));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Job Accepted!'),
                                        backgroundColor: Colors.green,
                                      ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFF6B00)),
                                    child: const Text('Accept',
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text('You are Offline',
                            style:
                                TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hello! I am MechNow AI Assistant. Please describe your vehicle issue!',
      'isBot': true,
    },
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add({'text': text, 'isBot': false}));
    _controller.clear();

    String reply =
        'I understand you have a vehicle issue. Can you describe more?';
    final lower = text.toLowerCase();
    if (lower.contains('battery'))
      reply =
          'Battery Issue Detected!\n• Check if headlights are dim\n• Try jump starting\n• Shall I find a mechanic nearby?';
    else if (lower.contains('tyre') || lower.contains('tire'))
      reply =
          'Tyre Issue Detected!\n• Move to safe location\n• Turn on hazard lights\n• Shall I find a mechanic nearby?';
    else if (lower.contains('engine'))
      reply =
          'Engine Issue Detected!\n• Stop the vehicle safely\n• Check engine temperature\n• Shall I find a mechanic nearby?';
    else if (lower.contains('overheat'))
      reply =
          'Overheating Detected!\n• Pull over immediately\n• Turn off AC\n• Let engine cool 30 mins\n• Shall I find a mechanic nearby?';
    else if (lower.contains('brake'))
      reply =
          'Brake Issue - URGENT!\n• Use handbrake if needed\n• Do not drive\n• Shall I find a mechanic nearby?';

    Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(
            () => _messages.add({'text': reply, 'isBot': true})));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: const Text('MechNow AI Chat',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.orange[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Battery', 'Tyre', 'Engine', 'Overheat', 'Brake'
                ]
                    .map((label) => GestureDetector(
                          onTap: () {
                            _controller.text = label;
                            _send();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B00),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(label,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12)),
                          ),
                        ))
                    .toList(),
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
                  alignment: msg['isBot']
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg['isBot']
                          ? Colors.grey[200]
                          : const Color(0xFFFF6B00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'],
                        style: TextStyle(
                            color: msg['isBot']
                                ? Colors.black
                                : Colors.white)),
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
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Describe your vehicle issue...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFF6B00),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 20),
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