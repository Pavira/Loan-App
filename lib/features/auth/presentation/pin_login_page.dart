import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/navigation/app_navigation.dart';
import 'package:loan_app/features/auth/data/auth_repository.dart';
import 'package:loan_app/widgets/custom_snackbar.dart';
import 'package:local_auth/local_auth.dart';

class PinLoginPage extends StatefulWidget {
  @override
  _PinLoginPageState createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // _authenticateUser();
    // Make status bar white and icons dark
    // Set status bar style
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.white,
    //     statusBarIconBrightness: Brightness.dark,
    //   ),
    // );

    // // Autofocus first pin box
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _focusNodes[0].requestFocus();
    // });
  }

  Future<void> _authenticateUser() async {
    try {
      final bool isSupported = await auth.isDeviceSupported();
      bool isAuthenticated = false;

      if (isSupported) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to continue',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
      }

      // if (isAuthenticated) {
      //   Future.delayed(const Duration(milliseconds: 500), () {
      //     Navigator.of(
      //       context,
      //     ).pushReplacement(MaterialPageRoute(builder: (_) => PinLoginPage()));
      //   });
      // } else {
      //   _showAuthFailedDialog();
      // }

      if (isAuthenticated) {
        // Navigate to the main app after auth
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => AppNavigation()));
      } else {
        // _showAuthFailedDialog();
      }
    } catch (e) {
      print('Biometric error: $e');
      // _showAuthFailedDialog();
    }
  }

  void _onPinChanged(String value, int index) async {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_controllers.every((c) => c.text.length == 1)) {
      final enteredPin = _controllers.map((c) => c.text).join();

      setState(() => _isVerifying = true);

      try {
        final bool isValid = await AuthRepository().validatePin(enteredPin);

        if (isValid) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          showCustomSnackbar(context, 'Invalid PIN. Please try again.');
          _clearAll();
        }
      } catch (e) {
        showCustomSnackbar(context, 'An error occurred. Please try again.');
      } finally {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _clearAll() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Widget _buildPinBox(int index) {
    return Focus(
      onFocusChange: (_) => setState(() {}),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                _focusNodes[index].hasFocus
                    ? Colors.blue
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: RawKeyboardListener(
            focusNode: FocusNode(), // Separate listener node
            onKey: (event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                if (_controllers[index].text.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                  _controllers[index - 1].clear();
                }
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              maxLength: 1,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.only(bottom: 6),
              ),
              onChanged: (value) => _onPinChanged(value, index),
            ),
          ),
        ),
      ),
    );
  }

  // void _openBiometricAuth() {
  //   Navigator.of(context).push(
  //     PageRouteBuilder(
  //       opaque: false,
  //       pageBuilder: (_, __, ___) => SplashPage(),
  //       transitionsBuilder:
  //           (_, a, __, child) => FadeTransition(opacity: a, child: child),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                'Welcome to Royal Finance Solutions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your secure 4-digit PIN',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, _buildPinBox),
              ),
              // 👇 Loader Overlay
              if (_isVerifying)
                Container(
                  // color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 40),
              GestureDetector(
                // onTap: () => _authenticateUser(),
                onTap:
                    () => showCustomSnackbar(
                      context,
                      "Please swtich to paid version to use this feature",
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.fingerprint, color: Colors.blueAccent, size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Use biometric or device lock',
                      style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.08),
              Image.asset(
                'assets/images/loan.jpg',
                height: screenHeight * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
