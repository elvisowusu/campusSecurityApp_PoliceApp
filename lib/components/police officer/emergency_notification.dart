import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:security_app/components/police%20officer/map_area.dart';
import 'package:security_app/widgets/custom_appbar.dart';
import 'live_location_service.dart';

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
      appBar: const MyAppBar(title: 'Emergency Cases'),
      body: StreamBuilder<List<HelpRequest>>(
        stream: _liveLocationService.getActiveHelpRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'No active emergency requests',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final sortedHelpRequests = snapshot.data!
            ..sort((a, b) => a.isRead.toInt().compareTo(b.isRead.toInt()));

          return ListView.builder(
            itemCount: sortedHelpRequests.length,
            itemBuilder: (context, index) {
              final helpRequest = sortedHelpRequests[index];
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                  child: Slidable(
                    key: ValueKey(helpRequest.trackingId),
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      extentRatio: 0.25,  // Adjusted to give more space for centering
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              _confirmAndDelete(context, helpRequest),
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_forever,
                          borderRadius: BorderRadius.circular(16),// Centered the icon
                        ),
                      ],
                    ),
                    child: HelpRequestItem(
                      helpRequest: helpRequest,
                      onTap: () => _navigateToMapArea(context, helpRequest),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(
      BuildContext context, HelpRequest helpRequest) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this help request?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await _liveLocationService.deleteHelpRequest(helpRequest.trackingId);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting help request: $e')),
        );
      }
    }
  }

  void _navigateToMapArea(BuildContext context, HelpRequest helpRequest) async {
    try {
      await _liveLocationService.updateHelpRequestReadStatus(
          helpRequest.trackingId, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapArea(
            helpRequest: helpRequest,
            policeOfficerId: widget.policeOfficerId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating help request: $e')),
      );
    }
  }
}

class HelpRequestItem extends StatelessWidget {
  final HelpRequest helpRequest;
  final VoidCallback onTap;

  const HelpRequestItem(
      {Key? key, required this.helpRequest, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: helpRequest.isRead ? Colors.white : Colors.red[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ref: ${helpRequest.referenceNumber}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: helpRequest.isRead ? Colors.blue : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      helpRequest.isRead ? 'Viewed' : 'New Alert',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Tap to view',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on bool {
  int toInt() => this ? 1 : 0;
}
