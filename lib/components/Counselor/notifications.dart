import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/signout.dart';
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
        backgroundColor: Colors.black.withOpacity(0.2), // Semi-transparent background color
        elevation: 0, // Remove shadow to enhance the glass effect
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Background color with transparency
              ),
            ),
          ),
        ),
        actions: const [
          SignOutButton()
          ],
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

              return FutureBuilder<DocumentSnapshot>(
                future:
                    _firestore.collection('counselors').doc(otherParticipant).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                      subtitle: Text('Please wait'),
                      tileColor: Colors.black45,
                    );
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  print(userData['Reference number']);
                  var userName = userData['fullName'] +
                          "_" +
                          userData['Reference number'] ??
                      'Unknown';
                  var lastMessage = data['content'] ?? 'N/A';

                  return Column(
                    children: [
                      ListTile(
                        title: Text(userName),
                        subtitle: Text(
                          lastMessage,
                          style: const TextStyle(color: Colors.black45),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CounselorStudentPrivateChatPage(
                                studentId: otherParticipant,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                    ],
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
