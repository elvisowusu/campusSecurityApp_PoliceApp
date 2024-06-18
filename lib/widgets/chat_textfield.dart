import 'package:flutter/material.dart';

class ChatTextField extends StatefulWidget {
  const ChatTextField({super.key, required this.receriverId});
  final String receriverId;

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Type a message',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(  
                borderSide:const BorderSide(
                  color: Colors.grey,
                  width:0,
                  style: BorderStyle.none
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        const SizedBox(
          width: 5,
        ),
        IconButton(
          onPressed: () {
            // Send message to the receiver
          },
          icon: const Icon(Icons.send),
          color: Colors.blue,
        ),
      ],
    );
  }
}