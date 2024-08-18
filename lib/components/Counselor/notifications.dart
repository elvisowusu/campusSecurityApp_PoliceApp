import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../../widgets/signout.dart';
import 'chatpage.dart';

class CounselorNotificationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  CounselorNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User not authenticated')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Chats'),
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
        ),
        actions: const [SignOutButton()],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('counselors')
            .doc(currentUser!.uid)
            .collection('chats')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats available'));
          }

          var chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              var studentId = chat.id;

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('counselors')
                    .doc(currentUser!.uid)
                    .collection('chats')
                    .doc(studentId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  if (!messageSnapshot.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  var latestMessage = messageSnapshot.data!.docs.isNotEmpty
                      ? messageSnapshot.data!.docs.first.data() as Map<String, dynamic>
                      : {'content': 'No messages yet', 'timestamp': Timestamp.now(), 'senderId': null};

                  var sender = latestMessage['senderId'] == currentUser!.uid ? 'You: ' : 'Stu: ';
                  var messageContent = '$sender${latestMessage['content']}';

                  var timestamp = latestMessage['timestamp'] as Timestamp;
                  var time = DateFormat('h:mm a').format(timestamp.toDate()); // Format the time

                  var unreadCount = messageSnapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return data['read'] == false && data['senderId'] != currentUser!.uid;
                  }).length;

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('students').doc(studentId).get(),
                    builder: (context, studentSnapshot) {
                      if (!studentSnapshot.hasData) {
                        return const ListTile(title: Text('Loading student data...'));
                      }

                      var studentData = studentSnapshot.data!.data() as Map<String, dynamic>;
                      var studentName = studentData['fullName'] ?? 'Unknown';
                      var referenceNumber = studentData['Reference number'] ?? '';

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              // Add a placeholder image or profile picture here
                              backgroundColor: Colors.grey,
                              child: Text(studentName[0]), // Example: First letter of the student's name
                            ),
                            title: Text('$studentName - $referenceNumber'),
                            subtitle: Text(
                              messageContent,
                              style: messageContent.startsWith('Stu: ')
                              ?const TextStyle(
                                color: Colors.black54,
                                fontWeight:FontWeight.bold
                              )
                              :const TextStyle(
                                color: Colors.black45,
                                fontWeight:FontWeight.normal
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(time, style: const TextStyle(color: Colors.green)),
                                if (unreadCount > 0)
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 12,
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Mark all messages as read when opening the chat
                              _firestore
                                  .collection('counselors')
                                  .doc(currentUser!.uid)
                                  .collection('chats')
                                  .doc(studentId)
                                  .collection('messages')
                                  .where('senderId', isNotEqualTo: currentUser!.uid)
                                  .get()
                                  .then((querySnapshot) {
                                for (var doc in querySnapshot.docs) {
                                  doc.reference.update({'read': true});
                                }
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CounselorStudentPrivateChatPage(
                                    studentId: studentId,
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
                },
              );
            },
          );
        },
      ),
    );
  }
}
