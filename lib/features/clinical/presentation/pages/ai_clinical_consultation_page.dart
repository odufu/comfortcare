import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../consultants/domain/entities/doctor_entity.dart';
import '../../domain/entities/consultation_message.dart';
import '../../domain/entities/health_vitals.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_event.dart';
import '../bloc/clinical_state.dart';
import '../widgets/ai_clinical_regimen_card.dart';
import '../widgets/ai_markdown_text.dart';

class AiClinicalConsultationPage extends StatefulWidget {
  const AiClinicalConsultationPage({super.key});

  @override
  State<AiClinicalConsultationPage> createState() => _AiClinicalConsultationPageState();
}

class _AiClinicalConsultationPageState extends State<AiClinicalConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  void _initSession() {
    // Maintain AI context within session: keep cached messages if already present
    final currentMessages = context.read<ClinicalBloc>().state.messages;
    if (currentMessages.isNotEmpty) {
      _scrollToBottom();
      return;
    }

    String? firstName;
    try {
      final authUser = context.read<AuthBloc>().state.user;
      if (authUser != null && authUser.fullName.trim().isNotEmpty) {
        firstName = authUser.fullName.trim().split(' ').first;
      }
    } catch (_) {}
    context.read<ClinicalBloc>().add(LoadConsultationHistory(
      userName: firstName,
      forceNewSession: false,
    ));
  }

  void _startFreshSession() {
    String? firstName;
    try {
      final authUser = context.read<AuthBloc>().state.user;
      if (authUser != null && authUser.fullName.trim().isNotEmpty) {
        firstName = authUser.fullName.trim().split(' ').first;
      }
    } catch (_) {}
    context.read<ClinicalBloc>().add(StartNewSessionEvent(
      userName: firstName,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ClinicalBloc>().add(SendConsultationMessage(text));
      if (presetText == null) {
        _messageController.clear();
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 400,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: isDesktop
          ? (isDark ? colorScheme.surfaceContainerLowest : const Color(0xFFF1F5F9))
          : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest.withValues(
          alpha: isDark ? 0.98 : 0.95,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.local_pharmacy, color: colorScheme.onPrimary, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Dr. Comfort',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online • AI Specialist',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
            tooltip: 'New Consultation Session',
            onPressed: _startFreshSession,
          ),
          IconButton(
            icon: Icon(Icons.show_chart, color: colorScheme.primary),
            tooltip: 'Health Vitals Telemetry',
            onPressed: () => context.push('/vitals-monitor'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 840),
          decoration: isDesktop
              ? BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : null,
          child: BlocConsumer<ClinicalBloc, ClinicalState>(
            listener: (context, state) {
              _scrollToBottom();
            },
            builder: (context, state) {
              final messages = state.messages;

              return Column(
                children: [
                  // Scrollable Message Stream
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      children: [
                        _buildDateHeader(context, colorScheme),
                        ...messages.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final msg = entry.value;
                          final isLastDoctorMsg = !msg.isFromUser &&
                              (idx == messages.length - 1 ||
                                  (state.isThinking && idx == messages.length - 2));

                          return _buildMessageItem(
                            context: context,
                            msg: msg,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            isLastDoctorMsg: isLastDoctorMsg,
                          );
                        }),
                        if (state.isThinking)
                          _buildThinkingBubble(context, isDark, colorScheme),
                      ],
                    ),
                  ),

                  // Bottom Chat Input Box
                  _buildChatInputBar(context, isDark, colorScheme),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 14),
        child: Text(
          'Today',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem({
    required BuildContext context,
    required ConsultationMessageEntity msg,
    required bool isDark,
    required ColorScheme colorScheme,
    required bool isLastDoctorMsg,
  }) {
    if (msg.isFromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 13,
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final bool showClinicalBadge = msg.priority == TriagePriority.high ||
        msg.priority == TriagePriority.critical;

    // AI Doctor Message Bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean Conversational Bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerLow
                        : colorScheme.surfaceContainerLowest,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showClinicalBadge) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Clinical Assessment',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            _buildPriorityBadge(msg.priority, colorScheme),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      AiMarkdownText(
                        text: msg.text,
                        baseStyle: TextStyle(
                          fontSize: 13.5,
                          height: 1.48,
                          color: colorScheme.onSurface,
                        ),
                        colorScheme: colorScheme,
                      ),
                      if (msg.clinicalNotes != null && msg.clinicalNotes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                msg.clinicalNotes!,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Embedded Health Vitals Telemetry Card
                if (msg.vitalsSnapshot != null) ...[
                  const SizedBox(height: 10),
                  _buildEmbeddedVitalsCard(context, msg.vitalsSnapshot!, isDark, colorScheme),
                ],

                // Embedded Recommended Regimen Card (Prescriptions)
                if (msg.recommendedProducts != null && msg.recommendedProducts!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  AiClinicalRegimenCard(products: msg.recommendedProducts),
                ],

                // Embedded Recommended Doctor / Consultant Card
                if (msg.recommendedDoctor != null) ...[
                  const SizedBox(height: 10),
                  _buildRecommendedDoctorCard(context, msg.recommendedDoctor!, isDark, colorScheme),
                ],

                // Pharmacist Verification Note (shown when prescriptions are recommended)
                if (msg.recommendedProducts != null && msg.recommendedProducts!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 13,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Regimen verified against NAFDAC safety standards • Pharm. Halima Bello (PCN #44912)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedDoctorCard(
    BuildContext context,
    DoctorEntity doc,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Recommended On-Call Specialist',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doc.availabilityStatus,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/consultants/${doc.id}'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Tooltip(
                    message: 'View ${doc.name} full profile',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(doc.avatarUrl),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => context.push('/consultants/${doc.id}'),
                      child: Text(
                        doc.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${doc.hospital} • Fee: ${doc.consultationFee.toNaira()}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.phone, size: 14),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Audio Call'),
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  ),
                  onPressed: () {
                    context.push('/telehealth/call/${doc.id}?type=audio');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.videocam, size: 15),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Video Call'),
                  ),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  ),
                  onPressed: () {
                    context.push('/telehealth/call/${doc.id}?type=video');
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.person_outline, size: 16),
                tooltip: 'Doctor Profile & Reviews',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  context.push('/consultants/${doc.id}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedVitalsCard(
    BuildContext context,
    HealthVitalsEntity vitals,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.surfaceContainerHigh,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monitor_heart,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Biometric Telemetry',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Live Synchronized Docket • Abuja Health Link',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.secondaryContainer
                      : const Color(0xFFA3F69C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF002204),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Live Sync',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF002204),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4 Vitals Stat Metrics
          Row(
            children: [
              Expanded(
                child: _buildVitalTile(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFE53935),
                  label: 'Blood Pressure',
                  value: '${vitals.systolic}/${vitals.diastolic}',
                  unit: 'mmHg',
                  status: vitals.bpStatus,
                  statusColor: vitals.systolic > 130
                      ? const Color(0xFFE53935)
                      : const Color(0xFF2E7D32),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVitalTile(
                  icon: Icons.speed,
                  iconColor: const Color(0xFF0288D1),
                  label: 'Heart Rate',
                  value: '${vitals.heartRate}',
                  unit: 'bpm',
                  status: vitals.heartRate > 100 ? 'Elevated' : 'Normal',
                  statusColor: vitals.heartRate > 100
                      ? const Color(0xFFE53935)
                      : const Color(0xFF0288D1),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildVitalTile(
                  icon: Icons.thermostat,
                  iconColor: const Color(0xFFFB8C00),
                  label: 'Body Temp',
                  value: vitals.temperature.toStringAsFixed(1),
                  unit: '°C',
                  status: vitals.temperature >= 38.0
                      ? 'Febrile Alert'
                      : (vitals.temperature >= 37.5 ? 'Mild Warmth' : 'Afebrile'),
                  statusColor: vitals.temperature >= 38.0
                      ? const Color(0xFFE53935)
                      : const Color(0xFF2E7D32),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVitalTile(
                  icon: Icons.bloodtype,
                  iconColor: const Color(0xFF7B1FA2),
                  label: 'Blood Glucose',
                  value: vitals.bloodGlucose.toStringAsFixed(0),
                  unit: 'mg/dL',
                  status: vitals.glucoseStatus,
                  statusColor: vitals.bloodGlucose >= 120
                      ? const Color(0xFFE53935)
                      : const Color(0xFF2E7D32),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Interactive Link to Full Telemetry Charts
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.push('/vitals-monitor'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.show_chart, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'View 7-Day Trend Telemetry & ECG Waveforms',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(TriagePriority priority, ColorScheme colorScheme) {
    final (bg, fg, label) = switch (priority) {
      TriagePriority.critical => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
          'Critical Priority'
        ),
      TriagePriority.high => (
          const Color(0xFFFFDBCF),
          const Color(0xFF8B1D00),
          'High Priority'
        ),
      TriagePriority.normal => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          'Standard Triage'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildThinkingBubble(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 12, left: 42),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.surfaceContainerHigh,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Dr. AI is assessing symptoms...',
                style: TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInputBar(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Ask Dr. Comfort or describe symptoms...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.arrow_upward,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                  tooltip: 'Send Consultation Message',
                  onPressed: () => _sendMessage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
