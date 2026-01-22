import 'package:flutter/material.dart';

class ServiceNotificationOverlay extends StatefulWidget {
  final String
  stage; // 'finding', 'assigned', 'reaching', 'solving', 'resolved'
  final double progress;
  final VoidCallback onDismiss;
  final VoidCallback onSolved;
  final VoidCallback? onTap;

  const ServiceNotificationOverlay({
    super.key,
    required this.stage,
    required this.progress,
    required this.onDismiss,
    required this.onSolved,
    this.onTap,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Finding your agent",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lufga',
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Your request has been received. An\nagent will be assigned shortly.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontFamily: 'Lufga',
                ),
              ),
            ],
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
                          ? "Your Agent solving the issue"
                          : isReaching
                          ? "Reach In 5min"
                          : "Agent Assigned",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lufga',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSolving
                          ? "Please wait a moment"
                          : isReaching
                          ? "meet at location"
                          : "Sayed will reach you shortly",
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
                    'assets/vehicle/bmwI5.png', // Placeholder for white car image in toast
                    height: 50,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://i.pravatar.cc/150?u=sayed',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                widthFactor: widget.progress,
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
                    (MediaQuery.of(context).size.width - 72) * widget.progress -
                    10,
                top: -8,
                child: Image.asset(
                  'assets/login/carimage.png', // Small car icon for the bar
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
              const Expanded(
                child: Text(
                  "All the issues you\nmentioned have been\nresolved",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lufga',
                    height: 1.3,
                  ),
                ),
              ),
              Image.asset(
                'assets/issue/isuuesoluved.png',
                height: 60,
                width: 60,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.task_alt, color: Colors.white, size: 60),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onDismiss,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Not Solved",
                    style: TextStyle(color: Colors.white, fontFamily: 'Lufga'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onSolved,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Solved",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lufga',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
