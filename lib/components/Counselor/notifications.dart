import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CounselorNotificationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('receiverId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var messages = snapshot.data!.docs;
          Map<String, String> notifications = {};

          for (var message in messages) {
            var senderId = message['senderId'];
            var text = message['text'];
            if (!notifications.containsKey(senderId)) {
              notifications[senderId] = text;
            }
          }

          return ListView.builder(
            itemCount: notifications.keys.length,
            itemBuilder: (context, index) {
              var studentId = notifications.keys.elementAt(index);
              var lastMessage = notifications[studentId];

              return ListTile(
                title: Text(studentId),
                subtitle: Text(lastMessage!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CounselorStudentPrivateChatPage(studentId: studentId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
