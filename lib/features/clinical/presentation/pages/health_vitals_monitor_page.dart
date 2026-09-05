import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../domain/entities/health_vitals.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_event.dart';
import '../bloc/clinical_state.dart';

class HealthVitalsMonitorPage extends StatefulWidget {
  const HealthVitalsMonitorPage({super.key});

  @override
  State<HealthVitalsMonitorPage> createState() => _HealthVitalsMonitorPageState();
}

class _HealthVitalsMonitorPageState extends State<HealthVitalsMonitorPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClinicalBloc>().add(LoadHealthVitals());
  }

  void _showLogVitalsDialog(BuildContext context) {
    final sysController = TextEditingController(text: '120');
    final diaController = TextEditingController(text: '80');
    final hrController = TextEditingController(text: '72');
    final gluController = TextEditingController(text: '95');
    final tempController = TextEditingController(text: '36.7');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Clinical Health Reading',
                style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Systolic (mmHg)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: diaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Diastolic (mmHg)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hrController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: gluController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Glucose (mg/dL)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tempController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Body Temperature (°C)'),
              ),
              const SizedBox(height: 20),
              CCButton(
                label: 'Save Vitals Reading',
                onPressed: () {
                  final vitals = HealthVitalsEntity(
                    systolic: int.tryParse(sysController.text) ?? 120,
                    diastolic: int.tryParse(diaController.text) ?? 80,
                    heartRate: int.tryParse(hrController.text) ?? 72,
                    bloodGlucose: double.tryParse(gluController.text) ?? 95.0,
                    temperature: double.tryParse(tempController.text) ?? 36.7,
                    loggedAt: DateTime.now(),
                  );
                  context.read<ClinicalBloc>().add(LogHealthVitalsEvent(vitals));
                  Navigator.pop(ctx);
                  context.showSnackBar('Health reading recorded successfully.', isSuccess: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Health Vitals Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: () => _showLogVitalsDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ClinicalBloc, ClinicalState>(
        builder: (context, state) {
          final vitals = state.vitals ??
              HealthVitalsEntity(
                systolic: 124,
                diastolic: 82,
                heartRate: 72,
                bloodGlucose: 96.0,
                temperature: 36.8,
                loggedAt: DateTime.now(),
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Status Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.surfaceContainerHigh),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite, color: colorScheme.secondary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vitals Synchronized',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Last reading: Today • Abuja Clinic Telemetry Stream',
                              style: textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      CCChip(
                        label: 'Optimal',
                        variant: CCChipVariant.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Vitals Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _buildVitalCard(
                      context,
                      title: 'BLOOD PRESSURE',
                      value: '${vitals.systolic}/${vitals.diastolic}',
                      unit: 'mmHg',
                      status: vitals.bpStatus,
                      icon: Icons.monitor_heart,
                      color: colorScheme.primary,
                    ),
                    _buildVitalCard(
                      context,
                      title: 'FASTING GLUCOSE',
                      value: vitals.bloodGlucose.toStringAsFixed(1),
                      unit: 'mg/dL',
                      status: vitals.glucoseStatus,
                      icon: Icons.water_drop,
                      color: colorScheme.secondary,
                    ),
                    _buildVitalCard(
                      context,
                      title: 'HEART RATE',
                      value: '${vitals.heartRate}',
                      unit: 'bpm',
                      status: 'Resting Normal',
                      icon: Icons.speed,
                      color: colorScheme.tertiary,
                    ),
                    _buildVitalCard(
                      context,
                      title: 'BODY TEMP',
                      value: '${vitals.temperature}°',
                      unit: 'Celsius',
                      status: 'Afebrile',
                      icon: Icons.thermostat,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Medication Reminders
                Text(
                  'Medication Adherence Reminders',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildReminderCard(
                  context,
                  drug: 'Coartem 80/480mg',
                  dosage: '1 Tab with meal (Malaria ACT Day 2)',
                  time: '08:00 AM & 08:00 PM',
                  isTaken: true,
                ),
                const SizedBox(height: 10),
                _buildReminderCard(
                  context,
                  drug: 'Panadol Extra Tablets',
                  dosage: '1 Tab as needed for headache',
                  time: '02:00 PM (Midday)',
                  isTaken: false,
                ),
                const SizedBox(height: 24),

                // Record Button
                CCButton(
                  label: '+ Log New Vitals Reading',
                  onPressed: () => _showLogVitalsDialog(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVitalCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
              ),
            ],
          ),
          Text(
            status,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context, {
    required String drug,
    required String dosage,
    required String time,
    required bool isTaken,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isTaken
                  ? colorScheme.secondaryContainer.withValues(alpha: 0.3)
                  : colorScheme.primaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.check_circle : Icons.alarm,
              color: isTaken ? colorScheme.secondary : colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drug,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$dosage • $time',
                  style: textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          CCChip(
            label: isTaken ? 'Completed' : 'Upcoming',
            variant: isTaken ? CCChipVariant.secondary : CCChipVariant.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
        ],
      ),
    );
  }
}
