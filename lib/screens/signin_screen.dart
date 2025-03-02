import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:security_app/components/counselor/notifications.dart';
import 'package:security_app/firebase_authentication/firebase_auth_services.dart';
import 'package:security_app/screens/forgot_password_screen.dart';
import 'package:security_app/screens/personnel_type.dart';
import 'package:security_app/theme/theme.dart';
import 'package:security_app/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/police officer/police_screen.dart';

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
                                      ? Icons.visibility_off
                                      : Icons.visibility,
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
                          //Reset Password 
                              const ForgotPasswordScreen(),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ), // Signup button
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
                            height: 5.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'Or',
                                  style: TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          // Sign in with Google
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
                                            FontAwesomeIcons.google,
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
        // Check user's role and navigate accordingly
        bool isPoliceOfficer = await _checkUserRole(user.uid, 'police_officers');
        bool isCounselor = await _checkUserRole(user.uid, 'counselors');

        if (isPoliceOfficer) {
          Fluttertoast.showToast(msg: 'Sign in successful as Police Officer!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (e) => const PoliceScreen(),
            ),
          );
        } else if (isCounselor) {
          Fluttertoast.showToast(msg: 'Sign in successful as Counselor!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (e) => CounselorNotificationsPage(),
            ),
          );
        } else {
          Fluttertoast.showToast(msg: 'Unauthorized role or role not found.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Sign in failed!');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isSigningIn = false;
      });
      Fluttertoast.showToast(msg: e.message ?? 'An error occurred during sign in.');
    }
  } else {
    setState(() {
      // Update error messages if form is not valid
      _emailError = _emailController.text.isEmpty ? 'Please enter Email' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Please enter Password' : null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please complete the form and agree to the terms.'),
      ),
    );
  }
}

// Helper function to check user's role
Future<bool> _checkUserRole(String uid, String collection) async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection(collection)
      .doc(uid)
      .get();
  return userDoc.exists;
}

void _signInWithGoogle() async {
  // ignore: no_leading_underscores_for_local_identifiers
  FirebaseAuthService _authService = FirebaseAuthService();

  setState(() {
    _isSigningInWithGoogle = true;
  });

  User? user = await _authService.signInWithGoogle();

  setState(() {
    _isSigningInWithGoogle = false;
  });

  if (user != null) {
    // Check user's role and navigate accordingly
    bool isPoliceOfficer = await _checkUserRole(user.uid, 'police_officers');
    bool isCounselor = await _checkUserRole(user.uid, 'counselors');

    if (isPoliceOfficer) {
      Fluttertoast.showToast(msg: 'Sign in successful as Police Officer!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (e) => const PoliceScreen(),
        ),
      );
    } else if (isCounselor) {
      Fluttertoast.showToast(msg: 'Sign in successful as Counselor!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (e) => CounselorNotificationsPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: 'Unauthorized role or role not found.');
    }
  } else {
    Fluttertoast.showToast(msg: 'Sign in with Google failed or cancelled.');
  }
}


}
