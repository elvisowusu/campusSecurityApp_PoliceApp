import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? _replyingToMessage;

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
    });

    setState(() {
      _replyingToMessage = null;
    });

    _messageController.clear();
  }

  Widget _buildMessageBubble(
    String message, bool isMe, String? replyingToMessage) {
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd, // Swipe from left to right
      onDismissed: (_) {
        setState(() {
          _replyingToMessage = message;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color.fromARGB(255, 161, 210, 105) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: Radius.circular(isMe ? 20.0 : 0.0),
            bottomRight: Radius.circular(isMe ? 0.0 : 20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyingToMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 5.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Text(
                  replyingToMessage,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Student'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection.orderBy('timestamp').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: messages.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String message = data['content'];
                    String senderId = data['senderId'];
                    String? replyingToMessage = data['replyingTo'];
                    bool isMe = senderId == currentUser!.uid;

                    return _buildMessageBubble(
                      message,
                      isMe,
                      replyingToMessage,
                    );
                  }).toList(),
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
    );
  }
}


