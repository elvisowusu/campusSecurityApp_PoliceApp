import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_appbar.dart';
import 'chatpage.dart';

class CounselorNotificationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  CounselorNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: const MyAppBar(title: 'Campus Safety'),
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
                  var time = DateFormat('h:mm a').format(timestamp.toDate());

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

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: InkWell(
                          onTap: () {
                            _markMessagesAsRead(studentId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CounselorStudentPrivateChatPage(
                                  studentId: studentId,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    studentName[0].toUpperCase(),
                                    style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$studentName - $referenceNumber',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            time,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        messageContent,
                                        style: TextStyle(
                                          color: messageContent.startsWith('Stu: ')
                                              ? Colors.black87
                                              : Colors.black54,
                                          fontWeight: messageContent.startsWith('Stu: ')
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 12,
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
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

  void _markMessagesAsRead(String studentId) {
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
  }
}