import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/consultation_message.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_event.dart';
import '../bloc/clinical_state.dart';
import '../widgets/ai_clinical_regimen_card.dart';

class AiClinicalConsultationPage extends StatefulWidget {
  const AiClinicalConsultationPage({super.key});

  @override
  State<AiClinicalConsultationPage> createState() => _AiClinicalConsultationPageState();
}

class _AiClinicalConsultationPageState extends State<AiClinicalConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _selectedCount = 3;
  double _selectedTotal = 7200.0;
  double _originalTotal = 8000.0;
  double _savings = 800.0;
  List<String> _selectedIds = [
    'prod-coartem-80-480',
    'prod-emzor-paracetamol',
    'prod-carestart-rdt',
  ];

  final List<String> _quickActionChips = [
    'Ask about food interactions',
    'Swap Paracetamol for Ibuprofen?',
    'Request dispatch photo',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ClinicalBloc>().add(LoadConsultationHistory());
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
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 200,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onRegimenTotalsChanged(
    int count,
    double total,
    double original,
    double savings,
    List<String> selectedIds,
  ) {
    setState(() {
      _selectedCount = count;
      _selectedTotal = total;
      _originalTotal = original;
      _savings = savings;
      _selectedIds = selectedIds;
    });
  }

  void _proceedToCheckout(ClinicalState state) {
    if (_selectedIds.isEmpty) {
      context.showSnackBar('Please select at least 1 care item.', isError: true);
      return;
    }

    // Collect products from consultation recommendations or fallback models
    final List<ProductEntity> availableProducts = [];
    for (final msg in state.messages) {
      if (msg.recommendedProducts != null) {
        availableProducts.addAll(msg.recommendedProducts!);
      }
    }

    for (final id in _selectedIds) {
      final existing = availableProducts.where((p) => p.id == id).firstOrNull;
      if (existing != null) {
        context.read<CartBloc>().add(AddToCart(product: existing));
      } else {
        // Fallback product model
        final fallback = _createFallbackProduct(id);
        context.read<CartBloc>().add(AddToCart(product: fallback));
      }
    }

    context.showSnackBar(
      'Added $_selectedCount regimen items to cart with 10% AI Bundle discount!',
      isSuccess: true,
    );
    context.push('/cart');
  }

  ProductEntity _createFallbackProduct(String id) {
    switch (id) {
      case 'prod-coartem-80-480':
        return const ProductModel(
          id: 'prod-coartem-80-480',
          name: 'Coartem 80/480mg',
          brand: 'Novartis',
          genericName: 'Artemether 80mg + Lumefantrine 480mg',
          packSize: '6 Film-Coated Tablets',
          price: 4200.0,
          wholesalePrice: 3500.0,
          category: 'Malaria Meds',
          description: 'Primary ACT anti-malarial treatment.',
          dosageInstructions: 'Take 1 tablet twice daily with meals for 3 days.',
          activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
          nafdacNumber: 'NAFDAC Reg. A4-0245',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoLw9r-RmsXTnOXgJM3rXNLOWTp4aNanpbJT4yg1dHRH5bh8wBJw_eZkLeWPOHuZZ_kVoP-UXzPUtD-sfGLck1C3w9gjm4SZ56JuI0g4F_HK7Ob0BQbZ3Bi0BW4x66DmgyxUZGJx_OLz-TnFNPyQg49zsaiNsncvjT35QqHDYEHcDPjQ54vxtV0J_wBbh5rV6n2cXy_EKqVhLe6jV77o16zZPiZGVmHho2akb6gLVW1oRjZXo8o5CaNgYsVNmVvK3mQ',
        );
      case 'prod-emzor-paracetamol':
        return const ProductModel(
          id: 'prod-emzor-paracetamol',
          name: 'Emzor Paracetamol 500mg',
          brand: 'Emzor Pharmaceuticals',
          genericName: 'Paracetamol BP 500mg',
          packSize: '20 Caplets',
          price: 1200.0,
          wholesalePrice: 950.0,
          category: 'Vitamins & Zinc',
          description: 'Antipyretic and analgesic for fever and chills relief.',
          dosageInstructions: '2 tabs every 8 hrs. Fast Dissolve.',
          activeIngredients: 'Paracetamol 500mg',
          nafdacNumber: 'NAFDAC Reg. 04-0312',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        );
      case 'prod-carestart-rdt':
        return const ProductModel(
          id: 'prod-carestart-rdt',
          name: 'CareStart Malaria RDT Kit',
          brand: 'Access Bio',
          genericName: 'Single Antigen Cassette Test',
          packSize: '1 Test Cassette + Lancet',
          price: 1800.0,
          wholesalePrice: 1400.0,
          category: 'Medical Devices',
          description: '15-Min rapid diagnostic test for Malaria antigen.',
          dosageInstructions: 'Single use diagnostic test.',
          activeIngredients: 'HRP2 Antigen Strip',
          nafdacNumber: 'NAFDAC Reg. 03-8821',
          imageUrl:
              'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
        );
      case 'prod-ors-zinc':
      default:
        return const ProductModel(
          id: 'prod-ors-zinc',
          name: 'ORS Hydration + Zinc',
          brand: 'Chi Pharmaceuticals',
          genericName: 'Oral Rehydration Salts with Zinc Sulfate',
          packSize: '5 Sachets',
          price: 1400.0,
          wholesalePrice: 1100.0,
          category: 'Vitamins & Zinc',
          description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
          dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
          activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
          nafdacNumber: 'NAFDAC Reg. 04-5512',
          imageUrl:
              'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006194)),
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
                color: const Color(0xFF006194),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006194).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'ComfortCare',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF006194),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA0F399),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified, size: 11, color: Color(0xFF217128)),
                          SizedBox(width: 2),
                          Text(
                            'Abuja',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF217128),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Pharmacist Consult',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3F4850),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF3F4850)),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFDAE2FD),
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida/AEtjO1WjFuU0Bkh-tRsd4vZtbY50RYc-26TYPCVsc_QvRdnshh94Wl0FHxfIRp_razpbA2uyyUqkdpvvGlkW87MIhoxuJqU8PYmn8uXQN7nUCzUXuUk0107p9lTxlrF9FlPgw5tCTusZ9rW1u2ScnRZaNGNMnVtYV-2YcVeMzsfaQ4zoMGYGF6CGkh5WpVo9U9E46ot9Sg1YbmahDKp5r7DWZHkhXGRu-fNsuRBzZVjmLSE-jxVQEbN_MX6KFSr_2EdM9Ed_YBystPwLoQ',
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ClinicalBloc, ClinicalState>(
        builder: (context, state) {
          return Column(
            children: [
              // Medical Care Protocol Header Ribbon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E7FF).withValues(alpha: 0.65),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFDAE2FD), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF006194),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF006194).withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.smart_toy,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF88D982),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'ComfortCare AI Doctor',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF131B2E),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCE5FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.verified_user,
                                        size: 10,
                                        color: Color(0xFF001D31),
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'PCN Regulated',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF001D31),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1B6D24),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Live Pharmacist Co-Pilot Active',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1B6D24),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.local_shipping, size: 13, color: Color(0xFF006194)),
                          SizedBox(width: 4),
                          Text(
                            'Abuja Depot',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F4850),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Stream
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  children: [
                    // Timestamp & Triage Badge
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Today, 14:28 • Protocol #CC-ABJ-8942',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3F4850),
                          ),
                        ),
                      ),
                    ),

                    // User Message Bubble
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16, left: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF006194),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(4),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x22006194),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Good afternoon. I've had intense headache, chills, fever of 38.6°C, and fatigue since last night. What should I take?",
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  '14:28',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFCCE5FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.done_all,
                                  size: 13,
                                  color: Color(0xFFCCE5FF),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // AI Clinical Diagnostic Bubble
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(top: 2, right: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007BB9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF007BB9).withValues(alpha: 0.25),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Diagnostic Assessment Box
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(18),
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFE2E7FF),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
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
                                          children: const [
                                            Icon(
                                              Icons.medical_services,
                                              size: 15,
                                              color: Color(0xFF006194),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Clinical Diagnostic Assessment',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF006194),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFDAD6),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'High Priority',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF93000A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Hello, based on your acute febrile symptoms and prevalence in the Abuja area, this indicates uncomplicated malaria accompanied by febrile pain. I have generated a personalized recovery protocol formulated for fast symptom clearance.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.45,
                                        color: Color(0xFF131B2E),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2F3FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.verified,
                                            size: 16,
                                            color: Color(0xFF1B6D24),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Reviewed against PCN malaria management guidelines & temperature record (38.6°C).',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF3F4850),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Embedded Pixel-Perfect AI Clinical Regimen Card
                              AiClinicalRegimenCard(
                                onTotalsChanged: _onRegimenTotalsChanged,
                              ),

                              const SizedBox(height: 12),

                              // Micro Pharmacist Follow-up Note
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F3FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE2E7FF),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.only(top: 2, right: 10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1B6D24),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.medical_information,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Row(
                                            children: [
                                              Text(
                                                'Pharm. Note & Guidance',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF131B2E),
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '• 1 min ago',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF3F4850),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            '"If temperature rises above 39.2°C or persists past 48 hours post-dose, utilize the instant pharmacist consultation link on this screen for clinical escalation."',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              height: 1.4,
                                              color: Color(0xFF3F4850),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Suggested Quick Action Chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _quickActionChips.map((chipText) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        elevation: 1,
                                        shadowColor: Colors.black.withValues(alpha: 0.1),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () => _sendMessage(chipText),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              chipText,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF006194),
                                              ),
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
                        ),
                      ],
                    ),

                    // Additional dynamic messages from state
                    ...state.messages.where((m) => m.id != 'msg-01' && m.id != 'msg-02').map((msg) {
                      return _buildAdditionalMessage(context, msg);
                    }),

                    if (state.isThinking)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F3FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF006194),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'AI Doctor evaluating symptoms against formulary...',
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Fixed Action Bar & Single-Tap Checkout Tray
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.98),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006194).withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                  border: const Border(
                    top: BorderSide(color: Color(0xFFE2E7FF), width: 1),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pricing & Savings Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                'REGIMEN TOTAL: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3F4850),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                _selectedTotal.toNaira(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF006194),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (_savings > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  _originalTotal.toNaira(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                    color: Color(0xFF707881),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_savings > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA0F399),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Save ${_savings.toNaira()} Applied',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF217128),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Large Primary Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006194),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                            shadowColor: const Color(0xFF006194).withValues(alpha: 0.35),
                          ),
                          onPressed: () => _proceedToCheckout(state),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bolt, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Proceed to 1-Tap Checkout ($_selectedCount Item${_selectedCount == 1 ? '' : 's'})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Safety & Regulatory Compliance Lockup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.verified,
                            size: 13,
                            color: Color(0xFF1B6D24),
                          ),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Supervised by Pharm. Halima Bello (PCN #44912) • NAFDAC Approved Formulary',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3F4850),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Chat Input Field for additional questions
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3FF),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF131B2E),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Ask doctor follow-up question...',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF707881),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, size: 18, color: Color(0xFF006194)),
                              onPressed: () => _sendMessage(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdditionalMessage(BuildContext context, ConsultationMessageEntity msg) {
    if (msg.isFromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF006194),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, right: 30),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E7FF)),
      ),
      child: Text(
        msg.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF131B2E)),
      ),
    );
  }
}
