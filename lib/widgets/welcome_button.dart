import 'package:cs_location_tracker_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({super.key, this.buttonName});
  final String? buttonName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>{
        Navigator.push(context, MaterialPageRoute(builder: (context) =>const SignUpScreen()) )
      },
      child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
              )),
          child: Text(
            buttonName!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )),
    );
  }
}
