import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_text_field.dart';
import '../../../pharmacy_portal/data/repositories/mock_community_pharmacies.dart';
import '../../../pharmacy_portal/domain/entities/pharmacy_entity.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _facilityController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _pharmacistController = TextEditingController();

  UserRole _selectedRole = UserRole.user;
  String _selectedSpecialty = 'Orthopedic Surgeon';
  final String _uploadedDocName = 'MDCN_Practicing_License_2026.pdf';
  String _selectedDistrict = 'Wuse 2, AMAC';
  bool _obscurePassword = true;

  static const List<String> _specialties = [
    'Orthopedic Surgeon',
    'Clinical Psychotherapist',
    'Physiotherapist & Mobility',
    'General Physician / Family Doctor',
    'Cardiologist & Hypertension',
    'Pediatrician & Child Health',
    'Neurologist',
    'Clinical Pharmacologist',
  ];

  static const Map<String, Map<String, double>> _districtCoordinates = {
    'Wuse 2, AMAC': {'lat': 9.0765, 'lng': 7.4720},
    'Maitama, AMAC': {'lat': 9.0880, 'lng': 7.4980},
    'Life Camp, AMAC': {'lat': 9.0125, 'lng': 7.4080},
    'Garki 2, AMAC': {'lat': 9.0340, 'lng': 7.4890},
    'Kado / Gwarinpa, AMAC': {'lat': 9.0920, 'lng': 7.4120},
    'Kubwa, Bwari': {'lat': 9.1550, 'lng': 7.3200},
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _facilityController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _pharmacistController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context, AuthState state) {
    if (_formKey.currentState?.validate() ?? false) {
      final isConsultant = _selectedRole == UserRole.consultant;
      final isPharmacy = _selectedRole == UserRole.pharmacy;

      if (isPharmacy) {
        // Register newly created community pharmacy into decentralized fulfillment network
        final coords = _districtCoordinates[_selectedDistrict] ?? {'lat': 9.0765, 'lng': 7.4720};
        final pharmacyName = _nameController.text.trim();
        final address = '${_addressController.text.trim()}, $_selectedDistrict';
        final whatsapp = _whatsappController.text.trim().isNotEmpty
            ? _whatsappController.text.trim()
            : _phoneController.text.trim();

        MockCommunityPharmaciesRepository.instance.registerPharmacy(
          CommunityPharmacyEntity(
            id: 'ph-${DateTime.now().millisecondsSinceEpoch}',
            name: pharmacyName,
            address: address,
            city: 'Abuja',
            state: 'Federal Capital Territory',
            lga: _selectedDistrict.contains('Kubwa') ? 'Bwari Area Council' : 'Abuja Municipal (AMAC)',
            landmark: 'Near $_selectedDistrict Corridor',
            latitude: coords['lat']!,
            longitude: coords['lng']!,
            phone: _phoneController.text.trim(),
            whatsapp: whatsapp,
            licenseNumber: _licenseController.text.trim(),
            pharmacistInCharge: _pharmacistController.text.trim().isNotEmpty
                ? _pharmacistController.text.trim()
                : 'Pharm. On-Duty',
            isOpen: true,
            rating: 5.0,
            stockLevels: {
              'Coartem 80/480mg': 40,
              'Amoxil 500mg': 30,
              'Augmentin 625mg': 25,
              'Paracetamol 500mg': 100,
              'Latex Gloves (100s)': 50,
            },
          ),
        );
      }

      context.read<AuthBloc>().add(
            RegisterSubmitted(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
              facilityName: isConsultant
                  ? _facilityController.text.trim()
                  : (isPharmacy ? _selectedDistrict : null),
              licenseNumber: (isConsultant || isPharmacy)
                  ? _licenseController.text.trim()
                  : null,
              specialty: isConsultant ? _selectedSpecialty : (isPharmacy ? 'Community Retail & Wholesale' : null),
              documentationName: isConsultant
                  ? _uploadedDocName
                  : (isPharmacy ? 'PCN_Premises_Registration.pdf' : null),
            ),
          );
    }
  }

  void _showConsultantPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pending_actions, color: Color(0xFFD97706), size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Application Submitted',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your consultant application and credentials have been submitted to the ComfortCare Admin console for review.',
              style: TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description, size: 16, color: Color(0xFFB45309)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _uploadedDocName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF78350F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Specialty: $_selectedSpecialty\nLicense: ${_licenseController.text.trim()}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The platform administrator will review your practicing license. You can view your status in your Consultant Console.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/doctor/console');
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF007A78),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Open Consultant Console'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isConsultant = _selectedRole == UserRole.consultant;
    final isPharmacy = _selectedRole == UserRole.pharmacy;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              if (isConsultant) {
                _showConsultantPendingDialog(context);
              } else if (isPharmacy) {
                context.showSnackBar(
                  'Community Pharmacy registered! Sourcing & dispatch routing active.',
                  isSuccess: true,
                );
                context.go('/pharmacy/console');
              } else {
                context.showSnackBar(
                  'Registration successful! Welcome to ComfortCare.',
                  isSuccess: true,
                );
                context.go('/dashboard');
              }
            } else if (state.status == AuthStatus.error && state.errorMessage != null) {
              context.showSnackBar(state.errorMessage!, isError: true);
            }
          },
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Join ComfortCare Abuja',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConsultant
                              ? 'Register as a specialist consultant (requires admin license approval).'
                              : isPharmacy
                                  ? 'Register your licensed pharmacy as a decentralized dispensary partner.'
                                  : 'Connect with specialist doctors and order authentic medications.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Role Selector: User vs Consultant vs Pharmacy
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildRoleChoice(
                                  label: 'User',
                                  subtitle: 'Patient / Seeker',
                                  icon: Icons.person_outline,
                                  isSelected: _selectedRole == UserRole.user,
                                  onTap: () {
                                    setState(() => _selectedRole = UserRole.user);
                                    context.read<AuthBloc>().add(const SwitchRoleEvent(UserRole.user));
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildRoleChoice(
                                  label: 'Consultant',
                                  subtitle: 'Doctor / Specialist',
                                  icon: Icons.medical_services_outlined,
                                  isSelected: isConsultant,
                                  onTap: () {
                                    setState(() => _selectedRole = UserRole.consultant);
                                    context.read<AuthBloc>().add(const SwitchRoleEvent(UserRole.consultant));
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildRoleChoice(
                                  label: 'Pharmacy',
                                  subtitle: 'Retail & Wholesale',
                                  icon: Icons.local_pharmacy_outlined,
                                  isSelected: isPharmacy,
                                  onTap: () {
                                    setState(() => _selectedRole = UserRole.pharmacy);
                                    context.read<AuthBloc>().add(const SwitchRoleEvent(UserRole.pharmacy));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Consultant Notice Banner
                        if (isConsultant) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF59E0B)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.verified_user_outlined, color: Color(0xFFB45309), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Admin Verification Required',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                          color: Color(0xFF78350F),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'All consultants must submit practicing credentials. The ComfortCare Admin console reviews and approves profiles before teleconsultations go live.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.brown.shade800,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Pharmacy Notice Banner
                        if (isPharmacy) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.share_location_rounded, color: Color(0xFF0D9488), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Decentralized Fulfillment Dispensary',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                          color: Color(0xFF0D9488),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Registering captures your dispensary location so NovaExpress couriers can pick up client orders. Prioritizes local arrival time to save patient wait time.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.teal.shade900,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Name / Pharmacy Name
                        CCTextField(
                          controller: _nameController,
                          label: isConsultant
                              ? 'Full Name & Title (e.g. Dr. Ngozi Okafor)'
                              : isPharmacy
                                  ? 'Pharmacy Business / Premise Name'
                                  : 'Full Name',
                          hintText: isConsultant
                              ? 'e.g. Dr. Ngozi Okafor'
                              : isPharmacy
                                  ? 'e.g. Apex Community Pharmacy Ltd'
                                  : 'e.g. Amina Bello',
                          prefixIcon: Icon(
                            isConsultant
                                ? Icons.medical_services_outlined
                                : isPharmacy
                                    ? Icons.storefront
                                    : Icons.person_outline,
                            color: colorScheme.primary,
                          ),
                          validator: (val) => Validators.validateRequired(val, 'Name'),
                        ),
                        const SizedBox(height: 16),

                        // Pharmacy District Dropdown & Address
                        if (isPharmacy) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FCT District & Dispatch Sector',
                                style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedDistrict,
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedDistrict = val);
                                      }
                                    },
                                    items: _districtCoordinates.keys.map((d) {
                                      return DropdownMenuItem<String>(
                                        value: d,
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: colorScheme.primary),
                                            const SizedBox(width: 8),
                                            Text(
                                              d,
                                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CCTextField(
                            controller: _addressController,
                            label: 'Physical Premise Street Address',
                            hintText: 'e.g. Plot 45, Aminu Kano Crescent',
                            prefixIcon: Icon(Icons.pin_drop_outlined, color: colorScheme.primary),
                            validator: (val) => Validators.validateRequired(val, 'Premise Address'),
                          ),
                          const SizedBox(height: 16),
                          CCTextField(
                            controller: _pharmacistController,
                            label: 'Superintendent Pharmacist-in-Charge',
                            hintText: 'e.g. Pharm. Kenneth Okafor, B.Pharm',
                            prefixIcon: Icon(Icons.badge_outlined, color: colorScheme.primary),
                            validator: (val) => Validators.validateRequired(val, 'Pharmacist in Charge'),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Specialty Dropdown (Consultant only)
                        if (isConsultant) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSpecialty,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedSpecialty = val);
                                  }
                                },
                                items: _specialties.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s,
                                    child: Row(
                                      children: [
                                        Icon(Icons.workspace_premium, size: 16, color: colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          s,
                                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email
                        CCTextField(
                          controller: _emailController,
                          label: isConsultant
                              ? 'Official Professional Email'
                              : isPharmacy
                                  ? 'Dispensary Contact Email'
                                  : 'Email Address',
                          hintText: isConsultant
                              ? 'e.g. dr.ngozi@clinic.ng'
                              : isPharmacy
                                  ? 'e.g. info@apexpharmacy.ng'
                                  : 'e.g. amina@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        CCTextField(
                          controller: _phoneController,
                          label: 'Phone Number (Abuja SMS & Alerts)',
                          hintText: 'e.g. 0803 265 1505',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.primary),
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 16),

                        // WhatsApp Number (Pharmacy only)
                        if (isPharmacy) ...[
                          CCTextField(
                            controller: _whatsappController,
                            label: 'WhatsApp Line (For NovaExpress Pickup Dispatch)',
                            hintText: 'e.g. 0803 265 1505',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF16A34A)),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // License Number (Consultant or Pharmacy)
                        if (isConsultant || isPharmacy) ...[
                          CCTextField(
                            controller: _licenseController,
                            label: isPharmacy
                                ? 'PCN Premises Registration License Number'
                                : 'MDCN / Professional License Number',
                            hintText: isPharmacy ? 'e.g. PCN/FCT/2026/0981' : 'e.g. MDCN-92041-FMC',
                            prefixIcon: Icon(Icons.badge_outlined, color: colorScheme.primary),
                            validator: (val) => Validators.validateRequired(val, 'License Number'),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Consultant Facility
                        if (isConsultant) ...[
                          CCTextField(
                            controller: _facilityController,
                            label: 'Hospital / Clinic / Practice Affiliation',
                            hintText: 'e.g. National Hospital Abuja / Private Clinic',
                            prefixIcon: Icon(Icons.local_hospital_outlined, color: colorScheme.primary),
                            validator: (val) => Validators.validateRequired(val, 'Affiliation'),
                          ),
                          const SizedBox(height: 16),

                          // Documentation Upload Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.35),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.upload_file, color: colorScheme.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Practicing License / Credential Document',
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _uploadedDocName,
                                              style: textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Ready for Admin Verification • 2.4 MB',
                                              style: textTheme.labelSmall?.copyWith(
                                                fontSize: 10,
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Password
                        CCTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        CCButton(
                          label: isConsultant
                              ? 'Submit Credentials for Admin Review'
                              : isPharmacy
                                  ? 'Register Pharmacy Dispensary'
                                  : 'Create User Account',
                          isLoading: state.isLoading,
                          onPressed: () => _onRegister(context, state),
                        ),
                        const SizedBox(height: 16),

                        // Back to Sign In
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already registered?',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                'Sign In',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleChoice({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? colorScheme.onPrimary.withValues(alpha: 0.85)
                          : colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
