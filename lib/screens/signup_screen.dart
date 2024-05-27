import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      customContainer: Text('Sign Up'),
    );
  }
}