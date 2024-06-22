// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cs_location_tracker_app/common/enum/message_type.dart';
// import 'package:cs_location_tracker_app/common/models/last_message_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';

// final chatRepositoryProvider = Provider((ref) {
//   return ChatRepository(
//     firestore:FirebaseFirestore.instance,
//     auth: FirebaseAuth.instance,
//   );
// });

// class ChatRepository {
//   final FirebaseFirestore firestore;
//   final FirebaseAuth auth;

//   ChatRepository({required this.firestore, required this.auth});
//   void sendTestMessage({
//     required BuildContext context,
//     required String receiverId,
//     required String testMessage,
//     required UserModel senderData,
//   }) async {
//     try {
//       final timeSent = DateTime.now();
//       final receiverDataMap =
//           await firestore.collection('users').doc(receiverId).get();
//       final receiverData = UserModel.fromMap(receiverDataMap.data()!);
//       final textMessageId = const Uuid().v4();

//       saveToMessageCollection(
//         receiverId: receiverId,
//         testMessage: testMessage,
//         timeSent: timeSent,
//         receiverUsername: receiverData.username,
//         senderUsername: senderData.username,
//         messageType: MessageType.text,
//       );

//       saveAsLastMessage(
//           senderUserData: senderData,
//           receiverUserData: receiverData,
//           lastMessage: testMessage,
//           timeSent: timeSent,
//           receiverId: receiverId);
//     } catch (e) {
//       AlertDialog(
//         title: const Text('Error'),
//         content: const Text('An error occurred while sending message'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       );
//     }
//   }

//   void saveToMessageCollection({
//     required String receiverId,
//     required String testMessage,
//     required DateTime timeSent,
//     required String receiverUsername,
//     required String senderUsername,
//     required MessageType messageType,
//   }) async {
//     final message = MessageModel(
//       senderId: auth.currentUser!.uid,
//       receiverId: receiverId,
//       message: testMessage,
//       type: MessageType.text,
//       timeSent: timeSent,
//       messageId: textMessageId,
//       isSeen: false,
//     );

//     await firestore
//         .collection('users')
//         .doc(auth.currentUser!.uid)
//         .collection('chats')
//         .doc(receiverId)
//         .collection('messages')
//         .doc(textMessageId)
//         .set(message.toMap());
//   }

//   void saveAsLastMessage({
//     required UserModel senderUserData,
//     required UserModel receiverUserData,
//     required String lastMessage,
//     required DateTime timeSent,
//     required String receiverId,
//   }) async {
//     final receiverLastMessage = LastMessageMode(
//       username: senderUserData.username,
//       profileImageUrl: senderUserData.profileImageUrl,
//       contactId: senderUserData.uid,
//       timeSent: timeSent,
//       lastMessage: lastMessage,
//     );

//     await firestore
//         .collection('users')
//         .doc(receiverId)
//         .collection('chats')
//         .doc(auth.currentUser!.uid)
//         .set(receiverLastMessage.toMap());

//     final senderLastMessage = LastMessageMode(
//       username: receiverUserData.username,
//       profileImageUrl: receiverUserData.profileImageUrl,
//       contactId: receiverUserData.uid,
//       timeSent: timeSent,
//       lastMessage: lastMessage,
//     );

//     await firestore
//         .collection('users')
//         .doc(auth.currentUser!.uid)
//         .collection('chats')
//         .doc(receiverId)
//         .set(senderLastMessage.toMap());
//   }
// }

// class UserModel {
//   final String uid;
//   final String username;
//   final String profileImageUrl;

//   UserModel({
//     required this.uid,
//     required this.username,
//     required this.profileImageUrl,
//   });
// }
