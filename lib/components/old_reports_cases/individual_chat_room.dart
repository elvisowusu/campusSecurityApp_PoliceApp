import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs_location_tracker_app/common/enum/message_type.dart';

class IndividualChatPage extends StatefulWidget {
  final String contactId;

  const IndividualChatPage({super.key, required this.contactId});

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  late User? _currentUser;
  late CollectionReference _messagesCollection;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _messagesCollection = _firestore
        .collection('chats')
        .doc(widget.contactId)
        .collection('messages');
  }

  void _sendMessage(MessageType messageType, String content) async {
    if (content.trim().isEmpty) return;

    await _messagesCollection.add({
      'senderId': _currentUser!.uid,
      'content': content,
      'timestamp': Timestamp.now(),
      'type': messageType.type,
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactId),
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
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () =>
                      _sendMessage(MessageType.text, _controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
