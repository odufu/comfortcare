import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comfort_care/core/extensions/currency_extensions.dart';
import 'package:comfort_care/core/utils/validators.dart';
import 'package:comfort_care/core/theme/bloc/theme_bloc.dart';
import 'package:comfort_care/core/theme/bloc/theme_event.dart';
import 'package:comfort_care/core/theme/bloc/theme_state.dart';
import 'package:comfort_care/core/storage/local_storage_service.dart';
import 'package:comfort_care/features/products/domain/entities/product.dart';
import 'package:comfort_care/features/products/presentation/widgets/product_card.dart';
import 'package:comfort_care/features/cart/domain/entities/cart_item.dart';
import 'package:comfort_care/features/cart/domain/repositories/cart_repository.dart';
import 'package:comfort_care/features/cart/domain/usecases/manage_cart.dart';
import 'package:comfort_care/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:comfort_care/features/orders/domain/entities/order.dart';
import 'package:comfort_care/core/widgets/cc_floating_ai_doctor_button.dart';
import 'package:comfort_care/core/widgets/cc_bottom_nav_bar.dart';
import 'package:comfort_care/core/widgets/cc_app_bar.dart';
import 'package:comfort_care/features/clinical/presentation/widgets/ai_clinical_regimen_card.dart';
import 'package:comfort_care/features/clinical/presentation/pages/ai_clinical_consultation_page.dart';
import 'package:comfort_care/features/dashboard/presentation/widgets/quick_actions_grid.dart';
import 'package:comfort_care/features/dashboard/presentation/widgets/fast_moving_essentials_section.dart';
import 'package:comfort_care/core/widgets/cc_side_nav.dart';
import 'package:comfort_care/features/auth/presentation/pages/login_page.dart';
import 'package:comfort_care/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:comfort_care/features/auth/domain/repositories/auth_repository.dart';
import 'package:comfort_care/features/auth/domain/usecases/login.dart';
import 'package:comfort_care/features/auth/domain/usecases/logout.dart';
import 'package:comfort_care/features/auth/domain/usecases/get_current_user.dart';
import 'package:comfort_care/features/auth/domain/entities/user.dart';
import 'package:comfort_care/features/clinical/presentation/pages/health_vitals_monitor_page.dart';
import 'package:comfort_care/features/clinical/presentation/bloc/clinical_bloc.dart';
import 'package:comfort_care/features/clinical/domain/repositories/clinical_repository.dart';
import 'package:comfort_care/features/clinical/domain/usecases/manage_clinical.dart';
import 'package:comfort_care/features/clinical/domain/entities/health_vitals.dart';
import 'package:comfort_care/features/clinical/domain/entities/consultation_message.dart';
import 'package:comfort_care/features/cart/presentation/pages/cart_prescription_review_page.dart';
import 'package:comfort_care/features/cart/presentation/bloc/cart_event.dart';

class FakeAuthRepository implements AuthRepository {
  UserEntity? currentUser;

  @override
  Future<UserEntity?> getCurrentUser() async => currentUser;

  @override
  Future<UserEntity> login({required String emailOrPhone, required String password, required UserRole role}) async {
    return UserEntity(
      id: 'test-user-1',
      email: emailOrPhone,
      fullName: 'Test User',
      phoneNumber: '08012345678',
      role: role,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
    String? facilityName,
    String? licenseNumber,
  }) async {
    return UserEntity(id: 'test-user-2', email: email, fullName: fullName, phoneNumber: phoneNumber, role: role);
  }

  @override
  Future<void> sendPasswordReset(String emailOrPhone) async {}
}

class FakeClinicalRepository implements ClinicalRepository {
  HealthVitalsEntity vitals = HealthVitalsEntity(
    systolic: 120,
    diastolic: 80,
    heartRate: 72,
    bloodGlucose: 95.0,
    temperature: 36.7,
    loggedAt: DateTime.now(),
  );

