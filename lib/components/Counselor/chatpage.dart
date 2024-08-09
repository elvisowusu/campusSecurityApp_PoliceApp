import 'package:cs_location_tracker_app/components/counselor/message_enum.dart';
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
  late User? _currentUser;
  late CollectionReference _messagesCollection;
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _messagesCollection = _firestore
        .collection('counselors')
        .doc(_currentUser!.uid)
        .collection('chats')
        .doc(widget.studentId)
        .collection('messages');
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userChatsCollection = _firestore
        .collection('counselors')
        .doc(_currentUser!.uid)
        .collection('chats');

    await _messagesCollection.add({
      'senderId': currentUser!.uid,
      'content': content,
      'timestamp': Timestamp.now(),
      'type': 'text',
      'participants': [currentUser!.uid, widget.studentId],
    });

    _messageController.clear();
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
                    MessageType messageType = (data['type'] as String).toEnum();
                    bool isMe = senderId == _currentUser!.uid;

                    Widget messageWidget;
                    switch (messageType) {
                      case MessageType.text:
                        messageWidget = Text(message);
                        break;
                      case MessageType.image:
                        messageWidget = Text('Image: $message');
                        break;
                      case MessageType.audio:
                        messageWidget = Text('Audio: $message');
                        break;
                      case MessageType.video:
                        messageWidget = Text('Video: $message');
                        break;
                      case MessageType.gif:
                        messageWidget = Text('GIF: $message');
                        break;
                      default:
                        messageWidget = Text(message);
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Colors.blueAccent : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: messageWidget,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(_messageController.text);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
