import 'package:flutter/material.dart';

class IndividualChatPage extends StatelessWidget {
  final String contact;

  const IndividualChatPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact),
      ),
      body: const Center(
        child: Text('Individual Chat Room'),
      ),
    );
  }
}