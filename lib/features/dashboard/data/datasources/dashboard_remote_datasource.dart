import '../../../../core/services/supabase_service.dart';
import '../models/category_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<Map<String, dynamic>> getHubTelemetry();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client.from('categories').select();
        if (res.isNotEmpty) {
          return res.map((e) => CategoryModel.fromJson(e)).toList();
        }
      } catch (_) {
        // Fallback to demo
      }
    }

    // Decoupled Demo Fallback from PRD & Designs
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      CategoryModel(
        id: 'cat-drugs',
        title: 'Prescription Drugs',
        subtitle: 'NAFDAC Verified ACTs, Antibiotics',
        itemCount: '340+ Items',
        iconName: 'medication',
      ),
      CategoryModel(
        id: 'cat-ai',
        title: 'Clinical AI Consult',
        subtitle: 'Symptom triage & pharmacist oversight',
        itemCount: '24/7 Co-Pilot',
        iconName: 'smart_toy',
      ),
      CategoryModel(
        id: 'cat-coldchain',
        title: 'Cold-Chain Insulin',
        subtitle: 'Calibrated storage 2°C - 8°C',
        itemCount: '48 Strains',
        iconName: 'ac_unit',
      ),
      CategoryModel(
        id: 'cat-vitals',
        title: 'Health Vitals Monitor',
        subtitle: 'Blood pressure & glucose telemetry',
        itemCount: 'Sync Active',
        iconName: 'monitor_heart',
      ),
      CategoryModel(
        id: 'cat-malaria',
        title: 'Malaria Regimens',
        subtitle: 'Coartem, Lonart DS, ACT Combos',
        itemCount: '28 Formulations',
        iconName: 'coronavirus',
      ),
      CategoryModel(
        id: 'cat-wholesale',
        title: 'Wholesale Depot Packs',
        subtitle: 'Tier 2 bulk clinic procurement',
        itemCount: 'Bulk Discounts',
        iconName: 'domain',
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> getHubTelemetry() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'hub_name': 'Abuja Logistics & Cold-Chain Hub',
      'location': 'Comfort Mall, Life Camp, Abuja',
      'temperature': '3.8°C Normal',
      'status': 'Secured Stream',
      'nafdac_regulated': true,
      'pcn_regulated': true,
      'express_eta': '25-35 mins',
      'active_riders': 12,
    };
  }
}
