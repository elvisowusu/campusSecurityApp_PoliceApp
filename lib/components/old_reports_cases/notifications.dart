import 'package:cs_location_tracker_app/components/old_reports_cases/individual_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainChatPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  MainChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(currentUser!.uid).collection('students').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String studentId = data['studentId'];

              return ListTile(
                title: Text(studentId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndividualChatPage(contactId: studentId),
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
