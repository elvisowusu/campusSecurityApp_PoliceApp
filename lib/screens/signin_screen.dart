import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});


  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      image:'assets/images/security.avif',
      customContainer: Column(
        children: [
          const Expanded(
            child: SizedBox(
              height: 18,) 
          ),
          Expanded(
            child: Container(
              decoration:const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}
