// import 'package:cs_location_tracker_app/components/old_reports_cases/repository/chat_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final chatControllerProvider = Provider((ref) {
//   final chatRepository = ref.watch(chatRepositoryProvider);
//   return ChatController(
//     chatRepository: chatRepository,
//     ref: ref,
//   );
// });


// class ChatController {
//   final ChatRepository chatRepository;
//   final ProviderRef ref;

//   ChatController({required this.chatRepository, required this.ref});

//   void sendTextMessage({
//     required BuildContext context,
//     required String textMessage,
//     required String receiverId,
//   }) {
//     ref.read(userInfoAuthProvider).whenData((value) {
//       chatRepository.sendTextMessage(
//         context: context,
//         textMessage: textMessage,
//         receiverId: receiverId,
//         senderData: value,
//       );
//     });
//   }
// }
