import 'package:flutter/material.dart';

class ReplyWidget extends StatelessWidget {
  final String replyingToMessage;
  final VoidCallback onCancelReply;

  const ReplyWidget({
    super.key,
    required this.replyingToMessage,
    required this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Replying to: $replyingToMessage',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancelReply,
          ),
        ],
      ),
    );
  }
}
