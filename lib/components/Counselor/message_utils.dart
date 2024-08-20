import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

void sendMessage(
  String content,
  CollectionReference messagesCollection,
  TextEditingController messageController,
  String? replyingToMessage,
  String? replyingToMessageId,
  String senderId,
  String studentId,
) async {
  if (content.trim().isEmpty) return;

  await messagesCollection.add({
    'senderId': senderId,
    'content': content,
    'timestamp': Timestamp.now(),
    'type': 'text',
    'participants': [senderId, studentId],
    'read': false,
    'replyingTo': replyingToMessage,
    'replyingToId': replyingToMessageId,
  });

  messageController.clear();
}

void scrollToBottom(ScrollController scrollController) {
  if (scrollController.hasClients) {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

void scrollToMessage(String messageId) {
  // Logic to scroll to the message with the given ID
}

void markMessagesAsRead(CollectionReference messagesCollection, String studentId) async {
  QuerySnapshot unreadMessages = await messagesCollection
      .where('senderId', isEqualTo: studentId)
      .where('read', isEqualTo: false)
      .get();

  WriteBatch batch = FirebaseFirestore.instance.batch();
  for (QueryDocumentSnapshot doc in unreadMessages.docs) {
    batch.update(doc.reference, {'read': true});
  }
  await batch.commit();
}

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  int hour = dateTime.hour;
  String period = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  hour = hour == 0 ? 12 : hour;
  return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
}

void copyMessage(String message, BuildContext context) {
  Clipboard.setData(ClipboardData(text: message));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Message copied to clipboard')),
  );
}

void deleteMessage(String messageId, CollectionReference messagesCollection, Function() callback) async {
  await messagesCollection.doc(messageId).delete();
  callback();
}

