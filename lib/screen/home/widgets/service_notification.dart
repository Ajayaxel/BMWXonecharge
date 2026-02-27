import 'package:flutter/material.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:onecharge/core/config/app_config.dart';

class ServiceNotificationOverlay extends StatefulWidget {
  final String
  stage; // 'finding', 'assigned', 'reaching', 'solving', 'resolved'
  final double progress;
  final VoidCallback onDismiss;
  final VoidCallback onSolved;
  final VoidCallback? onTap;
  final Ticket? ticket;

  const ServiceNotificationOverlay({
    super.key,
    required this.stage,
    required this.progress,
    required this.onDismiss,
    required this.onSolved,
    this.onTap,
    this.ticket,
  });

  @override
  State<ServiceNotificationOverlay> createState() =>
      _ServiceNotificationOverlayState();
}

class _ServiceNotificationOverlayState extends State<ServiceNotificationOverlay>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.stage == 'none') return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: GestureDetector(
            onTap: widget.onTap,
            child: _buildNotificationContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationContent() {
    switch (widget.stage) {
      case 'finding':
        return _buildFindingAgent();
      case 'assigned':
      case 'reaching':
      case 'solving':
        return _buildAgentAssigned();
      case 'resolved':
        return _buildResolved();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFindingAgent() {
    final issueCategory = widget.ticket?.issueCategory?.name ?? 'Service';
    final ticketId = widget.ticket?.ticketId;

    return Container(
      key: const ValueKey('finding'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Finding agent for $issueCategory",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticketId != null
                      ? "Ticket: #$ticketId\nFinding the best driver for you."
                      : "Please wait, our driver will be\nassigned to you shortly.",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ),
          // Circle loading indicator
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentAssigned() {
    final bool isReaching = widget.stage == 'reaching';
    final bool isSolving = widget.stage == 'solving';
    final String driverName = widget.ticket?.driver?.name ?? 'Agent';
    final String issueName = widget.ticket?.issueCategory?.name ?? 'Service';
    final String ticketId = widget.ticket?.ticketId ?? '';

    return Container(
      key: const ValueKey('assigned'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSolving
                          ? "Solving $issueName Issue"
                          : isReaching
                          ? "$driverName is Coming"
                          : "Agent Assigned",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lufga',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSolving
                          ? "Ticket #$ticketId - In progress"
                          : isReaching
                          ? "Ticket #$ticketId - On the way"
                          : "Ticket #$ticketId - ${widget.ticket?.driver?.name ?? ''} assigned",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Lufga',
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/vehicle/bmwI5.png',
                    height: 50,
                    width: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const SizedBox(width: 100),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                        border: Border.all(color: Colors.black, width: 2),
                        image: widget.ticket?.driver?.image != null
                            ? DecorationImage(
                                image: NetworkImage(
                                  widget.ticket!.driver!.image!.startsWith(
                                        'http',
                                      )
                                      ? widget.ticket!.driver!.image!
                                      : '${AppConfig.storageUrl}${widget.ticket!.driver!.image!}',
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.ticket?.driver?.image == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar with car
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: widget.progress > 0 ? widget.progress : 0.05,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left:
                    (MediaQuery.of(context).size.width - 72) *
                        (widget.progress > 0 ? widget.progress : 0.05) -
                    10,
                top: -8,
                child: Image.asset(
                  'assets/login/carimage.png',
                  height: 20,
                  width: 30,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResolved() {
    return Container(
      key: const ValueKey('resolved'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ticket?.issueCategory != null
                          ? "Your ${widget.ticket!.issueCategory!.name}\nissue has been\nresolved"
                          : "All the issues you\nmentioned have been\nresolved",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lufga',
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/issue/isuuesoluved.png',
                height: 80,
                width: 110,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.task_alt, color: Colors.white, size: 60),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onSolved,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Submit Feedback",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Lufga',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
