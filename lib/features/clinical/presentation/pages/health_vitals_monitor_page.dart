import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String _selectedTimeframe = '7 Days';
  final List<String> _timeframes = ['24 Hours', '7 Days', '30 Days', '3 Months'];

  // Reminder checklist state
  final Map<String, bool> _remindersState = {
    'Coartem 80/480mg': true,
    'Panadol Extra Tablets': false,
    'Omega-3 Fish Oil 1000mg': true,
  };

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
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Record Clinical Health Reading',
                    style: ctx.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Telemetry data syncs securely with your Abuja clinical dossier.',
                style: ctx.textTheme.bodySmall?.copyWith(color: ctx.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Systolic (mmHg)',
                        hintText: '120',
                        prefixIcon: Icon(Icons.favorite_border, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: diaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Diastolic (mmHg)',
                        hintText: '80',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hrController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Heart Rate (bpm)',
                        hintText: '72',
                        prefixIcon: Icon(Icons.speed, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: gluController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Blood Glucose (mg/dL)',
                        hintText: '95',
                        prefixIcon: Icon(Icons.water_drop_outlined, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: tempController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Body Temperature (°C)',
                  hintText: '36.7',
                  prefixIcon: Icon(Icons.thermostat, size: 18),
                ),
              ),
              const SizedBox(height: 22),
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
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : const Icon(Icons.monitor_heart_outlined),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Health Vitals Telemetry'),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  'Abuja Central Clinic Stream • Live',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_outlined),
            tooltip: 'Log New Reading',
            onPressed: () => _showLogVitalsDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ClinicalBloc, ClinicalState>(
        builder: (context, state) {
          final vitals = state.vitals ??
              HealthVitalsEntity(
                systolic: 120,
                diastolic: 80,
                heartRate: 72,
                bloodGlucose: 95.0,
                temperature: 36.7,
                loggedAt: DateTime.now(),
              );

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header & Timeframe Selector Bar
                        _buildTopStatusBar(context),
                        const SizedBox(height: 16),

                        if (isDesktop)
                          // Dual-Pane Desktop Layout
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Pane: Interactive Medical Charts (Flex 6)
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildBloodPressureChartCard(context, vitals),
                                    const SizedBox(height: 16),
                                    _buildECGWaveformCard(context, vitals),
                                    const SizedBox(height: 16),
                                    _buildGlucoseTrendCard(context, vitals),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Right Pane: Stat Metrics & Adherence (Flex 4)
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    // 4 Live Stats Grid
                                    _buildVitalsMetricsGrid(context, vitals, isDesktop: true),
                                    const SizedBox(height: 16),
                                    // Weekly Adherence Gauge
                                    _buildAdherenceGaugeCard(context),
                                    const SizedBox(height: 16),
                                    // Medication Reminders
                                    _buildRemindersSection(context),
                                    const SizedBox(height: 16),
                                    // Fast Action CTA
                                    CCButton(
                                      label: '+ Record New Vitals Reading',
                                      onPressed: () => _showLogVitalsDialog(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          // Fluid Mobile Stack Layout (< 960px)
                          Column(
                            children: [
                              _buildVitalsMetricsGrid(context, vitals, isDesktop: false),
                              const SizedBox(height: 16),
                              _buildBloodPressureChartCard(context, vitals),
                              const SizedBox(height: 16),
                              _buildECGWaveformCard(context, vitals),
                              const SizedBox(height: 16),
                              _buildGlucoseTrendCard(context, vitals),
                              const SizedBox(height: 16),
                              _buildAdherenceGaugeCard(context),
                              const SizedBox(height: 16),
                              _buildRemindersSection(context),
                              const SizedBox(height: 16),
                              CCButton(
                                label: '+ Record New Vitals Reading',
                                onPressed: () => _showLogVitalsDialog(context),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                      ],
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

  // Top Status Bar with Timeframe Pills
  Widget _buildTopStatusBar(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.analytics_outlined, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Telemetry Timeline',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Continuous Abuja Clinic Feed',
                    style: textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          // Timeframe Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _timeframes.map((tf) {
                final isSelected = tf == _selectedTimeframe;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTimeframe = tf),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tf,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 4 Vitals Stat Metrics Grid
  Widget _buildVitalsMetricsGrid(BuildContext context, HealthVitalsEntity vitals, {required bool isDesktop}) {
    final colorScheme = context.colorScheme;

    return GridView.count(
      crossAxisCount: isDesktop ? 2 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        _buildVitalCard(
          context,
          title: 'BLOOD PRESSURE',
          value: '${vitals.systolic}/${vitals.diastolic}',
          unit: 'mmHg',
          status: vitals.bpStatus,
          icon: Icons.favorite,
          color: colorScheme.primary,
        ),
        _buildVitalCard(
          context,
          title: 'FASTING GLUCOSE',
          value: vitals.bloodGlucose.toStringAsFixed(0),
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
          color: Colors.deepOrange,
        ),
        _buildVitalCard(
          context,
          title: 'BODY TEMP',
          value: '${vitals.temperature}°',
          unit: 'Celsius',
          status: 'Afebrile (Norm)',
          icon: Icons.thermostat,
          color: Colors.purple,
        ),
      ],
    );
  }

  // CHART 1: Interactive Blood Pressure Telemetry Trend Chart
  Widget _buildBloodPressureChartCard(BuildContext context, HealthVitalsEntity vitals) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final systolicData = [124, 121, 126, 122, 125, 119, vitals.systolic];
    final diastolicData = [82, 80, 84, 81, 83, 79, vitals.diastolic];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Today'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.show_chart, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Blood Pressure 7-Day Trend',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Text(
                    'Optimal Target Band: 110–125 / 70–85 mmHg',
                    style: textTheme.bodySmall?.copyWith(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              CCChip(
                label: '${vitals.systolic}/${vitals.diastolic} mmHg',
                variant: CCChipVariant.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legend Indicators
          Row(
            children: [
              _buildLegendDot(color: colorScheme.primary, label: 'Systolic'),
              const SizedBox(width: 14),
              _buildLegendDot(color: colorScheme.secondary, label: 'Diastolic'),
              const SizedBox(width: 14),
              _buildLegendDot(
                color: Colors.green.withValues(alpha: 0.35),
                label: 'Optimal Zone',
                isSquare: true,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Canvas Chart
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _BloodPressureChartPainter(
                systolicData: systolicData,
                diastolicData: diastolicData,
                days: days,
                systolicColor: colorScheme.primary,
                diastolicColor: colorScheme.secondary,
                gridColor: colorScheme.surfaceContainerHigh,
                targetBandColor: Colors.green.withValues(alpha: 0.08),
                textColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CHART 2: Real-Time ECG Cardiac Waveform Card
  Widget _buildECGWaveformCard(BuildContext context, HealthVitalsEntity vitals) {
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate telemetry monitor background
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  const Icon(Icons.monitor_heart, size: 18, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    'Live ECG Telemetry Waveform',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
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
                    const Text(
                      'LEAD II • NSR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Telemetry Readout Values
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildECGMetric(title: 'HEART RATE', value: '${vitals.heartRate}', unit: 'BPM', isPrimary: true),
                const SizedBox(width: 14),
                _buildECGMetric(title: 'PR INTERVAL', value: '156', unit: 'ms'),
                const SizedBox(width: 14),
                _buildECGMetric(title: 'QRS DURATION', value: '88', unit: 'ms'),
                const SizedBox(width: 14),
                _buildECGMetric(title: 'QTc INTERVAL', value: '412', unit: 'ms'),
                const SizedBox(width: 14),
                _buildECGMetric(title: 'SpO2 OXYGEN', value: '99', unit: '%'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Custom Painter for ECG Waveform
          SizedBox(
            height: 120,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _ECGWaveformPainter(
                  pulseColor: const Color(0xFF10B981),
                  gridColor: const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CHART 3: Fasting Blood Glucose 24H Curve
  Widget _buildGlucoseTrendCard(BuildContext context, HealthVitalsEntity vitals) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final glucosePoints = [92.0, 114.0, 98.0, 106.0, vitals.bloodGlucose];
    final labels = ['07:00 Fasting', '09:30 Post-Bkfst', '13:00 Pre-Lunch', '15:30 Post-Lunch', 'Current'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
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
              Row(
                children: [
                  Icon(Icons.water_drop_outlined, size: 18, color: colorScheme.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '24-Hour Blood Glucose Profile',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              CCChip(
                label: 'Optimal Euglycemia',
                variant: CCChipVariant.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Target Fasting: 70–100 mg/dL • Post-Prandial: <140 mg/dL',
            style: textTheme.bodySmall?.copyWith(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // Custom Canvas for Glucose
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _GlucoseChartPainter(
                data: glucosePoints,
                labels: labels,
                lineColor: colorScheme.secondary,
                gridColor: colorScheme.surfaceContainerHigh,
                targetBandColor: Colors.teal.withValues(alpha: 0.08),
                textColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CHART 4: Medication Adherence Radial Gauge
  Widget _buildAdherenceGaugeCard(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final completed = [true, true, true, true, true, false, true];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.03),
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
              Text(
                'Weekly Medication Adherence',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              CCChip(
                label: '86% Streak',
                variant: CCChipVariant.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Radial Gauge
              SizedBox(
                width: 72,
                height: 72,
                child: CustomPaint(
                  painter: _AdherenceRingPainter(
                    progress: 0.86,
                    trackColor: colorScheme.surfaceContainerHigh,
                    progressColor: colorScheme.secondary,
                  ),
                  child: Center(
                    child: Text(
                      '86%',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '6 of 7 Days Fully Logged',
                      style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Maintaining strict adherence prevents malaria recurrence & stabilizes blood pressure.',
                      style: textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 8),

                    // Day Dots Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final isDone = completed[i];
                        return Column(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? colorScheme.secondary
                                    : colorScheme.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  isDone ? Icons.check : Icons.close,
                                  size: 12,
                                  color: isDone ? Colors.white : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              days[i],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Medication Reminders with Interactive Checkboxes
  Widget _buildRemindersSection(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prescription Adherence Schedule',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              Icon(Icons.alarm_on, size: 18, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 12),

          _buildInteractiveReminderTile(
            context,
            drug: 'Coartem 80/480mg',
            dosage: '1 Tab with fatty food (Malaria ACT Day 2)',
            time: '08:00 AM & 08:00 PM',
          ),
          const SizedBox(height: 8),
          _buildInteractiveReminderTile(
            context,
            drug: 'Panadol Extra Tablets',
            dosage: '1 Tab as needed for headache',
            time: '02:00 PM (Midday)',
          ),
          const SizedBox(height: 8),
          _buildInteractiveReminderTile(
            context,
            drug: 'Omega-3 Fish Oil 1000mg',
            dosage: '1 Softgel daily after breakfast',
            time: '09:00 AM (Daily)',
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveReminderTile(
    BuildContext context, {
    required String drug,
    required String dosage,
    required String time,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isDone = _remindersState[drug] ?? false;

    return InkWell(
      onTap: () {
        setState(() {
          _remindersState[drug] = !isDone;
        });
        context.showSnackBar(
          isDone ? '$drug marked as pending.' : '$drug logged as taken!',
          isSuccess: !isDone,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDone
              ? colorScheme.secondaryContainer.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? colorScheme.secondary.withValues(alpha: 0.3) : colorScheme.surfaceContainerHigh,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? colorScheme.secondary : colorScheme.outline,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$dosage • $time',
                    style: textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            CCChip(
              label: isDone ? 'Taken' : 'Due',
              variant: isDone ? CCChipVariant.secondary : CCChipVariant.primary,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
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
              Expanded(
                child: Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 15, color: color),
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
                style: textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 10),
              ),
            ],
          ),
          Text(
            status,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label, bool isSquare = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isSquare ? BorderRadius.circular(2) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildECGMetric({
    required String title,
    required String value,
    required String unit,
    bool isPrimary = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isPrimary ? 18 : 14,
                fontWeight: FontWeight.w900,
                color: isPrimary ? const Color(0xFF10B981) : Colors.white,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom Painter 1: Blood Pressure Dual Curve Chart (Systolic + Diastolic)
class _BloodPressureChartPainter extends CustomPainter {
  final List<int> systolicData;
  final List<int> diastolicData;
  final List<String> days;
  final Color systolicColor;
  final Color diastolicColor;
  final Color gridColor;
  final Color targetBandColor;
  final Color textColor;

  _BloodPressureChartPainter({
    required this.systolicData,
    required this.diastolicData,
    required this.days,
    required this.systolicColor,
    required this.diastolicColor,
    required this.gridColor,
    required this.targetBandColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPadding = 24.0;
    const leftPadding = 30.0;
    const topPadding = 10.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width - leftPadding;

    const minY = 60.0;
    const maxY = 150.0;

    double getY(double val) {
      final norm = (val - minY) / (maxY - minY);
      return topPadding + chartHeight * (1.0 - norm);
    }

    double getX(int index) {
      final step = chartWidth / (days.length - 1);
      return leftPadding + (index * step);
    }

    // Paint Grid Lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(fontSize: 9, color: textColor, fontWeight: FontWeight.w600);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final ySteps = [70, 90, 110, 130];
    for (final step in ySteps) {
      final y = getY(step.toDouble());
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);

      textPainter.text = TextSpan(text: '$step', style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 6));
    }

    // Paint Optimal Target Zone (Systolic 110-125, Diastolic 70-85)
    final bandPaint = Paint()
      ..color = targetBandColor
      ..style = PaintingStyle.fill;

    final sysBandTop = getY(125);
    final sysBandBottom = getY(110);
    canvas.drawRect(
      Rect.fromLTRB(leftPadding, sysBandTop, size.width, sysBandBottom),
      bandPaint,
    );

    final diaBandTop = getY(85);
    final diaBandBottom = getY(70);
    canvas.drawRect(
      Rect.fromLTRB(leftPadding, diaBandTop, size.width, diaBandBottom),
      bandPaint,
    );

    // Draw Systolic Curve
    _drawCurve(
      canvas: canvas,
      data: systolicData.map((e) => e.toDouble()).toList(),
      getX: getX,
      getY: getY,
      lineColor: systolicColor,
      fillColor: systolicColor.withValues(alpha: 0.12),
      chartBottom: topPadding + chartHeight,
      leftPadding: leftPadding,
      width: size.width,
    );

    // Draw Diastolic Curve
    _drawCurve(
      canvas: canvas,
      data: diastolicData.map((e) => e.toDouble()).toList(),
      getX: getX,
      getY: getY,
      lineColor: diastolicColor,
      fillColor: diastolicColor.withValues(alpha: 0.12),
      chartBottom: topPadding + chartHeight,
      leftPadding: leftPadding,
      width: size.width,
    );

    // Draw X-Axis Day Labels
    for (int i = 0; i < days.length; i++) {
      final x = getX(i);
      textPainter.text = TextSpan(text: days[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 16));
    }
  }

  void _drawCurve({
    required Canvas canvas,
    required List<double> data,
    required double Function(int) getX,
    required double Function(double) getY,
    required Color lineColor,
    required Color fillColor,
    required double chartBottom,
    required double leftPadding,
    required double width,
  }) {
    if (data.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    path.moveTo(getX(0), getY(data[0]));
    fillPath.moveTo(getX(0), chartBottom);
    fillPath.lineTo(getX(0), getY(data[0]));

    for (int i = 0; i < data.length - 1; i++) {
      final x0 = getX(i);
      final y0 = getY(data[i]);
      final x1 = getX(i + 1);
      final y1 = getY(data[i + 1]);

      final controlX1 = x0 + (x1 - x0) / 2;
      final controlY1 = y0;
      final controlX2 = x0 + (x1 - x0) / 2;
      final controlY2 = y1;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x1, y1);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x1, y1);
    }

    fillPath.lineTo(getX(data.length - 1), chartBottom);
    fillPath.close();

    // Fill under curve
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Data dots
    final dotPaint = Paint()..color = lineColor;
    final dotInnerPaint = Paint()..color = Colors.white;

    for (int i = 0; i < data.length; i++) {
      final center = Offset(getX(i), getY(data[i]));
      canvas.drawCircle(center, 4, dotPaint);
      canvas.drawCircle(center, 2, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BloodPressureChartPainter oldDelegate) => true;
}

// Custom Painter 2: ECG Cardiac Rhythm Waveform
class _ECGWaveformPainter extends CustomPainter {
  final Color pulseColor;
  final Color gridColor;

  _ECGWaveformPainter({required this.pulseColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Fine Millimeter Medical Grid
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const cellSize = 16.0;
    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Realistic ECG Cardiac Waveform (P-Q-R-S-T Complex)
    final ecgPath = Path();
    final midY = size.height * 0.55;
    const cycleWidth = 110.0;
    final totalCycles = (size.width / cycleWidth).ceil() + 1;

    ecgPath.moveTo(0, midY);

    for (int i = 0; i < totalCycles; i++) {
      final startX = i * cycleWidth;

      // Isoelectric baseline
      ecgPath.lineTo(startX + 15, midY);
      // P Wave (atrial depolarization)
      ecgPath.quadraticBezierTo(startX + 22, midY - 10, startX + 30, midY);
      // PR Segment
      ecgPath.lineTo(startX + 40, midY);
      // Q Wave (septal depolarization)
      ecgPath.lineTo(startX + 44, midY + 8);
      // R Peak (ventricular depolarization - sharp high spike)
      ecgPath.lineTo(startX + 50, midY - 48);
      // S Wave (ventricular depolarization downward)
      ecgPath.lineTo(startX + 56, midY + 18);
      // ST Segment
      ecgPath.lineTo(startX + 66, midY);
      // T Wave (ventricular repolarization)
      ecgPath.quadraticBezierTo(startX + 78, midY - 14, startX + 90, midY);
      // Return to baseline
      ecgPath.lineTo(startX + cycleWidth, midY);
    }

    // Glow effect stroke
    final glowPaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.3)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ecgPath, glowPaint);

    // Crisp pulse stroke
    final strokePaint = Paint()
      ..color = pulseColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ecgPath, strokePaint);

    // Real-time Sweep Head at the right
    final headX = size.width - 24;
    canvas.drawCircle(
      Offset(headX, midY),
      5,
      Paint()..color = pulseColor.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      Offset(headX, midY),
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ECGWaveformPainter oldDelegate) => false;
}

// Custom Painter 3: Fasting Blood Glucose Trend
class _GlucoseChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color lineColor;
  final Color gridColor;
  final Color targetBandColor;
  final Color textColor;

  _GlucoseChartPainter({
    required this.data,
    required this.labels,
    required this.lineColor,
    required this.gridColor,
    required this.targetBandColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPadding = 24.0;
    const leftPadding = 32.0;
    const topPadding = 10.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width - leftPadding;

    const minY = 60.0;
    const maxY = 140.0;

    double getY(double val) {
      final norm = (val - minY) / (maxY - minY);
      return topPadding + chartHeight * (1.0 - norm);
    }

    double getX(int index) {
      final step = chartWidth / (labels.length - 1);
      return leftPadding + (index * step);
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(fontSize: 8.5, color: textColor, fontWeight: FontWeight.w600);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final val in [70, 100, 130]) {
      final y = getY(val.toDouble());
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
      textPainter.text = TextSpan(text: '$val', style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 6));
    }

    // Target Euglycemia Band (70 to 110 mg/dL)
    final bandTop = getY(110);
    final bandBottom = getY(70);
    canvas.drawRect(
      Rect.fromLTRB(leftPadding, bandTop, size.width, bandBottom),
      Paint()
        ..color = targetBandColor
        ..style = PaintingStyle.fill,
    );

    // Smooth curve
    final path = Path();
    final fillPath = Path();

    path.moveTo(getX(0), getY(data[0]));
    fillPath.moveTo(getX(0), topPadding + chartHeight);
    fillPath.lineTo(getX(0), getY(data[0]));

    for (int i = 0; i < data.length - 1; i++) {
      final x0 = getX(i);
      final y0 = getY(data[i]);
      final x1 = getX(i + 1);
      final y1 = getY(data[i + 1]);

      final cx1 = x0 + (x1 - x0) / 2;
      final cy1 = y0;
      final cx2 = x0 + (x1 - x0) / 2;
      final cy2 = y1;

      path.cubicTo(cx1, cy1, cx2, cy2, x1, y1);
      fillPath.cubicTo(cx1, cy1, cx2, cy2, x1, y1);
    }

    fillPath.lineTo(getX(data.length - 1), topPadding + chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = lineColor.withValues(alpha: 0.1));
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Dots & Callout Values
    for (int i = 0; i < data.length; i++) {
      final center = Offset(getX(i), getY(data[i]));
      canvas.drawCircle(center, 4, Paint()..color = lineColor);
      canvas.drawCircle(center, 2, Paint()..color = Colors.white);

      // Label below
      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), size.height - 16));
    }
  }

  @override
  bool shouldRepaint(covariant _GlucoseChartPainter oldDelegate) => true;
}

// Custom Painter 4: Adherence Radial Ring
class _AdherenceRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _AdherenceRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AdherenceRingPainter oldDelegate) => true;
}
