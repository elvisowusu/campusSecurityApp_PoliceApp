import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'message_bubble.dart';
import 'message_input.dart';
import 'reply_widget.dart';
import 'message_utils.dart';

class CounselorStudentPrivateChatPage extends StatefulWidget {
  const CounselorStudentPrivateChatPage({super.key, required this.studentId});

  final String studentId;

  @override
  State<CounselorStudentPrivateChatPage> createState() =>
      _CounselorStudentPrivateChatPageState();
}

class _CounselorStudentPrivateChatPageState
    extends State<CounselorStudentPrivateChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late CollectionReference _messagesCollection;
  final ScrollController _scrollController = ScrollController();
  String? _replyingToMessage;
  String? _selectedMessageId;
  String? _replyingToMessageId;

  void _handleReply(String message, String messageId) {
    setState(() {
      _replyingToMessage = message;
      _replyingToMessageId = messageId;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
      _replyingToMessageId = null;
    });
  }

  void scrollToMessage(String messageId, ScrollController scrollController) {
    // This is a basic implementation. You might need to adjust it based on your specific needs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0;
          i < scrollController.position.maxScrollExtent.toInt();
          i++) {
        if (scrollController.position.pixels == i) {
          scrollController.animateTo(
            i.toDouble(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          return;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _messagesCollection = _firestore
        .collection('counselors')
        .doc(currentUser!.uid)
        .collection('chats')
        .doc(widget.studentId)
        .collection('messages');
    markMessagesAsRead(_messagesCollection, widget.studentId);
  }

  // Build AppBar actions for copying or deleting the selected message
  Widget buildAppBarActions(String? selectedMessageId, BuildContext context,
      void Function(VoidCallback fn) setState) {
    if (selectedMessageId == null) {
      return const Text('Chat with Student');
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              // Retrieve the selected message content
              DocumentSnapshot selectedMessageSnapshot =
                  await _messagesCollection.doc(selectedMessageId).get();
              String messageToCopy = selectedMessageSnapshot['content'];

              // Copy the message to the clipboard
              copyMessage(messageToCopy, context);

              // Deselect the message after copying
              setState(() {
                _selectedMessageId = null;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Delete the selected message
              deleteMessage(selectedMessageId, _messagesCollection, () {
                // Callback after deletion
                setState(() {
                  _selectedMessageId = null;
                });
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              // Deselect the message (Cancel action)
              setState(() {
                _selectedMessageId = null;
              });
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: const [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: Scaffold(
        appBar: AppBar(
          title: _selectedMessageId == null
              ? const Text('Chat with Student')
              : buildAppBarActions(_selectedMessageId, context, setState),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/chatbg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _messagesCollection
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<DocumentSnapshot> messages = snapshot.data!.docs;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToBottom(_scrollController);
                      });

                      return ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = messages[index];
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          return MessageBubble(
                            message: data['content'],
                            isMe: data['senderId'] == currentUser!.uid,
                            replyingToMessage: data['replyingTo'],
                            timestamp: data['timestamp'],
                            messageId: document.id,
                            replyingToMessageId: data['replyingToId'],
                            selectedMessageId: _selectedMessageId,
                            onSelectMessage: (id) =>
                                setState(() => _selectedMessageId = id),
                            onReply: _handleReply,
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_replyingToMessage != null)
                  ReplyWidget(
                    replyingToMessage: _replyingToMessage!,
                    onCancelReply: _cancelReply,
                  ),
                MessageInput(
                  controller: _messageController,
                  onSendMessage: (message) {
                    sendMessage(
                      message,
                      _messagesCollection,
                      _messageController,
                      _replyingToMessage,
                      _replyingToMessageId,
                      currentUser!.uid,
                      widget.studentId,
                    );
                    _cancelReply();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
