import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class CounselorStudentPrivateChatPage extends StatefulWidget {
  const CounselorStudentPrivateChatPage({super.key, required this.studentId});

  final String studentId;

  @override
  State<CounselorStudentPrivateChatPage> createState() =>
      _CounselorStudentPrivateChatPageState();
}

class _CounselorStudentPrivateChatPageState
    extends State<CounselorStudentPrivateChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late CollectionReference _messagesCollection;
  String? _replyingToMessage;
  final ScrollController _scrollController = ScrollController();
  final Map<String, AnimationController> _animationControllers = {};
  String? _replyingToMessageId;
  
  @override
  void initState() {
    super.initState();
    _messagesCollection = _firestore
        .collection('counselors')
        .doc(currentUser!.uid)
        .collection('chats')
        .doc(widget.studentId)
        .collection('messages');
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _markMessagesAsRead() async {
    QuerySnapshot unreadMessages = await _messagesCollection
        .where('senderId', isEqualTo: widget.studentId)
        .where('read', isEqualTo: false)
        .get();

    WriteBatch batch = _firestore.batch();
    for (QueryDocumentSnapshot doc in unreadMessages.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    await _messagesCollection.add({
      'senderId': currentUser!.uid,
      'content': content,
      'timestamp': Timestamp.now(),
      'type': 'text',
      'participants': [currentUser!.uid, widget.studentId],
      'read': false,
      'replyingTo': _replyingToMessage,
      'replyingToId': _replyingToMessageId, 
    });

    setState(() {
      _replyingToMessage = null;
       _replyingToMessageId = null; 
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  void _scrollToMessage(String messageId) {
  for (int i = 0; i < _scrollController.position.maxScrollExtent.toInt(); i++) {
    if (_animationControllers.containsKey(messageId)) {
      _scrollController.animateTo(
        i.toDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
  }
}

  String _formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  int hour = dateTime.hour;
  String period = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  hour = hour == 0 ? 12 : hour; // convert hour '0' to '12' for 12 AM/PM
  return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
}


  Widget _buildMessageBubble(
      String message, bool isMe, String? replyingToMessage, Timestamp timestamp, String messageId, String? replyingToMessageId) {
    if (!_animationControllers.containsKey(messageId)) {
      _animationControllers[messageId] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    }
    final animationController = _animationControllers[messageId]!;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          animationController.value += details.primaryDelta! / 100 * (isMe ? -1 : 1);
        },
         onHorizontalDragEnd: (details) {
          if (animationController.value.abs() > 0.5) {
            setState(() {
              _replyingToMessage = message;
            });
          }
          animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(50 * animationController.value * (isMe ? -1 : 1), 0),
              child: Stack(
                children: [
                  child!,
                  Positioned(
                    left: isMe ? null : 10 * animationController.value,
                    right: isMe ? 10 * animationController.value : null,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.reply,
                        color: Colors.grey[600],
                        size: 20 * animationController.value.abs(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
                bottomLeft: Radius.circular(isMe ? 16.0 : 0.0),
                bottomRight: Radius.circular(isMe ? 0.0 : 16.0),
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
                if (replyingToMessage != null)
                GestureDetector(
                  onTap: () {
                    if (replyingToMessageId != null) {
                      _scrollToMessage(replyingToMessageId);
                    }
                  },
                  child:Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    padding: const EdgeInsets.all(5.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      replyingToMessage,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12.0,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          title: const Text('Chat with Student'),
        ),
        body:  Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/chatbg.png'),
        fit: BoxFit.cover,
      ),
    ),
        child:SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messagesCollection.orderBy('timestamp', descending: true).snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    List<DocumentSnapshot> messages = snapshot.data!.docs;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = messages[index];
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String message = data['content'];
                        String senderId = data['senderId'];
                        String? replyingToMessage = data['replyingTo'];
                        Timestamp timestamp = data['timestamp'];
                        bool isMe = senderId == currentUser!.uid;
                        String? replyingToMessageId = data['replyingToId'];

                        return _buildMessageBubble(
                          message,
                          isMe,
                          replyingToMessage,
                          timestamp,
                          document.id,
                          replyingToMessageId,
                        );
                      },
                    );
                  },
                ),
              ),
              if (_replyingToMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Replying to: $_replyingToMessage',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _replyingToMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: () {
                        _sendMessage(_messageController.text);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }
}