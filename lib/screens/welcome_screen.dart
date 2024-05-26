import 'package:flutter/material.dart';
import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';
import 'package:flutter/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomScaffold(
      customContainer:Column(
          children: [
            Flexible(child: Container(
              child: Center(child: RichText(
                textAlign: TextAlign.center,
                text:const TextSpan(
                  children: [
                    TextSpan(
                      text:'Welcome Back\n',
                      style: TextStyle(color: Colors.green, fontSize: 45, fontWeight: FontWeight.w600) ),
                    TextSpan(
                      text: '\nSign in to see live cases',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.w400)
                    )
                  ],
                ),
              ),

              )
            )),
            const Flexible(child: ButtonBar())
          ],
      )
    );
  }
}
