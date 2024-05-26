import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.customContainer});

  final Widget? customContainer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            child: Image.asset('assets/images/WelcomePhoto.avif',
          fit: BoxFit.fitHeight,
          width: double.infinity,
          height: double.infinity,
          ),
          ),
          SafeArea(
            child: customContainer!,
          )
        ],
      )
    );
  }
}