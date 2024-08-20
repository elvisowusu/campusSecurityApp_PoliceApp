import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_utils.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  final String? replyingToMessage;
  final Timestamp timestamp;
  final String messageId;
  final String? replyingToMessageId;
  final String? selectedMessageId;
  final Function(String) onSelectMessage;
  final Function(String, String) onReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.replyingToMessage,
    required this.timestamp,
    required this.messageId,
    this.replyingToMessageId,
    this.selectedMessageId,
    required this.onSelectMessage,
    required this.onReply,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.selectedMessageId == widget.messageId;
    return Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            _animationController.value +=
                details.primaryDelta! / 100 * (widget.isMe ? -1 : 1);
          },
          onHorizontalDragEnd: (details) {
            if (_animationController.value.abs() > 0.5) {
              widget.onReply(widget.message, widget.messageId);
            }
            _animationController.reverse();
          },
          onLongPress: () {
            // Select the message
            widget.onSelectMessage(widget.messageId);
          },
          onTap: () {
            // Deselect if tapping on the already selected message
            if (isSelected) {
              widget.onSelectMessage('');
            }
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    50 * _animationController.value * (widget.isMe ? -1 : 1),
                    0),
                child: Stack(
                  children: [
                    child!,
                    Positioned(
                      left:
                          widget.isMe ? null : 10 * _animationController.value,
                      right:
                          widget.isMe ? 10 * _animationController.value : null,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Icon(
                          Icons.reply,
                          color: Colors.grey[600],
                          size: 20 * _animationController.value.abs(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 181, 238, 243).withOpacity(0.5)
                    : (widget.isMe ? const Color(0xFFDCF8C6) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: Radius.circular(widget.isMe ? 16.0 : 0.0),
                  bottomRight: Radius.circular(widget.isMe ? 0.0 : 16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.replyingToMessage != null)
                    GestureDetector(
                      onTap: () {
                        if (widget.replyingToMessageId != null) {
                          scrollToMessage(widget.replyingToMessageId!);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5.0),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(widget.replyingToMessage!,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12.0,
                            )),
                      ),
                    ),
                  Text(widget.message,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      )),
                  Text(formatTimestamp(widget.timestamp),
                      style:
                          TextStyle(fontSize: 10.0, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ));
  }
}
