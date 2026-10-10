import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../data/datasources/consultants_remote_datasource.dart';
import '../../data/models/doctor_model.dart';
import '../../domain/entities/doctor_entity.dart';

class ConsultantsDirectoryPage extends StatefulWidget {
  const ConsultantsDirectoryPage({super.key});

  @override
  State<ConsultantsDirectoryPage> createState() =>
      _ConsultantsDirectoryPageState();
}

class _ConsultantsDirectoryPageState extends State<ConsultantsDirectoryPage> {
  final ConsultantsRemoteDataSource _dataSource =
      ConsultantsRemoteDataSourceImpl();

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedSpecialty = 'All';
  bool _onlyAvailable = false;
  bool _isLoading = false;
  List<DoctorModel> _doctors = [];

  final List<String> _specialties = [
    'All',
    'Infectious Diseases',
    'Cardiovascular',
    'Pediatrics',
    'Endocrinology',
    'Obstetrics',
    'Pharmacology',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    final results = await _dataSource.getDoctors(
      specialty: _selectedSpecialty == 'All' ? null : _selectedSpecialty,
      query: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      onlyAvailable: _onlyAvailable,
    );
    if (mounted) {
      setState(() {
        _doctors = results;
        _isLoading = false;
      });
    }
  }

  void _openDoctorRegistrationDialog() {
    final nameCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController(text: 'General Medicine');
    final licenseCtrl = TextEditingController();
    final qualCtrl = TextEditingController(text: 'MBBS, FWACS');
    final hospitalCtrl = TextEditingController(text: 'National Hospital Abuja');
    final feeCtrl = TextEditingController(text: '6500');
    final specCtrl = TextEditingController(text: 'Malaria, Fever, Headache, General Health');
    final bioCtrl = TextEditingController(text: 'Licensed medical practitioner registered with the Medical and Dental Council of Nigeria (MDCN).');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final colorScheme = Theme.of(ctx).colorScheme;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 580,
              height: 640,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Doctor / Consultant Registration',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Full Doctor Name *',
                              hintText: 'e.g. Dr. Kelechi Nwosu',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: titleCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Title & Role *',
                                    hintText: 'e.g. Consultant Pulmonologist',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: specialtyCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Clinical Specialty *',
                                    hintText: 'e.g. Respiratory Medicine',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: licenseCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'MDCN Reg. Number *',
                                    hintText: 'e.g. MDCN Reg. #54910',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: qualCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Qualifications',
                                    hintText: 'e.g. MBBS, FMCP, MSc',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: hospitalCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Hospital Affiliation (Abuja)',
                                    hintText: 'e.g. Garki Hospital Abuja',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: feeCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Consultation Fee (₦) *',
                                    prefixText: '₦ ',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: specCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Specializations & Conditions Treated *',
                              hintText: 'e.g. Asthma, Pneumonia, Chronic Cough, Bronchitis',
                              helperText: 'Used by Dr. Comfort AI to match patient symptoms to your consultation queue.',
                              helperMaxLines: 2,
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: bioCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Doctor Bio & Clinical Experience',
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Complete Registration'),
                        onPressed: () async {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final fee = double.tryParse(feeCtrl.text) ?? 6000.0;
                          final newDoctor = DoctorModel(
                            id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            title: titleCtrl.text.trim().isNotEmpty
                                ? titleCtrl.text.trim()
                                : 'Consultant Physician',
                            specialty: specialtyCtrl.text.trim(),
                            licenseNumber: licenseCtrl.text.trim().isNotEmpty
                                ? licenseCtrl.text.trim()
                                : 'MDCN-PENDING',
                            qualifications: qualCtrl.text.trim(),
                            yearsOfExperience: 10,
                            hospital: hospitalCtrl.text.trim(),
                            consultationFee: fee,
                            specializations: specCtrl.text
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList(),
                            avatarUrl:
                                'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
                            bio: bioCtrl.text.trim(),
                          );

                          await _dataSource.registerDoctor(newDoctor);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          _loadDoctors();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Welcome ${newDoctor.name}! Registered to ComfortCare Abuja Telehealth Network.',
                                ),
                                backgroundColor: colorScheme.primary,
                              ),
                            );
                          }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ComfortCare Doctors & Specialists',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
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
                Flexible(
                  child: Text(
                    'MDCN-Verified Telehealth Consultants • Abuja Network',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Doctor Workspace Console',
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () => context.push('/doctor/console'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: _openDoctorRegistrationDialog,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1, size: 15),
                  SizedBox(width: 4),
                  Text('Doctor Join'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SearchBar(
                        controller: _searchCtrl,
                        hintText: 'Search doctor by name, symptom (e.g. malaria, fever, BP), or hospital...',
                        leading: const Icon(Icons.search, size: 20),
                        trailing: _searchCtrl.text.isNotEmpty
                            ? [
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _loadDoctors();
                                  },
                                ),
                              ]
                            : null,
                        elevation: const WidgetStatePropertyAll(0),
                        backgroundColor: WidgetStatePropertyAll(
                          colorScheme.surfaceContainerLowest,
                        ),
                        onChanged: (_) => _loadDoctors(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      selected: _onlyAvailable,
                      label: const Text('Available Now'),
                      avatar: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      onSelected: (val) {
                        setState(() => _onlyAvailable = val);
                        _loadDoctors();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Specialty category chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final spec = _specialties[index];
                      final isSelected = _selectedSpecialty == spec;
                      return ChoiceChip(
                        label: Text(spec),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedSpecialty = spec);
                          _loadDoctors();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Doctor List Stream
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _doctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No matching doctors found',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search query or specialty filter.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _doctors.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final doc = _doctors[index];
                          return _buildDoctorCard(context, doc, isDark, colorScheme);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(
    BuildContext context,
    DoctorEntity doc,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
        ),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with availability dot (tapping opens full profile)
                GestureDetector(
                  onTap: () => context.push('/consultants/${doc.id}'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: 'View ${doc.name} full profile',
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage: NetworkImage(doc.avatarUrl),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: doc.isAvailable
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surfaceContainerLowest,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Credentials
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => context.push('/consultants/${doc.id}'),
                              child: Text(
                                doc.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 13, color: Colors.amber),
                                const SizedBox(width: 3),
                                Text(
                                  '${doc.rating} (${doc.reviewCount})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doc.title,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doc.hospital} • ${doc.yearsOfExperience} yrs experience',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 13,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doc.licenseNumber,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: doc.isAvailable
                                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                  : Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              doc.availabilityStatus,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: doc.isAvailable
                                    ? const Color(0xFF047857)
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Specialization tags
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: doc.specializations.take(4).map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    spec,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 20),

            // Pricing & Call CTA Buttons
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultation Fee',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      doc.consultationFee.toNaira(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Audio Call Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text('Audio Call'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    context.push('/telehealth/call/${doc.id}?type=audio');
                  },
                ),
                const SizedBox(width: 6),

                // Video Call Button
                FilledButton.icon(
                  icon: const Icon(Icons.videocam, size: 15),
                  label: const Text('Video Call'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
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
  }
}
