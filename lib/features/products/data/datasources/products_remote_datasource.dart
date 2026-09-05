import '../../../../core/services/supabase_service.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  });

  Future<ProductModel?> getProductById(String id);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  static const List<ProductModel> _mockProducts = [
    ProductModel(
      id: 'prod-coartem-80-480',
      name: 'Coartem 80/480mg',
      brand: 'Novartis Pharma AG',
      genericName: 'Artemether 80mg + Lumefantrine 480mg',
      packSize: '6 Tablets Blister Pack',
      price: 3850.0,
      wholesalePrice: 3150.0,
      category: 'Malaria Meds',
      description:
          'Coartem is a fixed-dose artemisinin-based combination therapy (ACT) indicated for the clinical treatment of acute uncomplicated Plasmodium falciparum malaria infections.',
      dosageInstructions:
          'Take 1 tablet twice daily with fatty food or milk for 3 consecutive days (total of 6 tablets). Complete full course.',
      activeIngredients: 'Artemether (80 mg), Lumefantrine (480 mg)',
      nafdacNumber: 'NAFDAC Reg. No. A4-0245',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 30°C in dry conditions',
      stock: 140,
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
    ),
    ProductModel(
      id: 'prod-augmentin-625',
      name: 'Augmentin 625mg',
      brand: 'GlaxoSmithKline (GSK)',
      genericName: 'Amoxicillin + Clavulanate Potassium',
      packSize: '14 Film-Coated Tablets',
      price: 7500.0,
      wholesalePrice: 6200.0,
      category: 'Antibiotics',
      description:
          'Broad spectrum antibacterial therapy for respiratory tract, urinary tract, and soft tissue bacterial infections.',
      dosageInstructions:
          'Take 1 tablet every 12 hours at the start of a meal as directed by your physician.',
      activeIngredients: 'Amoxicillin Trihydrate (500 mg), Potassium Clavulanate (125 mg)',
      nafdacNumber: 'NAFDAC Reg. No. 04-2194',
      requiresPrescription: true,
      isColdChain: false,
      storageTemp: 'Store below 25°C in moisture-proof foil',
      stock: 85,
      imageUrl:
          'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
    ),
    ProductModel(
      id: 'prod-mixtard-insulin',
      name: 'Mixtard 30/70 Insulin 100 IU/ml',
      brand: 'Novo Nordisk',
      genericName: 'Biphasic Isophane Human Insulin',
      packSize: '10 ml Injectable Vial',
      price: 14200.0,
      wholesalePrice: 12100.0,
      category: 'Cold Chain Insulin',
      description:
          'Premixed human insulin for diabetes mellitus glycemic control. Strictly transported under certified cold-chain protocol.',
      dosageInstructions:
          'Administer subcutaneously 30 minutes before meal according to individual endocrinologist prescription.',
      activeIngredients: '30% Soluble Insulin, 70% Isophane Insulin',
      nafdacNumber: 'NAFDAC Reg. No. 04-8910',
      requiresPrescription: true,
      isColdChain: true,
      storageTemp: 'Strict Cold-Chain 2°C to 8°C (Do not freeze)',
      stock: 42,
      imageUrl:
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
    ),
    ProductModel(
      id: 'prod-lonart-ds',
      name: 'Lonart DS Tablets',
      brand: 'Bliss GVS Healthcare',
      genericName: 'Artemether 80mg + Lumefantrine 480mg',
      packSize: '6 Tablets Pack',
      price: 3200.0,
      wholesalePrice: 2650.0,
      category: 'Malaria Meds',
      description:
          'Double strength Artemether and Lumefantrine combination for high efficacy anti-malarial treatment.',
      dosageInstructions: 'Take 1 tablet every 12 hours for 3 days after meals.',
      activeIngredients: 'Artemether (80 mg), Lumefantrine (480 mg)',
      nafdacNumber: 'NAFDAC Reg. No. B4-1189',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 30°C',
      stock: 190,
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
    ),
    ProductModel(
      id: 'prod-omron-m2',
      name: 'Omron M2 Basic Blood Pressure Monitor',
      brand: 'Omron Healthcare',
      genericName: 'Automatic Digital Upper Arm Monitor',
      packSize: '1 Device with IntelliWrap Cuff',
      price: 28500.0,
      wholesalePrice: 24200.0,
      category: 'BP Monitors',
      description:
          'Clinically validated blood pressure monitor with hypertension indicator and irregular heartbeat detection.',
      dosageInstructions: 'Measure seated after 5 minutes of rest, morning and evening.',
      activeIngredients: 'Oscillometric Sensor, Clinical Validation Protocol',
      nafdacNumber: 'NAFDAC Certified Device #MED-8841',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store in protective case',
      stock: 35,
      imageUrl:
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=500&auto=format&fit=crop&q=60',
    ),
    ProductModel(
      id: 'prod-panadol-extra',
      name: 'Panadol Extra Tablets',
      brand: 'GlaxoSmithKline (GSK)',
      genericName: 'Paracetamol 500mg + Caffeine 65mg',
      packSize: '10 Blister Packs (20 Tabs)',
      price: 1850.0,
      wholesalePrice: 1450.0,
      category: 'Vitamins & Zinc',
      description:
          'Tough on pain, gentle on stomach. Formulated for fast relief of febrile pains, headache, and body aches.',
      dosageInstructions: 'Take 1-2 tablets every 4-6 hours as needed. Do not exceed 8 tablets in 24 hours.',
      activeIngredients: 'Paracetamol (500 mg), Caffeine (65 mg)',
      nafdacNumber: 'NAFDAC Reg. No. 04-0312',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 30°C',
      stock: 220,
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
    ),
  ];

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  }) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        var req = client.from('products').select();
        if (category != null && category != 'All') {
          req = req.eq('category', category);
        }
        final res = await req;
        if (res.isNotEmpty) {
          return res.map((e) => ProductModel.fromJson(e)).toList();
        }
      } catch (_) {
        // Fallback to mock
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    var results = List<ProductModel>.from(_mockProducts);

    if (category != null && category != 'All') {
      results = results.where((p) => p.category.toLowerCase().contains(category.toLowerCase())).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.genericName.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q))
          .toList();
    }

    return results;
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client.from('products').select().eq('id', id).maybeSingle();
        if (res != null) {
          return ProductModel.fromJson(res);
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    return _mockProducts.where((p) => p.id == id).firstOrNull ?? _mockProducts.first;
  }
}
