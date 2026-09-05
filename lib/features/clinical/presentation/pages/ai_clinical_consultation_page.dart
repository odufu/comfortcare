import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../../core/widgets/cc_button.dart';
import '../../../../core/widgets/cc_chip.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/consultation_message.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_event.dart';
import '../bloc/clinical_state.dart';

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
    context.read<ClinicalBloc>().add(LoadConsultationHistory());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ClinicalBloc>().add(SendConsultationMessage(text));
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ComfortCare AI Doctor'),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live Pharmacist Co-Pilot Active',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Clinical Care Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: colorScheme.surfaceContainerHigh)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CCChip(
                  label: 'PCN Regulated Care',
                  icon: const Icon(Icons.verified_user, size: 12),
                  variant: CCChipVariant.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
                Text(
                  'Abuja Central Dispensary',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 11),
                ),
              ],
            ),
          ),

          // Message Stream
          Expanded(
            child: BlocBuilder<ClinicalBloc, ClinicalState>(
              builder: (context, state) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length + (state.isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length && state.isThinking) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Doctor evaluating symptoms against formulary...',
                                style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final message = state.messages[index];
                    return _buildMessageBubble(context, message);
                  },
                );
              },
            ),
          ),

          // Chat Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              border: Border(top: BorderSide(color: colorScheme.surfaceContainerHigh)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Describe symptoms (e.g. fever, dosage question)...',
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send, size: 18),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ConsultationMessageEntity msg) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    if (msg.isFromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Text(
            msg.text,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.4),
          ),
        ),
      );
    }

    // AI Clinical Response Bubble
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Clinical Diagnostic Assessment',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    if (msg.priority == TriagePriority.high)
                      CCChip(
                        label: 'High Priority',
                        variant: CCChipVariant.tertiary,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  msg.text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                if (msg.clinicalNotes != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: colorScheme.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            msg.clinicalNotes!,
                            style: textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Embedded Interactive Care Regimen Checklist
          if (msg.recommendedProducts != null && msg.recommendedProducts!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
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
                      Text(
                        'AI Clinical Regimen',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      CCChip(
                        label: 'Rx Ready',
                        variant: CCChipVariant.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...msg.recommendedProducts!.map((p) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check_box, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p.brand} • ${p.name}',
                                  style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  p.genericName,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            p.price.toNaira(),
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  CCButton(
                    label: 'Add Regimen to Cart & Review (Step 1 of 4)',
                    height: 42,
                    onPressed: () {
                      for (final prod in msg.recommendedProducts!) {
                        context.read<CartBloc>().add(AddToCart(product: prod));
                      }
                      context.showSnackBar('Clinical regimen added to cart.', isSuccess: true);
                      context.push('/cart');
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
