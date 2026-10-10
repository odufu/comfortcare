import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  });

  Future<ProductModel?> getProductById(String id);

  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String id, int stock);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  static final List<ProductModel> _mockProducts = [
    ProductModel(
      id: 'prod-coartem-80-480',
      name: 'Coartem 80/480mg',
      brand: 'Novartis',
      genericName: 'Novartis • 6 Tablets',
      packSize: '6 Tablets Blister Pack',
      price: 4200.0,
      wholesalePrice: 3833.33,
      category: 'Antimalarials',
      description:
          'Coartem is a fixed-dose artemisinin-based combination therapy (ACT) indicated for the clinical treatment of acute uncomplicated Plasmodium falciparum malaria infections.',
      dosageInstructions:
          'Take 1 tablet twice daily with fatty food or milk for 3 consecutive days (total of 6 tablets). Complete full course.',
      activeIngredients: 'Artemether (80 mg), Lumefantrine (480 mg)',
      nafdacNumber: 'NAFDAC: 04-2011',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 30°C in dry conditions',
      stock: 140,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoLw9r-RmsXTnOXgJM3rXNLOWTp4aNanpbJT4yg1dHRH5bh8wBJw_eZkLeWPOHuZZ_kVoP-UXzPUtD-sfGLck1C3w9gjm4SZ56JuI0g4F_HK7Ob0BQbZ3Bi0BW4x66DmgyxUZGJx_OLz-TnFNPyQg49zsaiNsncvjT35QqHDYEHcDPjQ54vxtV0J_wBbh5rV6n2cXy_EKqVhLe6jV77o16zZPiZGVmHho2akb6gLVW1oRjZXo8o5CaNgYsVNmVvK3mQ',
      badge1: 'In Stock',
      badge1Icon: 'verified',
      badge2: 'NAFDAC: 04-2011',
      badge2Icon: 'verified',
      packLabel: 'Retail Pack',
      cartonText: 'Carton (30): ₦115,000',
      isCartonHighlight: true,
      indications: 'Acute uncomplicated Malaria, P. falciparum infection, high fever, shivering, chills, headache, joint weakness',
      equivalentDrugs: 'Lonart Forte, Amatem Softgel, Lokmal, Artemether + Lumefantrine, P-Alaxin',
    ),
    ProductModel(
      id: 'prod-omron-m2',
      name: 'Omron M2 Basic BP',
      brand: 'Omron',
      genericName: 'Upper Arm Digital',
      packSize: '1 Complete Device with Cuff',
      price: 38500.0,
      wholesalePrice: 32000.0,
      category: 'Health Devices',
      description:
          'Clinically validated digital blood pressure monitor with Intellisense technology, hypertension indicator, and irregular heartbeat alert.',
      dosageInstructions: 'Measure seated after 5 minutes of rest, morning and evening.',
      activeIngredients: 'Oscillometric Sensor, Clinical Validation Protocol',
      nafdacNumber: '3yr Warranty',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store in protective case',
      stock: 35,
      imageUrl:
          'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=600&auto=format&fit=crop&q=80',
      badge1: 'Device',
      badge1Icon: 'medical_services',
      badge2: '3yr Warranty',
      badge2Icon: 'verified_user',
      packLabel: 'Digital Monitor',
      cartonText: 'Free Delivery',
      isCartonHighlight: true,
      indications: 'Blood pressure monitoring, hypertension tracking, cardiovascular care, heart rate tracking',
      equivalentDrugs: 'Accu-Chek, Digital Sphygmomanometer, Upper Arm BP Cuff, Beurer BP Monitor',
    ),
    ProductModel(
      id: 'prod-amoxil-500',
      name: 'Amoxil 500mg',
      brand: 'GSK',
      genericName: 'GSK • 20 Capsules',
      packSize: '20 Capsules Blister Pack',
      price: 3600.0,
      wholesalePrice: 2880.0,
      category: 'Antibiotics',
      description:
          'Broad spectrum antibacterial therapy for respiratory tract, ENT, and dental bacterial infections.',
      dosageInstructions: 'Take 1 capsule every 8 hours with plenty of water as directed by your physician.',
      activeIngredients: 'Amoxicillin (500 mg)',
      nafdacNumber: 'NAFDAC Reg. No. 04-1120',
      requiresPrescription: true,
      isColdChain: false,
      storageTemp: 'Store below 25°C in a cool dry place',
      stock: 110,
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
      badge1: 'Rx Required',
      badge1Icon: 'prescriptions',
      badge2: 'Wholesale Avail',
      badge2Icon: 'inventory_2',
      packLabel: 'Pack of 20',
      cartonText: 'Pack of 20',
      isCartonHighlight: false,
      indications: 'Bacterial infections, respiratory tract infections, dental infections, ear-nose-throat infections, bronchitis',
      equivalentDrugs: 'Augmentin 625mg, Ampiclox, Amoxicillin Trihydrate, Fleming',
    ),
    ProductModel(
      id: 'prod-latex-gloves',
      name: 'Latex Gloves (100s)',
      brand: 'SafeTouch',
      genericName: 'Powder-Free Medium',
      packSize: 'Single Box (100 pcs)',
      price: 6500.0,
      wholesalePrice: 5800.0,
      category: 'Hospital Consumables',
      description:
          'Medical sterile powder-free latex examination gloves with textured grip for healthcare procedures, clinic use, and patient care.',
      dosageInstructions: 'Single use disposable gloves. Discard after each clinical examination.',
      activeIngredients: 'Natural Rubber Latex, Polymer Coated',
      nafdacNumber: 'Clinic Grade',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store in dry hospital stockroom',
      stock: 300,
      imageUrl:
          'https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=600&auto=format&fit=crop&q=80',
      badge1: 'Bulk Deal',
      badge1Icon: 'inventory_2',
      badge2: 'Clinic Grade',
      badge2Icon: 'verified',
      packLabel: 'Single Box (100 pcs)',
      cartonText: 'Carton: ₦58k',
      isCartonHighlight: true,
      indications: 'Clinical examination, infection barrier, hospital procedures, wound dressing, patient hygiene',
      equivalentDrugs: 'Nitrile Gloves, Vinyl Gloves, Surgical Gloves, Sterile Exam Gloves',
    ),
    ProductModel(
      id: 'prod-augmentin-625',
      name: 'Augmentin 625mg',
      brand: 'GSK',
      genericName: 'Amoxicillin + Clavulanic Acid (14 Tabs)',
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
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvRFtfhY1CZMrdW6GR2-AFf7eBxEjGi0yfEf-bdUQV5O_S-oj4eV5iV0WylJ1dM-2knDIf0oPguNIa4SGr7pmZHKHAuMQgNUFUW5VK1z0QY5W2RtE_b2D7zSLND7XlH5H0npyqlutF9FPCgW74_Gapenn7XZLj2_o6MvopsBRmdKAqqhUnQVMaU87Z959jC9WMAuimo9QPmEEO-U6aQjGnxUhqwQCaTgGdJn-x0jMJAeK10cph4Ec-',
      badge1: 'Rx Required',
      badge1Icon: 'prescriptions',
      badge2: 'Life Camp Hub',
      badge2Icon: 'pin_drop',
      packLabel: 'Retail Pack',
      cartonText: 'Doctor Rx validation at checkout',
      isCartonHighlight: false,
      indications: 'Severe bacterial infections, sinusitis, lower respiratory infections, urinary tract infection (UTI), skin/soft tissue infection, dental abscess',
      equivalentDrugs: 'Fleming 625mg, Amoxil 500mg, Curam 625mg, Co-amoxiclav, Clavulin',
    ),
    ProductModel(
      id: 'prod-emzor-paracetamol',
      name: 'Emzor Paracetamol 500mg',
      brand: 'Emzor Nigeria',
      genericName: 'Pain & Fever Relief (100 Tablets Dispenser)',
      packSize: '100 Tablets Dispenser',
      price: 1200.0,
      wholesalePrice: 950.0,
      category: 'Vitamins & Immunity',
      description:
          'Antipyretic and analgesic symptom control for rapid relief of headache, feverish conditions, body pains, and chills.',
      dosageInstructions: 'Take 2 tablets every 8 hours after food with water. Do not exceed 8 tablets in 24 hours.',
      activeIngredients: 'Paracetamol BP (500 mg)',
      nafdacNumber: 'NAFDAC Approved 04-0125',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 30°C in dry conditions',
      stock: 350,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCG62rWr9JxPQ9S2YUheX_IV-3Z7b3R-0iE31gDJAYwxN_ZujSybiUkPJ-lGbFumwZqaBqkz749PIdssh9GLR_Zh3RqLolYgmipDWk4YiVqtlUXFGJjcvV7dUMj5LCgiqEoEDDRy9QdCxjuCaORKcyjhgyon9Tm6M7yQf6lH-B1ap5BkzBQQEouCNunxIoDlzSL0-GXsf0GNJFvnDX27doXELYtgvFIbnw6vcwIWn2A1z1iWT03rkAq',
      badge1: 'Everyday Essential',
      badge1Icon: 'verified',
      badge2: 'NAFDAC Approved',
      badge2Icon: 'done_all',
      packLabel: 'Box Pack',
      cartonText: 'Wholesale outer carton available',
      isCartonHighlight: true,
      indications: 'Headache, fever, mild to moderate body pain, aches, chills, muscle soreness, toothache, malaise',
      equivalentDrugs: 'Panadol Extra, Boska, Tylenol, Paracetamol, Panadol Actifast, Daga',
    ),
    ProductModel(
      id: 'prod-mixtard-insulin',
      name: 'Mixtard 30/70 Insulin 100 IU/ml',
      brand: 'Novo Nordisk',
      genericName: 'Biphasic Isophane Human Insulin',
      packSize: '10 ml Injectable Vial',
      price: 14200.0,
      wholesalePrice: 12100.0,
      category: 'Cardiovascular & BP',
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
      badge1: 'Cold-Chain',
      badge1Icon: 'ac_unit',
      badge2: 'Life Camp Hub',
      badge2Icon: 'pin_drop',
      packLabel: '10ml Vial',
      cartonText: 'Strict Cold-Chain Direct Delivery',
      isCartonHighlight: true,
      indications: 'Diabetes mellitus (Type 1 and Type 2), blood sugar regulation, glycemic control, hyperglycemia prevention',
      equivalentDrugs: 'Humulin 70/30, Lantus, Actrapid, Novomix, Insuman',
    ),
    ProductModel(
      id: 'prod-panadol-extra',
      name: 'Panadol Extra Tablets',
      brand: 'GlaxoSmithKline (GSK)',
      genericName: 'Paracetamol 500mg + Caffeine 65mg',
      packSize: '10 Blister Packs (20 Tabs)',
      price: 1850.0,
      wholesalePrice: 1450.0,
      category: 'Vitamins & Immunity',
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
      badge1: 'Fast Relief',
      badge1Icon: 'flash_on',
      badge2: 'NAFDAC Verified',
      badge2Icon: 'verified',
      packLabel: 'Retail Pack',
      cartonText: '20 Strips outer carton available',
      isCartonHighlight: false,
      indications: 'Severe headache, migraine, tension headache, acute fever, muscular pain, toothache, dysmenorrhea',
      equivalentDrugs: 'Emzor Paracetamol, Boska, Panadol Actifast, Cataflam, Ibuprofen, Feldene',
    ),
    ProductModel(
      id: 'prod-carestart-rdt',
      name: 'CareStart Malaria RDT Kit',
      brand: 'Access Bio',
      genericName: 'Single Antigen Cassette Test',
      packSize: '1 Test Cassette + Lancet + Buffer',
      price: 1800.0,
      wholesalePrice: 1400.0,
      category: 'Health Devices',
      description:
          'Rapid in-vitro diagnostic immunochromatographic assay for the detection of Plasmodium falciparum histidine-rich protein 2 (HRP2) in human whole blood.',
      dosageInstructions: 'Single use rapid test. Read results strictly between 15-20 minutes.',
      activeIngredients: 'Colloidal Gold conjugated monoclonal anti-HRP2 antibodies',
      nafdacNumber: 'NAFDAC Reg. No. 03-8821',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store between 1°C and 40°C. Do not freeze.',
      stock: 120,
      imageUrl:
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
      badge1: 'Express Dispatch',
      badge1Icon: 'timer',
      badge2: 'Point of Care',
      badge2Icon: 'verified',
      packLabel: 'Single Test Kit',
      cartonText: 'Box of 25 Tests available',
      isCartonHighlight: false,
      indications: 'Malaria diagnostic testing, Plasmodium falciparum parasite screening, febrile illness differential diagnosis',
      equivalentDrugs: 'SD Bioline Malaria RDT, First Response Malaria Test Kit',
    ),
    ProductModel(
      id: 'prod-ors-zinc',
      name: 'ORS Hydration + Zinc',
      brand: 'Chi Pharmaceuticals',
      genericName: 'Oral Rehydration Salts with Zinc Sulfate',
      packSize: '5 Sachets Pack',
      price: 1400.0,
      wholesalePrice: 1100.0,
      category: 'Vitamins & Immunity',
      description:
          'WHO-recommended low osmolarity oral rehydration salts with elemental zinc for rapid recovery, electrolyte replacement, and dehydration management.',
      dosageInstructions: 'Dissolve entire contents of 1 sachet in 1000ml (1 Liter) of clean drinking water. Drink as needed.',
      activeIngredients: 'Sodium Chloride 2.6g, Glucose Anhydrous 13.5g, Potassium Chloride 1.5g, Trisodium Citrate 2.9g, Zinc Sulfate 20mg',
      nafdacNumber: 'NAFDAC Reg. No. 04-5512',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store in a cool, dry place',
      stock: 240,
      imageUrl:
          'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
      badge1: 'WHO Standard',
      badge1Icon: 'verified',
      badge2: 'Pediatric Care',
      badge2Icon: 'check_circle',
      packLabel: '5 Sachets Pack',
      cartonText: 'Carton (50 packs): ₦45,000',
      isCartonHighlight: true,
      indications: 'Dehydration, diarrhea, gastroenteritis, electrolyte depletion, heat exhaustion, cholera rehydration',
      equivalentDrugs: 'HydraLyte, Electrorush, Dioralyte, Oralyt',
    ),
    ProductModel(
      id: 'prod-osteocare-vitabiotics',
      name: 'Osteocare Calcium + Vitamin D3 & Zinc',
      brand: 'Vitabiotics',
      genericName: 'Calcium Carbonate 800mg + Vit D3 400IU + Magnesium & Zinc',
      packSize: '30 Tablets Pack',
      price: 4800.0,
      wholesalePrice: 4100.0,
      category: 'Vitamins & Immunity',
      description:
          'Clinical bone remineralization formula specifically supporting bone fracture healing, callus formation, skeletal consolidation, and joint strength.',
      dosageInstructions: 'Take 2 tablets daily with a main meal and water. Do not chew.',
      activeIngredients: 'Calcium 800mg, Magnesium 300mg, Zinc 10mg, Vitamin D3 10µg (400 IU)',
      nafdacNumber: 'NAFDAC Reg. No. 04-3319',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 25°C in a dry place',
      stock: 95,
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
      badge1: 'Bone Healing',
      badge1Icon: 'health_and_safety',
      badge2: 'Vitabiotics UK',
      badge2Icon: 'verified',
      packLabel: 'Pack of 30',
      cartonText: 'Carton (24 packs): ₦98,000',
      isCartonHighlight: true,
      indications:
          'Bone fracture healing, fracture recovery, bone consolidation, calcium deficiency, osteoporosis prevention, leg bone remineralization, post-trauma bone support, joint stiffness',
      equivalentDrugs: 'Caltrate 600+D, Calcichew D3, Calcium Sandoz, Bone Health Complex, Osteo-D',
    ),
    ProductModel(
      id: 'prod-deep-heat-rub',
      name: 'Deep Heat Fast Relief Rub',
      brand: 'Mentholatum',
      genericName: 'Methyl Salicylate 12.8% + Menthol 5.9%',
      packSize: '100g Tube',
      price: 2950.0,
      wholesalePrice: 2450.0,
      category: 'Vitamins & Immunity',
      description:
          'Targeted heat therapy and analgesic rub for relieving post-fracture muscular stiffness, joint tightness, and facilitating physical therapy exercises and leg fluidity.',
      dosageInstructions:
          'Gently massage into the affected leg or joint 2-3 times daily, especially before and after rehabilitation mobility exercises.',
      activeIngredients: 'Methyl Salicylate 12.8%, Menthol 5.9%, Eucalyptus Oil 1.97%',
      nafdacNumber: 'NAFDAC Reg. No. 04-1021',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 30°C',
      stock: 140,
      imageUrl:
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=600&auto=format&fit=crop&q=80',
      badge1: 'Stiffness Relief',
      badge1Icon: 'healing',
      badge2: 'Fast Relief',
      badge2Icon: 'flash_on',
      packLabel: '100g Tube',
      cartonText: 'Wholesale carton available',
      isCartonHighlight: false,
      indications:
          'Leg stiffness, muscle tightness, joint mobility, physiotherapy rub, fracture recovery stiffness, walking pain, muscular spasm, legs not moving fluidly',
      equivalentDrugs: 'Voltarol Gel, Fastum Gel, Flexall, Tiger Balm, Ice Power, Wintergreen Gel',
    ),
    ProductModel(
      id: 'prod-neurobion-forte',
      name: 'Neurobion Forte Tablets',
      brand: 'P&G Health',
      genericName: 'Vitamin B1 + B6 + B12 Neurotropic Complex',
      packSize: '30 Coated Tablets',
      price: 3400.0,
      wholesalePrice: 2850.0,
      category: 'Vitamins & Immunity',
      description:
          'Neurotropic B-vitamin complex supporting peripheral nerve regeneration, neuromuscular transmission, and coordination for smooth, fluid limb movements during rehabilitation.',
      dosageInstructions: 'Take 1 tablet daily with a glass of water after food.',
      activeIngredients: 'Thiamine (B1) 100mg, Pyridoxine (B6) 200mg, Cyanocobalamin (B12) 200µg',
      nafdacNumber: 'NAFDAC Reg. No. 04-2901',
      requiresPrescription: false,
      isColdChain: false,
      storageTemp: 'Store below 25°C',
      stock: 160,
      imageUrl:
          'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=600&auto=format&fit=crop&q=80',
      badge1: 'Nerve Health',
      badge1Icon: 'psychology',
      badge2: 'Merck Formulation',
      badge2Icon: 'verified',
      packLabel: '30 Tablets',
      cartonText: 'Box of 100 available',
      isCartonHighlight: false,
      indications:
          'Nerve repair, fluid movement coordination, limb numbness, neuropathy, post-injury nerve healing, rehabilitation motor control, gait coordination',
      equivalentDrugs: 'Neurovit, Nervamin, B-Complex High Potency, Vitamin B1 B6 B12',
    ),
  ];

  static List<ProductModel> get inMemoryProducts => List.unmodifiable(_mockProducts);

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    bool isWholesale = false,
  }) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        var req = client.from(ApiConstants.productsTable).select();
        if (category != null && category != 'All') {
          req = req.eq('category', category);
        }
        final res = await req.order('created_at', ascending: false);
        if (res.isNotEmpty) {
          var fetched = res.map((e) => ProductModel.fromJson(e)).toList();
          if (query != null && query.trim().isNotEmpty) {
            final q = query.toLowerCase().trim();
            fetched = fetched
                .where((p) =>
                    p.name.toLowerCase().contains(q) ||
                    p.genericName.toLowerCase().contains(q) ||
                    p.brand.toLowerCase().contains(q))
                .toList();
          }
          return fetched;
        }
      } catch (_) {
        // Fallback to mock
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    var results = List<ProductModel>.from(_mockProducts);

    if (category != null && category != 'All') {
      final cat = category.toLowerCase().trim();
      results = results.where((p) {
        final pCat = p.category.toLowerCase().trim();
        if (pCat == cat || pCat.contains(cat) || cat.contains(pCat)) {
          return true;
        }
        if (cat.contains('malaria') && pCat.contains('malaria')) return true;
        if (cat.contains('cardio') && (pCat.contains('cardio') || pCat.contains('bp') || pCat.contains('insulin'))) return true;
        if (cat.contains('device') && (pCat.contains('device') || pCat.contains('bp'))) return true;
        if (cat.contains('vitamin') && (pCat.contains('vitamin') || pCat.contains('zinc'))) return true;
        return false;
      }).toList();
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
        final res = await client
            .from(ApiConstants.productsTable)
            .select()
            .eq('id', id)
            .maybeSingle();
        if (res != null) {
          return ProductModel.fromJson(res);
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    return _mockProducts.where((p) => p.id == id).firstOrNull ?? _mockProducts.first;
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final payload = product.toJson();
        final res = await client
            .from(ApiConstants.productsTable)
            .insert(payload)
            .select()
            .single();
        final created = ProductModel.fromJson(res);
        _mockProducts.insert(0, created);
        return created;
      } catch (_) {
        // Retry without extended AI columns in case migration is not yet applied
        try {
          final stripped = Map<String, dynamic>.from(product.toJson())
            ..remove('indications')
            ..remove('equivalent_drugs');
          final res = await client
              .from(ApiConstants.productsTable)
              .insert(stripped)
              .select()
              .single();
          final created = ProductModel.fromJson(res);
          _mockProducts.insert(0, created);
          return created;
        } catch (_) {}
      }
    }

    _mockProducts.insert(0, product);
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final payload = product.toJson();
        final res = await client
            .from(ApiConstants.productsTable)
            .update(payload)
            .eq('id', product.id)
            .select()
            .single();
        final updated = ProductModel.fromJson(res);
        final index = _mockProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _mockProducts[index] = updated;
        }
        return updated;
      } catch (_) {
        // Retry without extended AI columns in case migration is not yet applied
        try {
          final stripped = Map<String, dynamic>.from(product.toJson())
            ..remove('indications')
            ..remove('equivalent_drugs');
          final res = await client
              .from(ApiConstants.productsTable)
              .update(stripped)
              .eq('id', product.id)
              .select()
              .single();
          final updated = ProductModel.fromJson(res);
          final index = _mockProducts.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _mockProducts[index] = updated;
          }
          return updated;
        } catch (_) {}
      }
    }

    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _mockProducts[index] = product;
    }
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client
            .from(ApiConstants.productsTable)
            .delete()
            .eq('id', id);
      } catch (_) {
        // Fallback
      }
    }

    _mockProducts.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> updateStock(String id, int stock) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client
            .from(ApiConstants.productsTable)
            .update({'stock': stock})
            .eq('id', id);
      } catch (_) {
        // Fallback
      }
    }

    final index = _mockProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final p = _mockProducts[index];
      _mockProducts[index] = ProductModel(
        id: p.id,
        name: p.name,
        brand: p.brand,
        genericName: p.genericName,
        packSize: p.packSize,
        price: p.price,
        wholesalePrice: p.wholesalePrice,
        category: p.category,
        description: p.description,
        dosageInstructions: p.dosageInstructions,
        activeIngredients: p.activeIngredients,
        nafdacNumber: p.nafdacNumber,
        requiresPrescription: p.requiresPrescription,
        isColdChain: p.isColdChain,
        storageTemp: p.storageTemp,
        stock: stock,
        imageUrl: p.imageUrl,
        badge1: p.badge1,
        badge1Icon: p.badge1Icon,
        badge2: p.badge2,
        badge2Icon: p.badge2Icon,
        packLabel: p.packLabel,
        cartonText: p.cartonText,
        isCartonHighlight: p.isCartonHighlight,
      );
    }
  }
}
