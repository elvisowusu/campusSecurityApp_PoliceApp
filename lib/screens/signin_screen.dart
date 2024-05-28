import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _SignInformKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      image:'assets/images/security.avif',
      customContainer: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 18,) 
          ),
          Expanded(
            flex: 7,
            child: Container(
              decoration:const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Form(
                key: _SignInformKey,
                child:const Column(
              )),
            )
          ),
        ],
      ),
    );
  }
}
