import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../widgets/signout.dart';
import 'live_location_service.dart';
import 'map_area.dart';

class EmergencyNotifications extends StatefulWidget {
  final String policeOfficerId;

  const EmergencyNotifications({super.key, required this.policeOfficerId});

  @override
  State<EmergencyNotifications> createState() => _EmergencyNotificationsState();
}

class _EmergencyNotificationsState extends State<EmergencyNotifications> {
  final LiveLocationService _liveLocationService = LiveLocationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Cases'),
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
      body: StreamBuilder<List<HelpRequest>>(
        stream: _liveLocationService.getActiveHelpRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active help requests'));
          }

          final sortedHelpRequests = snapshot.data!
            ..sort((a, b) => a.isRead.toInt().compareTo(b.isRead.toInt()));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: sortedHelpRequests.length,
              itemBuilder: (context, index) {
                final helpRequest = sortedHelpRequests[index];

                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          try {
                            await _liveLocationService
                                .deleteHelpRequest(helpRequest.trackingId);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error deleting help request: $e')),
                            );
                          }
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete Request',
                      ),
                    ],
                  ),
                  child: HelpRequestItem(
                    helpRequest: helpRequest,
                    onTap: () async {
                      try {
                        await _liveLocationService.updateHelpRequestReadStatus(
                            helpRequest.trackingId, true);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapArea(
                                helpRequest: helpRequest,
                                policeOfficerId: widget.policeOfficerId),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error updating help request: $e')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class HelpRequestItem extends StatelessWidget {
  final HelpRequest helpRequest;
  final VoidCallback onTap;

  const HelpRequestItem(
      {super.key, required this.helpRequest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: helpRequest.isRead ? Colors.blue : Colors.red,
        child: Text(helpRequest.studentName.isNotEmpty
            ? helpRequest.studentName[0]
            : 'S'),
      ),
      title: Text(
        helpRequest.studentName,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      subtitle: Text('Ref: ${helpRequest.referenceNumber} - Help me!'),
      onTap: onTap,
    );
  }
}

extension on bool {
  int toInt() => this ? 1 : 0;
}
