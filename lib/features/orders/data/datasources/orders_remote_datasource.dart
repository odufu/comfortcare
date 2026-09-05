import '../../../../core/services/supabase_service.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(String id);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  static final List<OrderModel> _orders = [
    OrderModel(
      id: 'CC-84920',
      items: const [
        CartItemModel(
          product: ProductModel(
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
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
          ),
          quantity: 2,
        ),
      ],
      totalAmount: 8900.0,
      destinationAddress: 'Plot 1044, Adetokunbo Ademola Crescent, Wuse 2, Abuja',
      recipientName: 'Dr. Farouk Al-Mansur',
      recipientPhone: '+234 803 265 1505',
      dispatchSpeed: DispatchSpeed.express,
      status: OrderStatus.inTransit,
      riderName: 'Rider Ibrahim',
      riderPhone: '+234 812 345 6789',
      eta: '18 mins • Arriving ~3:45 PM',
      coldChainTemp: 'Cold-Chain 3.8°C Normal',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
  ];

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('orders').insert(order.toJson());
        return order;
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client.from('orders').select().order('created_at');
        if (res.isNotEmpty) {
          return res.map((e) => OrderModel.fromJson(e)).toList();
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return _orders;
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client.from('orders').select().eq('id', id).maybeSingle();
        if (res != null) {
          return OrderModel.fromJson(res);
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return _orders.isNotEmpty ? _orders.first : null;
    }
  }
}