  @override
  Future<List<ConsultationMessageEntity>> getConsultationHistory() async => [
        ConsultationMessageEntity(
          id: 'msg-01',
          text: "Good afternoon. I've had intense headache and fever of 38.6°C.",
          isFromUser: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ConsultationMessageEntity(
          id: 'msg-02',
          text: "Hello, based on your symptoms this indicates acute uncomplicated malaria.",
          isFromUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          priority: TriagePriority.high,
          clinicalNotes: 'Reviewed against PCN malaria management guidelines.',
          vitalsSnapshot: vitals,
          recommendedProducts: const [
            ProductEntity(
              id: 'prod-coartem-80-480',
              name: 'Coartem 80/480mg',
              brand: 'Novartis',
              genericName: 'Artemether 80mg + Lumefantrine 480mg',
              category: 'Antimalarial',
              packSize: '6 Tablets',
              price: 4200.0,
              wholesalePrice: 3900.0,
              description: 'Antimalarial ACT therapy',
              dosageInstructions: '1 tablet with fatty food',
              activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
              nafdacNumber: '04-2011',
              imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
              requiresPrescription: true,
            ),
          ],
        ),
      ];

  @override
  Future<HealthVitalsEntity> getLatestVitals() async => vitals;

  @override
  Future<void> logVitals(HealthVitalsEntity v) async {
    vitals = v;
  }

  @override
  Future<ConsultationMessageEntity> sendMessage(String text) async {
    return ConsultationMessageEntity(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: 'Response to: $text',
      isFromUser: false,
      timestamp: DateTime.now(),
      priority: TriagePriority.normal,
      vitalsSnapshot: vitals,
      recommendedProducts: const [
        ProductEntity(
          id: 'prod-coartem-80-480',
          name: 'Coartem 80/480mg',
          brand: 'Novartis',
          genericName: 'Artemether 80mg + Lumefantrine 480mg',
          category: 'Antimalarial',
          packSize: '6 Tablets',
          price: 4200.0,
          wholesalePrice: 3900.0,
          description: 'Antimalarial ACT therapy',
          dosageInstructions: '1 tablet with fatty food',
          activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
          nafdacNumber: '04-2011',
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
          requiresPrescription: true,
        ),
      ],
      clinicalNotes: 'Verified under PCN guidelines.',
    );
  }
}

class FakeCartRepository implements CartRepository {
  final List<CartItemEntity> items = [];

  @override
  Future<List<CartItemEntity>> getCartItems() async => items;

