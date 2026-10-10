import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../data/datasources/consultants_remote_datasource.dart';
import '../../domain/entities/consultant_review_entity.dart';
import '../../domain/entities/doctor_entity.dart';

class ConsultantProfilePage extends StatefulWidget {
  final String doctorId;

  const ConsultantProfilePage({super.key, required this.doctorId});

  @override
  State<ConsultantProfilePage> createState() => _ConsultantProfilePageState();
}

class _ConsultantProfilePageState extends State<ConsultantProfilePage> {
  final ConsultantsRemoteDataSource _dataSource =
      ConsultantsRemoteDataSourceImpl();

  DoctorEntity? _doctor;
  List<ConsultantReviewEntity> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final doc = await _dataSource.getDoctorById(widget.doctorId);
    final revs = await _dataSource.getDoctorReviews(widget.doctorId);
    if (mounted) {
      setState(() {
        _doctor = doc;
        _reviews = revs;
        _isLoading = false;
      });
    }
  }

  void _openRatingDialog() {
    if (_doctor == null) return;
    double selectedRating = 5.0;
    final commentCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: 'Amina Bello');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Rate ${_doctor!.name}'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your verified rating helps other patients in Abuja choose the best clinical specialist.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text('Consultation Rating:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return IconButton(
                        icon: Icon(
                          starValue <= selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => selectedRating = starValue);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Your Name *',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Clinical Review / Feedback',
                      hintText: 'Describe how the consultation went, diagnosis clarity, and bedside manner...',
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await _dataSource.rateDoctor(
                    doctorId: _doctor!.id,
                    rating: selectedRating,
                    comment: commentCtrl.text.trim().isNotEmpty
                        ? commentCtrl.text.trim()
                        : 'Doctor provided thorough clinical explanation.',
                    patientName: nameCtrl.text.trim().isNotEmpty
                        ? nameCtrl.text.trim()
                        : 'Patient',
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  _loadProfile();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you! Your verified rating was submitted.'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                },
                child: const Text('Submit Rating'),
              ),
            ],
          );
        },
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

    if (_doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Profile')),
        body: const Center(child: Text('Doctor profile not found')),
      );
    }

    final doc = _doctor!;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Rate this Consultant',
            icon: const Icon(Icons.star_outline),
            onPressed: _openRatingDialog,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Fee',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    doc.consultationFee.toNaira(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.phone, size: 15),
                label: const Text('Audio Call'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: () {
                  context.push('/telehealth/call/${doc.id}?type=audio');
                },
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.videocam, size: 16),
                label: const Text('Video Call'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () {
                  context.push('/telehealth/call/${doc.id}?type=video');
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Profile Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.surfaceContainerHigh,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: NetworkImage(doc.avatarUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doc.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc.hospital,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 13, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doc.rating} (${doc.reviewCount} reviews)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: doc.isAvailable
                                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                    : Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                doc.availabilityStatus,
                                style: TextStyle(
                                  fontSize: 10,
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
            ),
            const SizedBox(height: 16),

            // Credentials & MDCN verification banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: colorScheme.secondary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MDCN Registered & Verified',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        Text(
                          '${doc.licenseNumber} • Qualifications: ${doc.qualifications}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Clinical Bio
            const Text(
              'About Consultant',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              doc.bio,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 18),

            // Conditions Treated / Specializations
            const Text(
              'Conditions & Symptoms Treated',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: doc.specializations.map((s) {
                return Chip(
                  label: Text(s),
                  avatar: const Icon(Icons.check, size: 14),
                  backgroundColor: colorScheme.surfaceContainerLowest,
                  side: BorderSide(color: colorScheme.surfaceContainerHigh),
                );
              }).toList(),
            ),
            const Divider(height: 32),

            // Patient Reviews & Ratings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Ratings & Reviews',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${doc.rating} rating from ${doc.reviewCount} verified consultations',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                  label: const Text('Add Review'),
                  onPressed: _openRatingDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No reviews yet. Be the first to consult and rate this doctor!'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final rev = _reviews[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.surfaceContainerHigh,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rev.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (starIdx) {
                                    return Icon(
                                      starIdx < rev.rating.toInt()
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  rev.consultationType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rev.comment,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
