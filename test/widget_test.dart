import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comfort_care/core/extensions/currency_extensions.dart';
import 'package:comfort_care/core/utils/validators.dart';
import 'package:comfort_care/core/theme/bloc/theme_bloc.dart';
import 'package:comfort_care/core/theme/bloc/theme_event.dart';
import 'package:comfort_care/core/theme/bloc/theme_state.dart';
import 'package:comfort_care/core/storage/local_storage_service.dart';
import 'package:comfort_care/features/products/domain/entities/product.dart';
import 'package:comfort_care/features/cart/domain/entities/cart_item.dart';
import 'package:comfort_care/features/orders/domain/entities/order.dart';

class FakeLocalStorageService implements LocalStorageService {
  String? themeMode;

  @override
  String? getThemeMode() => themeMode;

  @override
  Future<bool> saveThemeMode(String mode) async {
    themeMode = mode;
    return true;
  }

  @override
  Future<bool> clearAll() async => true;
  @override
  String? getCartJson() => null;
  @override
  String? getRole() => null;
  @override
  String? getToken() => null;
  @override
  String? getUserJson() => null;
  @override
  bool isOnboardingCompleted() => true;
  @override
  Future<bool> removeToken() async => true;
  @override
  Future<bool> removeUserJson() async => true;
  @override
  Future<bool> saveCartJson(String cartJson) async => true;
  @override
  Future<bool> saveRole(String role) async => true;
  @override
  Future<bool> saveToken(String token) async => true;
  @override
  Future<bool> saveUserJson(String userJson) async => true;
  @override
  Future<bool> setOnboardingCompleted() async => true;
}

void main() {
  group('ComfortCare Core Utilities & Formatting Tests', () {
    test('Currency formatters output Nigerian Naira (₦) correctly', () {
      expect(3850.0.toNaira(), '₦3,850.00');
      expect(0.0.toNaira(), '₦0.00');
      expect(1250000.5.toNaira(), '₦1,250,000.50');
    });

    test('Nigerian Phone Validator accepts valid formats', () {
      expect(Validators.validatePhone('+2348032651505'), isNull);
      expect(Validators.validatePhone('08032651505'), isNull);
      expect(Validators.validatePhone('07012345678'), isNull);
      expect(Validators.validatePhone('12345'), isNotNull);
      expect(Validators.validatePhone(''), isNotNull);
    });

    test('Email Validator verifies correct email format', () {
      expect(Validators.validateEmail('doctor@clinic.ng'), isNull);
      expect(Validators.validateEmail('info@comfortcare.ng'), isNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
    });
  });

  group('ComfortCare Domain Entities & Business Logic', () {
    const testProduct = ProductEntity(
      id: 'prod-coartem-80-480',
      name: 'Coartem 80/480mg',
      brand: 'Novartis',
      genericName: 'Artemether / Lumefantrine (6 Tabs)',
      packSize: '6 Tablets Pack',
      price: 3850.0,
      wholesalePrice: 3150.0,
      category: 'Prescription Drugs',
      description: 'First-line artemisinin-based combination therapy.',
      dosageInstructions: '1 tablet morning and evening with meals for 3 days.',
      activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
      nafdacNumber: 'NAFDAC Reg No: 04-0987',
      requiresPrescription: true,
      isColdChain: false,
      stock: 450,
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
    );

    test('CartItemEntity calculates total retail and wholesale prices correctly', () {
      const cartItem = CartItemEntity(
        product: testProduct,
        quantity: 3,
        isPrescriptionAttached: true,
      );

      expect(cartItem.totalPrice, 3850.0 * 3);
      expect(cartItem.totalWholesalePrice, 3150.0 * 3);
      expect(cartItem.isPrescriptionAttached, isTrue);
    });

    test('OrderEntity model attributes adhere to PRD specification', () {
      final now = DateTime.now();
      final order = OrderEntity(
        id: 'CC-84920',
        items: const [
          CartItemEntity(product: testProduct, quantity: 2),
        ],
        totalAmount: 7700.0,
        destinationAddress: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
        recipientName: 'Dr. Farouk Al-Mansur',
        recipientPhone: '+234 803 265 1505',
        dispatchSpeed: DispatchSpeed.express,
        status: OrderStatus.inTransit,
        riderName: 'Rider Ibrahim',
        riderPhone: '+234 812 345 6789',
        coldChainTemp: 'Cold-Chain 3.8°C Normal',
        createdAt: now,
      );

      expect(order.id, 'CC-84920');
      expect(order.status, OrderStatus.inTransit);
      expect(order.dispatchSpeed, DispatchSpeed.express);
      expect(order.coldChainTemp, contains('3.8°C'));
    });
  });

  group('ComfortCare ThemeBloc State Transitions', () {
    test('ThemeBloc toggles between light and dark mode properly', () async {
      final storage = FakeLocalStorageService();
      final bloc = ThemeBloc(storageService: storage);
      expect(bloc.state.themeMode, ThemeMode.system);

      bloc.add(ToggleThemeMode());
      await expectLater(
        bloc.stream,
        emits(predicate<ThemeState>((s) => s.themeMode == ThemeMode.dark)),
      );

      bloc.add(ToggleThemeMode());
      await expectLater(
        bloc.stream,
        emits(predicate<ThemeState>((s) => s.themeMode == ThemeMode.light)),
      );

      bloc.add(const ChangeThemeMode(ThemeMode.dark));
      await expectLater(
        bloc.stream,
        emits(predicate<ThemeState>((s) => s.themeMode == ThemeMode.dark)),
      );

      await bloc.close();
    });
  });
}
