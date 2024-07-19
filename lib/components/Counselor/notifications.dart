import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatpage.dart';

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
            .collectionGroup('messages')
            .where('participants', arrayContains: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var messages = snapshot.data!.docs;

          Map<String, Map<String, dynamic>> latestMessages = {};

          for (var message in messages) {
            var data = message.data() as Map<String, dynamic>;
            var participants = List<String>.from(data['participants']);
            var otherParticipant =
                participants.firstWhere((id) => id != currentUser!.uid);

            final user =
                _firestore.collection('users').doc(otherParticipant).get();

            if (!latestMessages.containsKey(otherParticipant) ||
                (latestMessages[otherParticipant]!['timestamp'] as Timestamp)
                        .compareTo(data['timestamp'] as Timestamp) <
                    0) {
              latestMessages[otherParticipant] = data;
            }
          }

          var sortedMessages = latestMessages.values.toList()
            ..sort((a, b) => (b['timestamp'] as Timestamp)
                .compareTo(a['timestamp'] as Timestamp));

          return ListView(
            children: sortedMessages.map((data) {
              var otherParticipant = List<String>.from(data['participants'])
                  .firstWhere((id) => id != currentUser!.uid);
              return Column(
                children: [
                  ListTile(
                    title: Text(otherParticipant),
                    subtitle: Text(data['content'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CounselorStudentPrivateChatPage(
                            studentId: otherParticipant,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
