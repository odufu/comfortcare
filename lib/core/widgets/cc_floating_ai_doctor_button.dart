import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CCFloatingAiDoctorButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const CCFloatingAiDoctorButton({
    super.key,
    this.onPressed,
  });

  @override
  State<CCFloatingAiDoctorButton> createState() => _CCFloatingAiDoctorButtonState();
}

class _CCFloatingAiDoctorButtonState extends State<CCFloatingAiDoctorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF006194), Color(0xFF007BB9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006194).withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: Tooltip(
          message: 'Dr. Comfort AI Medical Chat',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onPressed ?? () => context.push('/ai-consult'),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        Positioned(
                          top: 5,
                          child: Icon(
                            Icons.add,
                            color: Color(0xFF006194),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA0F399),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF006194),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA0F399).withValues(alpha: 0.8),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
