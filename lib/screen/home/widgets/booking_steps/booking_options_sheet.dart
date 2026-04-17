import 'package:flutter/material.dart';

class BookingOptionsSheet extends StatefulWidget {
  final VoidCallback onInstantSelected;
  final VoidCallback onScheduledSelected;

  const BookingOptionsSheet({
    super.key,
    required this.onInstantSelected,
    required this.onScheduledSelected,
  });

  @override
  State<BookingOptionsSheet> createState() => _BookingOptionsSheetState();
}

class _BookingOptionsSheetState extends State<BookingOptionsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Handle bar
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const Text(
                        "Booking Options",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lufga',
                          letterSpacing: -0.5,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Select your preferred service speed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[500],
                          fontFamily: 'Lufga',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 36),
                      _buildAnimatedOption(
                        index: 0,
                        title: "Instant Booking",
                        subtitle: "Get service provider immediately",
                        icon: Icons.flash_on_rounded,
                        primaryColor: Colors.black,
                        onTap: widget.onInstantSelected,
                      ),
                      const SizedBox(height: 18),
                      _buildAnimatedOption(
                        index: 1,
                        title: "Schedule Booking",
                        subtitle: "Choose a time that fits your day",
                        icon: Icons.calendar_today_rounded,
                        primaryColor: Colors.black,
                        onTap: widget.onScheduledSelected,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final start = 0.3 + (index * 0.15);
        final end = (start + 0.5).clamp(0.0, 1.0);
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: _ModernOptionCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        primaryColor: primaryColor,
        onTap: onTap,
      ),
    );
  }
}

class _ModernOptionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ModernOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_ModernOptionCard> createState() => _ModernOptionCardState();
}

class _ModernOptionCardState extends State<_ModernOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isPressed ? widget.primaryColor : const Color(0xFFF1F1F1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(widget.icon, color: widget.primaryColor, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Lufga',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lufga',
                        color: Colors.grey[500],
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[300],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
