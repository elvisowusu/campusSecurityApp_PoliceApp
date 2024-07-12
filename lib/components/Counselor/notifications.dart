import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CounselorNotificationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  CounselorNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var messages = snapshot.data!.docs;

          Map<String, dynamic> latestMessages = {};

          for (var message in messages) {
            var data = message.data() as Map<String, dynamic>;
            var senderId = data['senderId'];
            if (senderId != currentUser!.uid) {
              if (!latestMessages.containsKey(senderId) ||
                  (latestMessages[senderId]['timestamp'] as Timestamp)
                          .compareTo(data['timestamp'] as Timestamp) <
                      0) {
                latestMessages[senderId] = data;
              }
            }
          }

          return ListView(
            children: latestMessages.values.map((message) {
              return ListTile(
                title: Text(message['text']),
                subtitle: Text('From: ${message['senderId']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CounselorStudentPrivateChatPage(
                        studentId: message['senderId'],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
