import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs_location_tracker_app/firebase_authentication/firebase_auth_services.dart';
import 'package:cs_location_tracker_app/screens/signin_screen.dart';
import 'package:cs_location_tracker_app/theme/theme.dart';
import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpScreen extends StatefulWidget {
  final String role;
  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  bool _isSigningUp = false;
  bool _isSigningUpWithGoogle = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;

  // Flag for password visibility
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    _fullNameFocusNode.addListener(() {
      if (_fullNameFocusNode.hasFocus) {
        setState(() {
          _fullNameError = null;
        });
      }
    });

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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
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
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _signUpFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 21.0,
                      ),
                      TextFormField(
                        controller: _fullNameController,
                        focusNode: _fullNameFocusNode,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          errorText: _fullNameError,
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
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
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
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText:
                            !_showPassword, // Toggle visibility based on _showPassword flag
                        obscuringCharacter: '*',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        height: 15.0,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: lightColorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'By creating account you have to agree with our Terms and Conditions.',
                              style: TextStyle(
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // Signup button
                      GestureDetector(
                        onTap: _signUp,
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
                                _isSigningUp
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Sign up',
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
                      // Sign up social media logo
                      GestureDetector(
                        onTap: _signUpWithGoogle,
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
                                _isSigningUpWithGoogle
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
                                  "Sign up with Google",
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
                        height: 15.0,
                      ),
                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
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
          ),
        ],
      ),
    );
  }

  void _signUp() async {
    if (_signUpFormKey.currentState!.validate()) {
      //loader
      setState(() {
        _isSigningUp = true;
      });

      String fullName = _fullNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      User? user = await _auth.signUp(email, password);
      setState(() {
        _isSigningUp = false;
      });

      if (user != null) {
        await FirebaseFirestore.instance.collection(widget.role).doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        Fluttertoast.showToast(msg: "Sign up successful");
        Navigator.push(
            context, MaterialPageRoute(builder: (e) => const SignInScreen()));
      } else {
        Fluttertoast.showToast(msg: "Some error happened");
      }
    } else {
      setState(() {
        // Update error messages if form is not valid
        _fullNameError =
            _fullNameController.text.isEmpty ? 'Please enter Full name' : null;
        _emailError =
            _emailController.text.isEmpty ? 'Please enter Email' : null;
        _passwordError =
            _passwordController.text.isEmpty ? 'Please enter Password' : null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete the form and agree to the terms.')),
      );
    }
  }

  // Sign up with Google
  void _signUpWithGoogle() async {

    setState(() {
      _isSigningUpWithGoogle = true;
    });

    try {
      // Perform Google sign-in
      User? user = await FirebaseAuthService().signInWithGoogle();

      if (user != null) {
        // Check if user already exists in the database
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(widget.role)
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // User already exists, handle accordingly (e.g., log in the user)
          Fluttertoast.showToast(msg: "Google account already exists!");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (e) => const SignInScreen()),
          );
        } else {
          // Add user to the database
          await FirebaseFirestore.instance
              .collection(widget.role)
              .doc(user.uid)
              .set({
            'fullName': user.displayName,
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
          Fluttertoast.showToast(msg: "Sign up successful");
          setState(() {
            _isSigningUpWithGoogle = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (e) => const SignInScreen()),
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Some error happened");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error signing up with Google: $e");
      Fluttertoast.showToast(msg: "Failed to sign up with Google.");
    } finally {
      setState(() {
        _isSigningUpWithGoogle = false;
      });
    }
  }
}
