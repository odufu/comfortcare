import 'package:comfort_care/features/pharmacy_portal/domain/entities/pharmacy_entity.dart';

/// In-memory repository of registered licensed community pharmacies across Abuja (FCT)
/// that act as decentralized micro-fulfillment centers for ComfortCare.
class MockCommunityPharmaciesRepository {
  MockCommunityPharmaciesRepository._();
  static final MockCommunityPharmaciesRepository instance =
      MockCommunityPharmaciesRepository._();

  final List<CommunityPharmacyEntity> _pharmacies = [
    // 1. MedPlus Pharmacy (Life Camp) - Close to Life Camp, Gwarinpa, Kado
    const CommunityPharmacyEntity(
      id: 'ph-medplus-lifecamp',
      name: 'MedPlus Pharmacy (Life Camp)',
      address: 'Suite 12, Comfort Mall Commercial Wing, Life Camp, Abuja',
      city: 'Abuja',
      state: 'Federal Capital Territory',
      lga: 'Abuja Municipal (AMAC)',
      landmark: 'Near Life Camp Roundabout & Comfort Mall',
      latitude: 9.0125,
      longitude: 7.4080,
      phone: '+234 803 111 2233',
      whatsapp: '+234 803 111 2233',
      licenseNumber: 'PCN/FCT/2024/0981',
      pharmacistInCharge: 'Pharm. Kenneth Okafor, B.Pharm',
      isOpen: true,
      rating: 4.9,
      stockLevels: {
        'Coartem 80/480mg': 45,
        'Coartem': 45,
        'Amoxil 500mg': 30,
        'Amoxil': 30,
        'Augmentin 625mg': 20,
        'Augmentin': 20,
        'Paracetamol 500mg': 100,
        'Paracetamol': 100,
        'Latex Gloves (100s)': 50,
        'Latex Gloves': 50,
        'Omron M2 Basic BP': 8,
        'Omron': 8,
      },
    ),

    // 2. H-Medix Pharmacy (Wuse 2) - Central Abuja, fastest for Wuse 2, Maitama, Central Area
    const CommunityPharmacyEntity(
      id: 'ph-hmedix-wuse2',
      name: 'H-Medix Pharmacy (Wuse 2)',
      address: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
      city: 'Abuja',
      state: 'Federal Capital Territory',
      lga: 'Abuja Municipal (AMAC)',
      landmark: 'Beside AP Plaza, Adetokunbo Ademola Corridor',
      latitude: 9.0765,
      longitude: 7.4720,
      phone: '+234 802 444 5566',
      whatsapp: '+234 802 444 5566',
      licenseNumber: 'PCN/FCT/2023/1102',
      pharmacistInCharge: 'Pharm. Fatima Bello, M.Pharm',
      isOpen: true,
      rating: 4.95,
      stockLevels: {
        'Coartem 80/480mg': 60,
        'Coartem': 60,
        'Amoxil 500mg': 40,
        'Amoxil': 40,
        'Augmentin 625mg': 35,
        'Augmentin': 35,
        'Paracetamol 500mg': 200,
        'Paracetamol': 200,
        'Latex Gloves (100s)': 80,
        'Latex Gloves': 80,
        'Ciprofloxacin 500mg': 30,
        'Ibuprofen 400mg': 90,
        // Intentionally missing 'Omron M2 Basic BP' and 'Ventolin Inhaler' to trigger multi-stop sourcing
      },
    ),

    // 3. HealthPlus Pharmacy (Maitama) - High-end diplomatic sector
    const CommunityPharmacyEntity(
      id: 'ph-healthplus-maitama',
      name: 'HealthPlus Pharmacy (Maitama)',
      address: 'Plot 82, Gana Street, Maitama, Abuja',
      city: 'Abuja',
      state: 'Federal Capital Territory',
      lga: 'Abuja Municipal (AMAC)',
      landmark: 'Near Transcorp Hilton Corridor, Gana Street',
      latitude: 9.0880,
      longitude: 7.4980,
      phone: '+234 803 777 8899',
      whatsapp: '+234 803 777 8899',
      licenseNumber: 'PCN/FCT/2022/0743',
      pharmacistInCharge: 'Pharm. Chinedu Eze, B.Pharm',
      isOpen: true,
      rating: 4.88,
      stockLevels: {
        'Omron M2 Basic BP': 15,
        'Omron': 15,
        'Ventolin Inhaler': 25,
        'Ventolin': 25,
        'Insulin Glargine Lantus': 12,
        'Augmentin 625mg': 15,
        'Paracetamol 500mg': 80,
      },
    ),

    // 4. Netcare Community Pharmacy (Garki 2) - Southern Abuja
    const CommunityPharmacyEntity(
      id: 'ph-netcare-garki2',
      name: 'Netcare Community Pharmacy (Garki 2)',
      address: 'Area 11, Muhammadu Buhari Way, Garki 2, Abuja',
      city: 'Abuja',
      state: 'Federal Capital Territory',
      lga: 'Abuja Municipal (AMAC)',
      landmark: 'Near Area 11 Junction',
      latitude: 9.0340,
      longitude: 7.4890,
      phone: '+234 809 333 4455',
      whatsapp: '+234 809 333 4455',
      licenseNumber: 'PCN/FCT/2025/0312',
      pharmacistInCharge: 'Pharm. Halima Aliyu, B.Pharm',
      isOpen: true,
      rating: 4.85,
      stockLevels: {
        'Coartem 80/480mg': 30,
        'Amoxil 500mg': 25,
        'Paracetamol 500mg': 150,
        'Latex Gloves (100s)': 30,
      },
    ),

    // 5. Next Mega Supercentre & Pharmacy (Kado / Gwarinpa Expressway)
    const CommunityPharmacyEntity(
      id: 'ph-next-kado',
      name: 'Next Supercentre Pharmacy (Kado)',
      address: 'Ahmadu Bello Way, Kado District, Abuja',
      city: 'Abuja',
      state: 'Federal Capital Territory',
      lga: 'Abuja Municipal (AMAC)',
      landmark: 'Next Cash & Carry Complex, Kado Expressway',
      latitude: 9.0920,
      longitude: 7.4120,
      phone: '+234 814 555 6677',
      whatsapp: '+234 814 555 6677',
      licenseNumber: 'PCN/FCT/2021/0450',
      pharmacistInCharge: 'Pharm. Babatunde Adeleke, B.Pharm',
      isOpen: true,
      rating: 4.92,
      stockLevels: {
        'Omron M2 Basic BP': 50,
        'Omron': 50,
        'Latex Gloves (100s)': 200,
        'Latex Gloves': 200,
        'Augmentin 625mg': 60,
        'Coartem 80/480mg': 80,
      },
    ),

    // 6. M-Care Distant Mega Pharmacy (Kubwa Express Outskirts)
    // IMPORTANT: Has 100% of ALL items, but is far away (~22km, 48-55 mins arrival time).
    // Tests user's rule: Arrival time is maximum priority! If this distant pharmacy has all items
    // but arrives in 50 mins, while local pharmacies arrive in 15 mins via 2 stops,
    // local rapid pharmacies take precedence!
    const CommunityPharmacyEntity(
      id: 'ph-mcare-kubwa-distant',
      name: 'M-Care Mega Pharmacy (Kubwa Express Outskirts)',
      address: 'Phase 4, Gado Nasko Way, Kubwa, Abuja',
      city: 'Abuja',
      state: 'Federal Capital Territory',
      lga: 'Bwari Area Council',
      landmark: 'Kubwa Expressway Exit 3',
      latitude: 9.1550,
      longitude: 7.3200,
      phone: '+234 805 999 0011',
      whatsapp: '+234 805 999 0011',
      licenseNumber: 'PCN/FCT/2020/0188',
      pharmacistInCharge: 'Pharm. Danladi Musa, M.Pharm',
      isOpen: true,
      rating: 4.75,
      stockLevels: {
        'Coartem 80/480mg': 500,
        'Coartem': 500,
        'Amoxil 500mg': 300,
        'Amoxil': 300,
        'Augmentin 625mg': 250,
        'Augmentin': 250,
        'Omron M2 Basic BP': 100,
        'Omron': 100,
        'Latex Gloves (100s)': 500,
        'Latex Gloves': 500,
        'Ventolin Inhaler': 80,
        'Ventolin': 80,
        'Paracetamol 500mg': 1000,
        'Paracetamol': 1000,
        'Insulin Glargine Lantus': 50,
      },
    ),
  ];

  List<CommunityPharmacyEntity> getAll() => List.unmodifiable(_pharmacies);

  CommunityPharmacyEntity? getById(String id) {
    try {
      return _pharmacies.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void registerPharmacy(CommunityPharmacyEntity pharmacy) {
    _pharmacies.removeWhere((p) => p.id == pharmacy.id);
    _pharmacies.add(pharmacy);
  }
}
