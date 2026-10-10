import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/consultants_remote_datasource.dart';
import '../../domain/entities/doctor_entity.dart';

class TelehealthCallPage extends StatefulWidget {
  final String doctorId;
  final String initialCallType; // 'video' or 'audio'

  const TelehealthCallPage({
    super.key,
    required this.doctorId,
    this.initialCallType = 'video',
  });

  @override
  State<TelehealthCallPage> createState() => _TelehealthCallPageState();
}

class _TelehealthCallPageState extends State<TelehealthCallPage> {
  final ConsultantsRemoteDataSource _dataSource =
      ConsultantsRemoteDataSourceImpl();

  DoctorEntity? _doctor;
  late bool _isVideo;
  bool _isMuted = false;
  bool _isFrontCamera = true;
  bool _isConnecting = true;
  int _secondsElapsed = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.initialCallType.toLowerCase() != 'audio';
    _initCall();
  }

  Future<void> _initCall() async {
    final doc = await _dataSource.getDoctorById(widget.doctorId);
    if (mounted) {
      setState(() {
        _doctor = doc;
      });
    }

    // Simulate clinical connection setup
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() {
        _isConnecting = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _endCall() {
    _callTimer?.cancel();
    _showRatingModal();
  }

  void _showRatingModal() {
    double rating = 5.0;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final colorScheme = Theme.of(ctx).colorScheme;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Consultation Ended',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Session duration: ${_formatTimer(_secondsElapsed)} with ${_doctor?.name ?? "Consultant"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How was your clinical experience?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                // Star rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starVal = index + 1.0;
                    return IconButton(
                      icon: Icon(
                        starVal <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setModalState(() => rating = starVal);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Share your feedback (optional)',
                    hintText: 'Was the prescription explanation and bedside manner helpful?',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: () async {
                      if (_doctor != null) {
                        await _dataSource.rateDoctor(
                          doctorId: _doctor!.id,
                          rating: rating,
                          comment: commentCtrl.text.trim().isNotEmpty
                              ? commentCtrl.text.trim()
                              : 'Excellent clinical consultation.',
                          patientName: 'Amina Bello',
                          consultationType: _isVideo ? 'Video Call' : 'Audio Call',
                        );
                      }
                      if (ctx.mounted) {
                        Navigator.pop(ctx); // Close modal
                      }
                      if (mounted) {
                        context.pop(); // Close call page
                      }
                    },
                    child: const Text('Submit Rating & Return'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (mounted) {
                      context.pop();
                    }
                  },
                  child: const Text('Skip Rating'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showClinicalNotesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: Theme.of(ctx).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Telehealth Clinical Notes & Vitals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 6),
            const Text(
              'Patient Telemetry Snapshot (Abuja):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text('• Blood Pressure: 124/82 mmHg (Stable)\n• Temperature: 38.6°C (Acute febrile chills)\n• Heart Rate: 84 bpm\n• Blood Glucose: 96.0 mg/dL'),
            const SizedBox(height: 12),
            const Text(
              'Prescribed Medication Candidates:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text('• Coartem 80/480mg (Artemether/Lumefantrine)\n• Emzor Paracetamol 500mg\n• CareStart Malaria RDT'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Return to Consultation Call'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doctor;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Call Viewport (Video or Audio Equalizer)
            Positioned.fill(
              child: _isVideo ? _buildVideoViewport(doc) : _buildAudioViewport(doc),
            ),

            // Top Status Bar (Doctor Name, Encrypted Badge, Call Timer)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Doctor Info Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: doc != null ? NetworkImage(doc.avatarUrl) : null,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              doc?.name ?? 'Connecting...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              doc?.specialty ?? 'Telehealth Specialist',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Timer & Encryption Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isConnecting ? Colors.amber : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isConnecting ? 'Connecting...' : _formatTimer(_secondsElapsed),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.lock, size: 12, color: Colors.white70),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Picture-in-Picture Local Self Preview (Only in Video Mode)
            if (_isVideo)
              Positioned(
                top: 72,
                right: 16,
                child: Container(
                  width: 90,
                  height: 125,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: Text(
                          'You (Abuja)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Call Action Controls Bar
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Audio
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      isActive: _isMuted,
                      tooltip: _isMuted ? 'Unmute' : 'Mute Mic',
                      onPressed: () {
                        setState(() => _isMuted = !_isMuted);
                      },
                    ),

                    // Video Toggle
                    _buildControlButton(
                      icon: _isVideo ? Icons.videocam : Icons.videocam_off,
                      isActive: !_isVideo,
                      tooltip: _isVideo ? 'Turn Off Video' : 'Turn On Video',
                      onPressed: () {
                        setState(() => _isVideo = !_isVideo);
                      },
                    ),

                    // Flip Camera
                    _buildControlButton(
                      icon: Icons.flip_camera_ios,
                      isActive: false,
                      tooltip: 'Flip Camera',
                      onPressed: () {
                        setState(() => _isFrontCamera = !_isFrontCamera);
                      },
                    ),

                    // Clinical Notes / Vitals
                    _buildControlButton(
                      icon: Icons.assignment_outlined,
                      isActive: false,
                      tooltip: 'Clinical Notes',
                      onPressed: _showClinicalNotesSheet,
                    ),

                    // End Call (Red Button)
                    InkWell(
                      onTap: _endCall,
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x66EF4444),
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViewport(DoctorEntity? doc) {
    if (doc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Simulated Doctor Video Feed
        Positioned.fill(
          child: Image.network(
            doc.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: Colors.black87),
          ),
        ),

        // Dark gradient overlay for readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),

        // HD Quality & Telehealth Network Watermark
        Positioned(
          top: 72,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.hd, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text(
                  '1080p Telehealth Feed • Abuja Server',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioViewport(DoctorEntity? doc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF007A78).withValues(alpha: 0.15),
                ),
              ),
              // Inner pulse ring
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF007A78).withValues(alpha: 0.3),
                ),
              ),
              CircleAvatar(
                radius: 54,
                backgroundImage: doc != null ? NetworkImage(doc.avatarUrl) : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            doc?.name ?? 'Dr. Specialist',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            doc?.title ?? 'Medical Consultant',
            style: const TextStyle(fontSize: 13, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 18),

          // Audio Equalizer Visualizer simulation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              final heights = [16.0, 28.0, 42.0, 24.0, 36.0, 20.0, 30.0];
              return Container(
                width: 4,
                height: heights[index],
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            _isConnecting ? 'Establishing secure voice channel...' : 'HD Audio Call Active • Noise Canceling Enabled',
            style: const TextStyle(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? Colors.red.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFFEF4444) : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
