import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/datasources/consultants_remote_datasource.dart';
import '../../domain/entities/consultation_session_entity.dart';
import '../../domain/entities/doctor_entity.dart';

class DoctorConsolePage extends StatefulWidget {
  const DoctorConsolePage({super.key});

  @override
  State<DoctorConsolePage> createState() => _DoctorConsolePageState();
}

class _DoctorConsolePageState extends State<DoctorConsolePage> {
  final ConsultantsRemoteDataSource _dataSource =
      ConsultantsRemoteDataSourceImpl();

  DoctorEntity? _currentDoctor;
  List<ConsultationSessionEntity> _sessions = [];
  bool _isLoading = true;
  bool _isAvailable = true;
  String _status = 'Available Now';

  @override
  void initState() {
    super.initState();
    _loadConsoleData();
  }

  Future<void> _loadConsoleData() async {
    setState(() => _isLoading = true);
    dynamic user;
    try {
      user = context.read<AuthBloc>().state.user;
    } catch (_) {
      user = null;
    }
    DoctorEntity? current;
    if (user != null) {
      current = await _dataSource.getDoctorById(user.id);
    }
    if (current == null) {
      final doctors = await _dataSource.getDoctors();
      current = doctors.firstWhere(
        (d) => d.id == 'doc-chinedu-eze',
        orElse: () => doctors.first,
      );
    }
    final sessions = await _dataSource.getSessionsForDoctor(current.id);

    if (mounted) {
      setState(() {
        _currentDoctor = current;
        _isAvailable = current!.isAvailable;
        _status = current.availabilityStatus;
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    if (_currentDoctor == null) return;
    if (_currentDoctor!.approvalStatus == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot go Online: Your consultant credentials are currently under review by Admin.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }
    final newStatus = value ? 'Available Now' : 'Offline';
    setState(() {
      _isAvailable = value;
      _status = newStatus;
    });
    await _dataSource.updateDoctorAvailability(
      _currentDoctor!.id,
      value,
      newStatus,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
            ? 'You are now Online and accepting telehealth consultations.'
            : 'You are now Offline. Patients will be queued or routed to on-call peers.',
        ),
        backgroundColor: value ? const Color(0xFF10B981) : Colors.grey.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final doc = _currentDoctor!;
    final pendingSessions = _sessions.where((s) => s.status == 'waiting').toList();
    final completedSessions = _sessions.where((s) => s.status == 'completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doctor Clinical Console',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _isAvailable ? const Color(0xFF10B981) : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${doc.name} • $_status',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Queue',
            icon: const Icon(Icons.refresh),
            onPressed: _loadConsoleData,
          ),
          IconButton(
            tooltip: 'View Directory',
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.push('/consultants'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doc.approvalStatus == 'pending') ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pending_actions_outlined,
                            color: Color(0xFFB45309),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Consultant Profile Under Review',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                              Text(
                                'Awaiting ComfortCare Admin & Medical Board Approval',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PENDING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your submitted credentials (${doc.documentationName}) and MDCN license (${doc.licenseNumber}) are queued in the Admin Console. Live patient teleconsultations and routing will activate automatically once approved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown.shade800,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.push('/admin/console'),
                          icon: const Icon(Icons.admin_panel_settings, size: 16),
                          label: const Text('Open Admin Console to Approve'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF007A78),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _loadConsoleData,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('Check Status'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Doctor Profile & Online Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.surfaceContainerHigh,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/consultants/${doc.id}'),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Tooltip(
                            message: 'View ${doc.name} full profile',
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(doc.avatarUrl),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => context.push('/consultants/${doc.id}'),
                              child: Text(
                                doc.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              doc.title,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${doc.licenseNumber} • ${doc.hospital}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Availability Switcher Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isAvailable ? Icons.sensors : Icons.sensors_off,
                            color: _isAvailable ? const Color(0xFF10B981) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isAvailable ? 'Status: Accepting Consultations' : 'Status: Offline',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isAvailable ? const Color(0xFF10B981) : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _isAvailable
                                    ? 'Incoming video & audio calls will ring in your console'
                                    : 'Toggle switch to start taking live patient calls',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAvailable,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: _toggleAvailability,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance Metric Ribbon
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Active Rating',
                    value: '⭐ ${doc.rating}',
                    subtitle: '${doc.reviewCount} Reviews',
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Consultations',
                    value: '${doc.reviewCount + 12}',
                    subtitle: 'Completed',
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Consultation Fee',
                    value: doc.consultationFee.toNaira(),
                    subtitle: 'Per Session',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Patient Consultation Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Live Waiting Queue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: pendingSessions.isNotEmpty
                            ? Colors.red.withValues(alpha: 0.15)
                            : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pendingSessions.length} Waiting',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: pendingSessions.isNotEmpty ? Colors.red : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_isAvailable)
                  Text(
                    'Go Online to take calls',
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (pendingSessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 36, color: colorScheme.primary),
                    const SizedBox(height: 8),
                    const Text(
                      'Queue is clear! No patients currently waiting.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'When Dr. Comfort AI or users book consultations, they will appear here instantly.',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingSessions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final sess = pendingSessions[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    color: colorScheme.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: colorScheme.primaryContainer,
                                      child: const Icon(Icons.person, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sess.patientName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Waiting 3m • Fee: ${sess.fee.toNaira()}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sess.callType == 'video' ? '📹 Video' : '📞 Audio',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.notes, size: 16, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Chief Complaint: ${sess.chiefComplaint}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.phone, size: 14),
                                label: const Text('Audio Call'),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                onPressed: () {
                                  context.push('/telehealth/call/${doc.id}?type=audio');
                                },
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                icon: const Icon(Icons.videocam, size: 15),
                                label: const Text('Video Call'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                ),
                                onPressed: () {
                                  context.push('/telehealth/call/${doc.id}?type=video');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Recent Consultations
            const Text(
              'Recent Completed Consultations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (completedSessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No past consultations logged yet today.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedSessions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final sess = completedSessions[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.surfaceContainerHigh),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.done, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sess.patientName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                sess.chiefComplaint,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          sess.fee.toNaira(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