  @override
  Future<void> addToCart(ProductEntity product, int quantity) async {
    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + quantity);
    } else {
      items.add(CartItemEntity(product: product, quantity: quantity));
    }
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx != -1) {
      if (quantity <= 0) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: quantity);
      }
    }
  }

  @override
  Future<void> removeFromCart(String productId) async {
    items.removeWhere((i) => i.product.id == productId);
  }

  @override
  Future<void> attachPrescription(String productId) async {}

  @override
  Future<void> clearCart() async {
    items.clear();
  }
}

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
      expect(3850.0.toNaira(), '₦3,850');
      expect(3850.0.toNaira(showDecimals: true), '₦3,850.00');
      expect(0.0.toNaira(), '₦0');
      expect(1250000.0.toNaira(), '₦1,250,000');
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

    test('ThemeState isDark detects platform brightness when on ThemeMode.system', () {
      const systemState = ThemeState(themeMode: ThemeMode.system);
      expect(systemState.isDark(Brightness.dark), isTrue);
      expect(systemState.isDark(Brightness.light), isFalse);

      const explicitDark = ThemeState(themeMode: ThemeMode.dark);
      expect(explicitDark.isDark(Brightness.light), isTrue);

      const explicitLight = ThemeState(themeMode: ThemeMode.light);
      expect(explicitLight.isDark(Brightness.dark), isFalse);
    });

    test('ThemeBloc toggles from system dark directly to light mode on first toggle', () async {
      final storage = FakeLocalStorageService();
      final bloc = ThemeBloc(storageService: storage);
      expect(bloc.state.themeMode, ThemeMode.system);

      // When currently visually in dark mode, first toggle should switch directly to light mode
      bloc.add(const ToggleThemeMode(isCurrentDark: true));
      await expectLater(
        bloc.stream,
        emits(predicate<ThemeState>((s) => s.themeMode == ThemeMode.light)),
      );

      await bloc.close();
    });
  });

  group('AI Clinical Consultation & FAB Tests', () {
    testWidgets('CCFloatingAiDoctorButton renders properly with live badge', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: CCFloatingAiDoctorButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('AI Doctor'), findsOneWidget);
      expect(find.text('Live Co-Pilot'), findsOneWidget);
      expect(find.text('PCN'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);

      await tester.tap(find.text('AI Doctor'));
      expect(pressed, isTrue);
    });

    testWidgets('AiClinicalRegimenCard renders exact items, tags, and recalculates on toggle', (tester) async {
      int reportedCount = 0;
      double reportedTotal = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AiClinicalRegimenCard(
                onTotalsChanged: (count, total, original, savings, ids) {
                  reportedCount = count;
                  reportedTotal = total;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header & Badge
      expect(find.text('Recommended Drugs'), findsOneWidget);
      expect(find.text('Rx Ready'), findsOneWidget);
      expect(find.text('Tap any medication to view full clinical details'), findsOneWidget);

      // Verify 4 items
      expect(find.text('Coartem 80/480mg'), findsOneWidget);
      expect(find.text('Emzor Paraceta...'), findsOneWidget);
      expect(find.text('CareStart Mala...'), findsOneWidget);
      expect(find.text('ORS Hydration ...'), findsOneWidget);

      // Verify Tags
      expect(find.text('1st Line Malaria Therapy'), findsOneWidget);
      expect(find.text('Fast Dissolve'), findsOneWidget);
      expect(find.text('15-Min Results'), findsOneWidget);
      expect(find.text('Optional Add-on'), findsOneWidget);

      // Verify Tail-end Action Buttons with 3 items selected by default (Total ₦7,200)
      expect(find.text('Add Selected (3) • ₦7,200'), findsOneWidget);
      expect(find.text('Add All'), findsOneWidget);
      expect(reportedCount, 3);
      expect(reportedTotal, 7200.0);
    });
  });

  group('Medicines & Products Catalog Redesign Tests', () {
    const coartemProduct = ProductEntity(
      id: 'prod-coartem-80-480',
      name: 'Coartem 80/480mg',
      brand: 'Novartis',
      genericName: 'Artemether & Lumefantrine (6 Tablets)',
      packSize: '6 Tablets Blister Pack',
      price: 4200.0,
      wholesalePrice: 3833.33,
      category: 'Antimalarials',
      description: 'First line malaria treatment.',
      dosageInstructions: 'Take 1 tablet twice daily for 3 days.',
      activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
      nafdacNumber: 'NAFDAC 04-2051',
      badge1: '20m Express',
      badge1Icon: 'timer',
      badge2: 'NAFDAC 04-2051',
      badge2Icon: 'verified',
      packLabel: 'Retail Pack',
      cartonText: 'Carton (30): ₦115,000',
      isCartonHighlight: true,
      stock: 140,
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
    );

    testWidgets('ProductCard renders exact typography, badges, pack label, and carton note', (tester) async {
      final fakeRepo = FakeCartRepository();
      final cartBloc = CartBloc(manageCartUseCase: ManageCartUseCase(fakeRepo));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CartBloc>.value(
              value: cartBloc,
              child: const SizedBox(
                width: 200,
                height: 280,
                child: ProductCard(
                  product: coartemProduct,
                  isWholesale: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Category Tag
      expect(find.text('Antimalarial'), findsOneWidget);

      // Verify Name & Subtitle
      expect(find.text('Coartem 80/480mg'), findsOneWidget);
      expect(find.text('Artemether & Lumefantrine (6 Tablets)'), findsOneWidget);

      // Verify Badges
      expect(find.text('20m Express'), findsOneWidget);
      expect(find.text('NAFDAC 04-2051'), findsOneWidget);

      // Verify Pricing
      expect(find.text('₦4,200'), findsOneWidget);

      // Verify Circular Add Button initially
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap Add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify stepper is now visible with quantity 1
      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('Core Bottom Navigation Restructuring Tests', () {
    testWidgets('CCBottomNavBar renders exact 5 core anchors: Home, Pharmacy, Orders, Profile, Health Vitals', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CCBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify all 5 core anchors exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Pharmacy'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Health Vitals'), findsOneWidget);

      // Verify Icons
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.local_pharmacy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);

      // Tap Pharmacy tab (index 1)
      await tester.tap(find.text('Pharmacy'));
      await tester.pump();
      expect(tappedIndex, 1);

      // Tap Orders tab (index 2)
      await tester.tap(find.text('Orders'));
      await tester.pump();
      expect(tappedIndex, 2);

      // Tap Profile tab (index 3)
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(tappedIndex, 3);

      // Tap Health Vitals tab (index 4)
      await tester.tap(find.text('Health Vitals'));
      await tester.pump();
      expect(tappedIndex, 4);
    });
  });

  group('Home Page Redesign Tests', () {
    testWidgets('CCAppBar renders brand logo, deliver-to location, notifications, cart, and profile avatar', (tester) async {
      bool profileTapped = false;
      bool notificationsTapped = false;
      bool locationTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CCAppBar(
              showBrandLogo: true,
              showLocationSelector: true,
              showProfileAvatar: true,
              selectedLocation: 'Comfort Mall, Life Camp, Abuja',
              cartItemCount: 2,
              onLocationTap: () => locationTapped = true,
              onNotificationsTap: () => notificationsTapped = true,
              onProfileTap: () => profileTapped = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Location selector
      expect(find.text('DELIVER TO'), findsOneWidget);
      expect(find.text('Comfort Mall, Life Camp, Abuja'), findsOneWidget);

      // Verify Cart count badge
      expect(find.text('2'), findsOneWidget);

      // Verify Notification Icon
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // Tap Notification
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      expect(notificationsTapped, isTrue);

      // Tap Location
      await tester.tap(find.text('Comfort Mall, Life Camp, Abuja'));
      expect(locationTapped, isTrue);

      // Tap Profile Avatar
      await tester.tap(find.byType(ClipOval).last);
      expect(profileTapped, isTrue);
    });

    testWidgets('QuickActionsGrid renders 4 tactile quick action cards', (tester) async {
      bool uploadTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuickActionsGrid(
                onUploadPrescriptionTap: () => uploadTapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify all 4 action cards
      expect(find.text('Upload Rx'), findsOneWidget);
      expect(find.text('15-Min Pharmacist Verify'), findsOneWidget);
      expect(find.text('Instant'), findsOneWidget);

      expect(find.text('AI Doctor'), findsOneWidget);
      expect(find.text('Instant Clinical Triage'), findsOneWidget);
      expect(find.text('24/7 Live'), findsOneWidget);

      expect(find.text('Track Orders'), findsOneWidget);
      expect(find.text('Live Abuja Courier'), findsOneWidget);
      expect(find.text('20-35m'), findsOneWidget);

      expect(find.text('Health Vitals'), findsOneWidget);
      expect(find.text('BP, Glucose & Heart Rate'), findsOneWidget);
      expect(find.text('Monitor'), findsOneWidget);

      // Tap Upload Rx
      await tester.tap(find.text('Upload Rx'));
      await tester.pump();
      expect(uploadTapped, isTrue);
    });

    testWidgets('FastMovingEssentialsSection renders exact 4 products and adds to cart on + tap', (tester) async {
      final fakeRepo = FakeCartRepository();
      final cartBloc = CartBloc(manageCartUseCase: ManageCartUseCase(fakeRepo));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CartBloc>.value(
              value: cartBloc,
              child: const SingleChildScrollView(
                child: FastMovingEssentialsSection(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Header
      expect(find.text('Fast-Moving Essentials'), findsOneWidget);
      expect(find.text('Verified authentic with batch tracking'), findsOneWidget);
      expect(find.text('View More'), findsOneWidget);

      // Verify Products
      expect(find.text('Coartem 80/480mg'), findsOneWidget);
      expect(find.text('Omron M2 Basic BP'), findsOneWidget);
      expect(find.text('Amoxil 500mg'), findsOneWidget);
      expect(find.text('Latex Gloves (100s)'), findsOneWidget);

      // Verify Badges
      expect(find.text('In Stock'), findsOneWidget);
      expect(find.text('NAFDAC: 04-2011'), findsOneWidget);
      expect(find.text('Device'), findsOneWidget);
      expect(find.text('3yr Warranty'), findsOneWidget);
      expect(find.text('Rx Required'), findsOneWidget);
      expect(find.text('Wholesale Avail'), findsOneWidget);
      expect(find.text('Bulk Deal'), findsOneWidget);
      expect(find.text('Clinic Grade'), findsOneWidget);

      // Verify Prices
      expect(find.text('₦4,200'), findsOneWidget);
      expect(find.text('₦38,500'), findsOneWidget);
      expect(find.text('₦3,600'), findsOneWidget);
      expect(find.text('₦6,500'), findsOneWidget);

      // Tap the first circular "+" button (Coartem)
      final plusButtons = find.byIcon(Icons.add);
      expect(plusButtons, findsWidgets);
      await tester.tap(plusButtons.first);
      await tester.pump();

      // Verify item was added to CartBloc
      expect(cartBloc.state.totalItems, 1);
      expect(cartBloc.state.items.first.product.name, 'Coartem 80/480mg');
    });
  });

  group('Desktop Collapsible Side Navigation Tests', () {
    testWidgets('CCSideNav renders all 5 anchors, brand lockup, AI Doctor card, and collapses on toggle', (tester) async {
      int tappedIndex = -1;
      bool aiDoctorTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc(storageService: FakeLocalStorageService()),
            child: Scaffold(
              body: CCSideNav(
                currentIndex: 0,
                onTap: (index) => tappedIndex = index,
                onAiDoctorTap: () => aiDoctorTapped = true,
                initialCollapsed: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Brand Lockup
      expect(find.text('ComfortCare'), findsOneWidget);
      expect(find.text('Abuja Health Hub'), findsOneWidget);

      // Verify all 5 core navigation anchors exist in expanded state
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Pharmacy'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Health Vitals'), findsOneWidget);

      // Verify AI Doctor Co-Pilot Card
      expect(find.text('AI Doctor Co-Pilot'), findsOneWidget);
      expect(find.text('Consult Now →'), findsOneWidget);

      // Tap Pharmacy (index 1)
      await tester.tap(find.text('Pharmacy'));
      await tester.pump();
      expect(tappedIndex, 1);

      // Tap Health Vitals (index 4)
      await tester.tap(find.text('Health Vitals'));
      await tester.pump();
      expect(tappedIndex, 4);

      // Tap AI Doctor CTA
      await tester.tap(find.text('Consult Now →'));
      await tester.pump();
      expect(aiDoctorTapped, isTrue);

      // Tap Collapse Button
      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify sidebar is now collapsed with expand button visible
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.text('ComfortCare'), findsNothing);

      // Tap Expand Button
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ComfortCare'), findsOneWidget);
      expect(find.text('Health Vitals'), findsOneWidget);
    });
  });

  group('Login Screen & Dual-Pane Layout Tests', () {
    testWidgets('LoginPage renders role selector, demo pills, biometric trigger, and signs in', (tester) async {
      final fakeAuthRepo = FakeAuthRepository();
      final authBloc = AuthBloc(
        loginUseCase: LoginUseCase(fakeAuthRepo),
        logoutUseCase: LogoutUseCase(fakeAuthRepo),
        getCurrentUserUseCase: GetCurrentUserUseCase(fakeAuthRepo),
        authRepository: fakeAuthRepo,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => authBloc,
            child: const Scaffold(
              body: LoginPage(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify regulatory badges & titles
      expect(find.text('Sign In to Dispensary Hub'), findsOneWidget);
      expect(find.text('Individual / Patient'), findsOneWidget);
      expect(find.text('Clinic / Wholesale'), findsWidgets);

      // Verify quick demo pills
      expect(find.text('Quick Demo Logins:'), findsOneWidget);
      expect(find.text('Patient'), findsOneWidget);
      expect(find.text('Pharmacist'), findsOneWidget);

      // Verify Biometric button
      expect(find.text('Fast Biometric Sign In'), findsOneWidget);

      // Tap Clinic / Wholesale demo pill
      await tester.tap(find.text('Pharmacist'));
      await tester.pump();

      expect(authBloc.state.selectedRole, UserRole.pharmacist);
    });
  });

  group('Health Vitals Monitor & Medical Charts Tests', () {
    testWidgets('HealthVitalsMonitorPage renders telemetry timeline, 4 stat cards, BP trend, and ECG wave', (tester) async {
      final fakeClinicalRepo = FakeClinicalRepository();
      final clinicalBloc = ClinicalBloc(
        manageClinicalUseCase: ManageClinicalUseCase(fakeClinicalRepo),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ClinicalBloc>(
            create: (_) => clinicalBloc,
            child: const HealthVitalsMonitorPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify telemetry header & timeframe pills
      expect(find.text('Health Vitals Telemetry'), findsOneWidget);
      expect(find.text('Telemetry Timeline'), findsOneWidget);
      expect(find.text('24 Hours'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);
      expect(find.text('30 Days'), findsOneWidget);

      // Verify 4 vitals stat metric cards
      expect(find.text('BLOOD PRESSURE'), findsOneWidget);
      expect(find.text('FASTING GLUCOSE'), findsOneWidget);
      expect(find.text('HEART RATE'), findsWidgets);
      expect(find.text('BODY TEMP'), findsOneWidget);

      // Verify medical chart cards
      expect(find.text('Blood Pressure 7-Day Trend'), findsOneWidget);
      expect(find.text('Live ECG Telemetry Waveform'), findsOneWidget);
      expect(find.text('24-Hour Blood Glucose Profile'), findsOneWidget);
      expect(find.text('Weekly Medication Adherence'), findsOneWidget);

      // Verify prescription schedule reminders
      expect(find.text('Prescription Adherence Schedule'), findsOneWidget);
      expect(find.text('Coartem 80/480mg'), findsOneWidget);
    });
  });

  group('Cart & Prescription Review Screen Tests', () {
    testWidgets('CartPrescriptionReviewPage renders Step 1 tracker, Cold-Chain badge, Rx dossier, and summary', (tester) async {
      final fakeCartRepo = FakeCartRepository();
      final cartBloc = CartBloc(manageCartUseCase: ManageCartUseCase(fakeCartRepo));

      // Add a test medication to cart
      cartBloc.add(
        const AddToCart(
          product: ProductEntity(
            id: 'prod-coartem',
            name: 'Coartem 80/480mg',
            brand: 'Novartis',
            genericName: 'Artemether / Lumefantrine',
            category: 'Antimalarial',
            packSize: '6 Tablets',
            price: 4200.0,
            wholesalePrice: 3900.0,
            description: 'Antimalarial ACT therapy',
            dosageInstructions: '1 tablet with fatty food',
            activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
            nafdacNumber: '04-2011',
            imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
            requiresPrescription: true,
          ),
          quantity: 2,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartBloc>(
            create: (_) => cartBloc,
            child: const CartPrescriptionReviewPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Step 1 progress bar
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Order & Rx Review'), findsOneWidget);

      // Verify Cold Chain assurance banner
      expect(find.text('NAFDAC & Cold-Chain Monitored'), findsOneWidget);
      expect(find.text('2°C - 8°C Verified'), findsOneWidget);

      // Verify prescription review
      expect(find.text('Medications Review'), findsOneWidget);
      expect(find.text('Coartem 80/480mg'), findsOneWidget);

      // Verify Order summary and Dispatch methods
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Standard Dispatch'), findsOneWidget);
      expect(find.text('Priority Cold-Chain Express'), findsOneWidget);
      expect(find.text('Proceed to Delivery Dispatch (Step 2 of 4)'), findsOneWidget);
    });
  });

  group('AI Clinical Consultation Chat & Desktop Telehealth Tests', () {
    testWidgets('AiClinicalConsultationPage desktop layout constraints width to max 840px', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final clinicalRepository = FakeClinicalRepository();
      final manageClinicalUseCase = ManageClinicalUseCase(clinicalRepository);
      final clinicalBloc = ClinicalBloc(manageClinicalUseCase: manageClinicalUseCase);
      final cartRepository = FakeCartRepository();
      final manageCartUseCase = ManageCartUseCase(cartRepository);
      final cartBloc = CartBloc(manageCartUseCase: manageCartUseCase);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ClinicalBloc>.value(value: clinicalBloc),
              BlocProvider<CartBloc>.value(value: cartBloc),
            ],
            child: const AiClinicalConsultationPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify centered container is constrained to maxWidth: 840
      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.constraints != null) {
          return widget.constraints!.maxWidth == 840.0;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);

      // Verify header branding and PCN badge
      expect(find.text('ComfortCare AI Doctor'), findsOneWidget);
      expect(find.text('PCN Regulated'), findsOneWidget);
      expect(find.text('Live Pharmacist Co-Pilot Active'), findsOneWidget);
    });

    testWidgets('Sending a message simulates doctor reply with health stats and prescriptions', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final clinicalRepository = FakeClinicalRepository();
      final manageClinicalUseCase = ManageClinicalUseCase(clinicalRepository);
      final clinicalBloc = ClinicalBloc(manageClinicalUseCase: manageClinicalUseCase);
      final cartRepository = FakeCartRepository();
      final manageCartUseCase = ManageCartUseCase(cartRepository);
      final cartBloc = CartBloc(manageCartUseCase: manageCartUseCase);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ClinicalBloc>.value(value: clinicalBloc),
              BlocProvider<CartBloc>.value(value: cartBloc),
            ],
            child: const AiClinicalConsultationPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify initial message history loaded
      expect(find.text("Good afternoon. I've had intense headache and fever of 38.6°C."), findsOneWidget);
      expect(find.text('Patient Biometric Telemetry'), findsOneWidget);
      expect(find.text('120/80'), findsOneWidget); // Blood pressure reading
      expect(find.text('Recommended Drugs'), findsOneWidget); // Prescriptions

      // Send message via quick action chip
      final chipFinder = find.text('Ask about food interactions');
      await tester.ensureVisible(chipFinder);
      await tester.pumpAndSettle();
      await tester.tap(chipFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // User message is rendered in the chat (found in user message bubble and in chip list)
      expect(find.text('Ask about food interactions'), findsNWidgets(2));

      // Settle async thinking simulation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify simulated reply arrived
      expect(find.text('Response to: Ask about food interactions'), findsOneWidget);

      // Verify Health Vitals are represented in the conversation
      expect(find.text('Patient Biometric Telemetry'), findsWidgets);
      expect(find.text('View 7-Day Trend Telemetry & ECG Waveforms'), findsWidgets);

      // Verify Prescriptions Regimen is represented in the conversation
      expect(find.text('Recommended Drugs'), findsWidgets);
      expect(find.text('Coartem 80/480mg'), findsWidgets);
    });
  });
}

