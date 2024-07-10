import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs_location_tracker_app/common/toast.dart';
import 'package:cs_location_tracker_app/components/live_cases/emergency_notification.dart';
import 'package:cs_location_tracker_app/components/old_reports_cases/notifications.dart';
import 'package:cs_location_tracker_app/firebase_authentication/firebase_auth_services.dart';
import 'package:cs_location_tracker_app/screens/forgot_password_screen.dart';
import 'package:cs_location_tracker_app/screens/personnel_type.dart';
import 'package:cs_location_tracker_app/theme/theme.dart';
import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _signInformKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  //loader
  bool _isSigningIn = false;
  bool _isSigningInWithGoogle = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Define FocusNodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Track error messages for fields
  String? _emailError;
  String? _passwordError;

  // Flag for password visibility
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    // Add listeners to clear errors on focus
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() {
          _emailError = null;
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      image: 'assets/images/security.avif',
      customContainer: Column(
        children: [
          const Expanded(
              flex: 1,
              child: SizedBox(
                height: 18,
              )),
          Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                      key: _signInformKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text('Email'),
                                hintText: 'Enter Email',
                                hintStyle:
                                    const TextStyle(color: Colors.black26),
                                errorText: _emailError,
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText:
                                !_showPassword, // Toggle visibility based on _showPassword flag
                            obscuringCharacter: '*',
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              label: const Text('Password'),
                              hintText: 'Enter Password',
                              hintStyle: const TextStyle(color: Colors.black26),
                              errorText: _passwordError,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: lightColorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: lightColorScheme.primary,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(color: Colors.black45),
                                )
                              ]),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (e) =>
                                              const ForgotPasswordScreen()));
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: lightColorScheme.primary),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: _signIn,
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _isSigningIn
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            'Sign in',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          GestureDetector(
                            onTap: _signInWithGoogle,
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _isSigningInWithGoogle
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.g_mobiledata_outlined,
                                            color: Colors.white,
                                          ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "Sign in with Google",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.black45),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (e) =>
                                              const RoleSelectionScreen()));
                                },
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: lightColorScheme.primary),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                ),
              )),
        ],
      ),
    );
  }

  void _signIn() async {
    if (_signInformKey.currentState!.validate()) {
      setState(() {
        _isSigningIn = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        User? user = await _auth.signIn(email, password);
        setState(() {
          _isSigningIn = false;
        });

        if (user != null) {
          // Fetch user role from Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final role = userDoc.data()?['role'];

          if (role == 'Police Officer') {
            showToast(message: 'Sign in successful!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (e) => const EmergencyNotifications()),
            );
          } else if (role == 'Counsellor') {
            showToast(message: 'Sign in successful!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (e) => const MainChatPage()),
            );
          } else {
            showToast(message: 'Unauthorized role or role not found.');
          }
        } else {
          showToast(message: 'Sign in failed!');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isSigningIn = false;
        });
        showToast(message: e.message ?? 'An error occurred during sign in.');
      }
    } else {
      setState(() {
        // Update error messages if form is not valid
        _emailError =
            _emailController.text.isEmpty ? 'Please enter Email' : null;
        _passwordError =
            _passwordController.text.isEmpty ? 'Please enter Password' : null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the form and agree to the terms.'),
        ),
      );
    }
  }

  // Sign in with Google
  void _signInWithGoogle() async {
    setState(() {
      _isSigningInWithGoogle = true;
    });
  }
}
