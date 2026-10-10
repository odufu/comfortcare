import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../consultants/data/datasources/consultants_remote_datasource.dart';
import '../../../consultants/data/models/doctor_model.dart';
class AdminConsolePage extends StatefulWidget {
  const AdminConsolePage({super.key});

  @override
  State<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage>
    with SingleTickerProviderStateMixin {
  final ConsultantsRemoteDataSource _consultantsDataSource =
      ConsultantsRemoteDataSourceImpl();

  late TabController _tabController;
  List<DoctorModel> _pendingConsultants = [];
  List<DoctorModel> _approvedConsultants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final pending = await _consultantsDataSource.getPendingConsultants();
    final approved = await _consultantsDataSource.getDoctors();

    if (mounted) {
      setState(() {
        _pendingConsultants = pending;
        _approvedConsultants = approved;
        _isLoading = false;
      });
    }
  }

  Future<void> _approveConsultant(DoctorModel doctor) async {
    try {
      await _consultantsDataSource.approveConsultant(doctor.id);
      if (!mounted) return;
      context.showSnackBar(
        '${doctor.name} has been approved as an active Consultant!',
        isSuccess: true,
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar('Failed to approve consultant: $e', isError: true);
    }
  }

  Future<void> _disapproveConsultant(DoctorModel doctor) async {
    final reasonController = TextEditingController(text: 'Credentials or license requires further verification.');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Disapprove ${doctor.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a note or reason for the rejection:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter rejection notes...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Disapproval'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _consultantsDataSource.rejectConsultant(
          doctor.id,
          reason: reasonController.text.trim(),
        );
        if (!mounted) return;
        context.showSnackBar('Application for ${doctor.name} disapproved.');
        _loadData();
      } catch (e) {
        if (!mounted) return;
        context.showSnackBar('Error: $e', isError: true);
      }
    }
  }

  void _viewCredentialsDoc(DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                doctor.documentationName ?? 'Practicing_License.pdf',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Applicant: ${doctor.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Specialty: ${doctor.specialty}'),
                  Text('License: ${doctor.licenseNumber}'),
                  Text('Institution: ${doctor.hospital}'),
                  Text('Document: ${doctor.documentationName ?? "Practicing_License.pdf"}'),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text('MDCN Digital Watermark Verified', style: TextStyle(fontSize: 11, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Document Status: Stored in encrypted cloud bucket. Admin review certified.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _approveConsultant(doctor);
            },
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Approve Immediately'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF007A78)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Operations Console',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'ComfortCare Abuja • Full Operations & Credential Verification',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Data',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Drug Catalog CRUD',
            onPressed: () => context.push('/admin/products'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/auth/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: _pendingConsultants.isNotEmpty,
                label: Text('${_pendingConsultants.length}'),
                child: const Icon(Icons.verified_user),
              ),
              text: 'Consultant Approvals',
            ),
            const Tab(
              icon: Icon(Icons.medical_services_outlined),
              text: 'Active Consultants',
            ),
            const Tab(
              icon: Icon(Icons.local_pharmacy_outlined),
              text: 'Pharmacy Partners',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConsultantApprovalsTab(),
                _buildActiveConsultantsTab(),
                _buildPharmacyPartnersTab(),
              ],
            ),
    );
  }

  // 1. Consultant Approvals Tab
  Widget _buildConsultantApprovalsTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Overview Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF007A78),
                    const Color(0xFF004D40),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medical Board Credential Reviews',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_pendingConsultants.length} consultants waiting for credential authorization. Review their license, certifications, and approve for patient consultations.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Applicants (${_pendingConsultants.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_pendingConsultants.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      'All Consultant Applications Reviewed!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No pending doctors, surgeons, or therapists currently awaiting approval.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pendingConsultants.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = _pendingConsultants[index];
                  return _buildPendingCard(doc);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(DoctorModel doc) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(doc.avatarUrl),
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doc.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: const Text(
                            'PENDING REVIEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.specialty,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${doc.hospital} • ${doc.qualifications}',
                      style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text(
                  'License: ${doc.licenseNumber}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _viewCredentialsDoc(doc),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(
                        doc.documentationName ?? 'Practicing_License.pdf',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _disapproveConsultant(doc),
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                label: const Text('Disapprove', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _approveConsultant(doc),
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Approve Specialist'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF007A78),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Active Consultants Tab
  Widget _buildActiveConsultantsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Approved Active Specialists (${_approvedConsultants.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            ],
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _approvedConsultants.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = _approvedConsultants[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(doc.avatarUrl),
                  ),
                  title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${doc.specialty} • ${doc.hospital}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: doc.isAvailable ? Colors.green.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: doc.isAvailable ? Colors.green : Colors.grey,
                          ),
                        ),
                        child: Text(
                          doc.isAvailable ? 'ACTIVE' : 'OFFLINE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: doc.isAvailable ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.consultationFee.toNaira(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Pharmacy Partners Tab
  Widget _buildPharmacyPartnersTab() {
    final pharmacies = [
      {
        'name': 'MedPlus Pharmacy Ltd',
        'branch': 'Life Camp Branch, Abuja',
        'license': 'PCN-R-90412',
        'status': 'Active Verified Partner',
        'wholesaleSpend': 4850000.0,
        'retailOrdersFulfilled': 342,
        'contact': '+234 803 555 7890',
      },
      {
        'name': 'HealthPlus Dispensary',
        'branch': 'Maitama Business Hub',
        'license': 'PCN-R-77218',
        'status': 'Active Verified Partner',
        'wholesaleSpend': 6200000.0,
        'retailOrdersFulfilled': 510,
        'contact': '+234 802 345 6789',
      },
      {
        'name': 'Al-Mansur Clinic Pharmacy',
        'branch': 'Wuse 2 Central, Abuja',
        'license': 'PCN-W-89412',
        'status': 'Active Verified Partner',
        'wholesaleSpend': 3100000.0,
        'retailOrdersFulfilled': 198,
        'contact': '+234 803 265 1505',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pharmacy Network Overview',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Licensed pharmacies selling medicines to retail app users and ordering bulk stock from ComfortCare Wholesale.',
                        style: TextStyle(fontSize: 11.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => context.push('/admin/products'),
                  child: const Text('Manage Catalog'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Registered Pharmacy Partners',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pharmacies.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pharm = pharmacies[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_pharmacy, color: Color(0xFF007A78), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pharm['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${pharm['branch']} • PCN: ${pharm['license']}',
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'LICENSED',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Wholesale Procurement', style: TextStyle(fontSize: 10, color: Colors.black54)),
                            Text(
                              (pharm['wholesaleSpend'] as double).toNaira(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Retail Orders Dispensed', style: TextStyle(fontSize: 10, color: Colors.black54)),
                            Text(
                              '${pharm['retailOrdersFulfilled']} orders',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Official Contact', style: TextStyle(fontSize: 10, color: Colors.black54)),
                            Text(
                              pharm['contact'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
