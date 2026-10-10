import 'package:flutter_test/flutter_test.dart';
import 'package:comfort_care/core/services/nova_express_logistics_service.dart';
import 'package:comfort_care/features/cart/domain/entities/cart_item.dart';
import 'package:comfort_care/features/products/domain/entities/product.dart';
import 'package:comfort_care/features/orders/domain/entities/order.dart';

void main() {
  group('NovaExpress Decentralized Pharmacy Logistics Tests', () {
    const sampleProduct1 = ProductEntity(
      id: 'prod-coartem-80-480',
      name: 'Coartem 80/480mg',
      brand: 'Novartis',
      genericName: 'Artemether / Lumefantrine (6 Tabs)',
      packSize: '6 Tablets Pack',
      price: 3850.0,
      wholesalePrice: 3150.0,
      category: 'Malaria Meds',
      description: 'Complete ACT malaria treatment regimen.',
      dosageInstructions: '1 tablet twice daily for 3 days.',
      activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
      nafdacNumber: 'NAFDAC Reg. A4-0245',
      imageUrl: 'https://example.com/coartem.png',
    );

    const sampleProduct2 = ProductEntity(
      id: 'prod-augmentin-625',
      name: 'Augmentin 625mg',
      brand: 'GSK',
      genericName: 'Amoxicillin / Clavulanate (14 Tabs)',
      packSize: '14 Tablets Pack',
      price: 6500.0,
      wholesalePrice: 5200.0,
      category: 'Antibiotics',
      description: 'Broad-spectrum antibiotic formulation.',
      dosageInstructions: '1 tablet twice daily for 7 days.',
      activeIngredients: 'Amoxicillin 500mg, Clavulanic Acid 125mg',
      nafdacNumber: 'NAFDAC Reg. 04-1299',
      imageUrl: 'https://example.com/augmentin.png',
    );

    test('Single-Pharmacy Pickup calculates standard flat rate (₦3,500)', () {
      final singleCartItem = [
        const CartItemEntity(product: sampleProduct1, quantity: 2),
      ];

      final payload = NovaExpressLogisticsService.buildOrderPayload(
        orderId: 'CC-84920',
        items: singleCartItem,
        totalAmount: 7700.0,
        recipientName: 'Dr. Farouk Al-Mansur',
        recipientPhone: '+234 803 265 1505',
        recipientWhatsapp: '+234 803 265 1505',
        destinationAddress: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
        paymentReceiptRef: 'PAYSTACK-CC-99482',
        paymentGateway: 'Paystack Instant Settlement',
        deliveryInstructions: 'Deliver to Clinic Front Desk, Gate 2',
      );

      // Verify Pricing
      final pricing = payload['logistics_pricing'] as Map<String, dynamic>;
      expect(pricing['base_flat_rate'], equals(3500.0));
      expect(pricing['additional_pickup_fee'], equals(0.0));
      expect(pricing['pickup_count'], equals(1));
      expect(pricing['total_fee'], equals(3500.0));

      // Verify 1 Pickup Stop
      final pickupStops = payload['pickup_stops'] as List;
      expect(pickupStops.length, equals(1));
      final stop1 = pickupStops.first as Map<String, dynamic>;
      expect(stop1['pharmacy_name'], contains('MedPlus Pharmacy'));
      expect(stop1['contact_phone'], isNotEmpty);
      expect(stop1['contact_whatsapp'], isNotEmpty);

      // Verify Receiver fields
      final receiver = payload['receiver'] as Map<String, dynamic>;
      expect(receiver['name'], equals('Dr. Farouk Al-Mansur'));
      expect(receiver['whatsapp_number'], equals('+234 803 265 1505'));
    });

    test('Multi-Pharmacy Pickup (2 stops) applies additional pickup fee (₦3,500 + ₦1,500 = ₦5,000)', () {
      final multiCartItems = [
        const CartItemEntity(product: sampleProduct1, quantity: 2),
        const CartItemEntity(product: sampleProduct2, quantity: 1),
      ];

      final payload = NovaExpressLogisticsService.buildOrderPayload(
        orderId: 'CC-99014',
        items: multiCartItems,
        totalAmount: 14200.0,
        recipientName: 'Amina Bello',
        recipientPhone: '+234 802 345 6789',
        recipientWhatsapp: '+234 802 345 6789',
        destinationAddress: 'Maitama, Abuja',
      );

      // Verify Multi-Pickup Pricing Breakdown
      final pricing = payload['logistics_pricing'] as Map<String, dynamic>;
      expect(pricing['base_flat_rate'], equals(3500.0));
      expect(pricing['additional_pickup_fee'], equals(1500.0));
      expect(pricing['pickup_count'], equals(2));
      expect(pricing['total_fee'], equals(5000.0));

      // Verify 2 Distinct Pharmacy Pickup Stops in Payload
      final pickupStops = payload['pickup_stops'] as List;
      expect(pickupStops.length, equals(2));

      final stopA = pickupStops[0] as Map<String, dynamic>;
      expect(stopA['pharmacy_name'], contains('MedPlus'));
      expect(stopA['sealed_bag_ref'], equals('BAG-CC-99014-A'));

      final stopB = pickupStops[1] as Map<String, dynamic>;
      expect(stopB['pharmacy_name'], contains('H-Medix'));
      expect(stopB['sealed_bag_ref'], equals('BAG-CC-99014-B'));

      // Verify Total Payment Receipt matches
      final receipt = payload['payment_receipt'] as Map<String, dynamic>;
      expect(receipt['total_logistics_fee'], equals(5000.0));
      expect(receipt['amount_paid'], equals(14200.0 + 5000.0));
    });

    test('submitOrderToNovaExpress returns multi-stop tracking and fee confirmation', () async {
      final multiCartItems = [
        const CartItemEntity(product: sampleProduct1, quantity: 2),
        const CartItemEntity(product: sampleProduct2, quantity: 1),
      ];

      final order = OrderEntity(
        id: 'CC-9011',
        items: multiCartItems,
        totalAmount: 14200.0,
        destinationAddress: 'Wuse 2, Abuja',
        recipientName: 'Amina Bello',
        recipientPhone: '+234 802 345 6789',
        recipientWhatsapp: '+234 802 345 6789',
        paymentReceipt: 'CC-PAYSTACK-9011',
        dispatchSpeed: DispatchSpeed.express,
        createdAt: DateTime.now(),
      );

      final result = await NovaExpressLogisticsService.submitOrderToNovaExpress(
        order: order,
        paymentReceiptRef: 'CC-PAYSTACK-9011',
      );

      expect(result.success, isTrue);
      expect(result.pickupStopsCount, equals(2));
      expect(result.additionalPickupFee, equals(1500.0));
      expect(result.flatDeliveryFee, equals(5000.0));
      expect(result.trackingNumber, startsWith('NOV-2026-'));
    });
  });
}
