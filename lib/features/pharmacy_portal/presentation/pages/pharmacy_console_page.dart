import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/currency_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../products/data/datasources/products_remote_datasource.dart';
import '../../../products/domain/entities/product.dart';

class PharmacyConsolePage extends StatefulWidget {
  const PharmacyConsolePage({super.key});

  @override
  State<PharmacyConsolePage> createState() => _PharmacyConsolePageState();
}

class _PharmacyConsolePageState extends State<PharmacyConsolePage>
    with SingleTickerProviderStateMixin {
  final ProductsRemoteDataSource _productsDataSource =
      ProductsRemoteDataSourceImpl();

  late TabController _tabController;
  List<ProductEntity> _wholesaleCatalog = [];
  List<Map<String, dynamic>> _retailStock = [];
  List<Map<String, dynamic>> _customerOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPharmacyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacyData() async {
    setState(() => _isLoading = true);
    final prods = await _productsDataSource.getProducts(isWholesale: true);

    // Initial mock retail inventory for MedPlus Pharmacy
    final stock = [
      {
        'id': 'medplus-coartem',
        'name': 'Coartem 80/480mg (Artemether / Lumefantrine)',
        'category': 'Antimalarials',
        'retailPrice': 3200.0,
        'wholesaleCost': 2400.0,
        'stockUnits': 142,
        'isAvailable': true,
      },
      {
        'id': 'medplus-amoxil',
        'name': 'Augmentin 625mg Tablets (Amoxicillin/Clavulanate)',
        'category': 'Antibiotics',
        'retailPrice': 5500.0,
        'wholesaleCost': 4125.0,
        'stockUnits': 84,
        'isAvailable': true,
      },
      {
        'id': 'medplus-panadol',
        'name': 'Panadol Extra Paracetamol 500mg (10x10 Packs)',
        'category': 'Analgesics',
        'retailPrice': 1800.0,
        'wholesaleCost': 1350.0,
        'stockUnits': 310,
        'isAvailable': true,
      },
      {
        'id': 'medplus-ventolin',
        'name': 'Ventolin Inhaler 100mcg (Salbutamol GSK)',
        'category': 'Respiratory',
        'retailPrice': 7200.0,
        'wholesaleCost': 5400.0,
        'stockUnits': 36,
        'isAvailable': true,
      },
      {
        'id': 'medplus-camoquin',
        'name': 'Lonart Forte 80/480mg (6 Tablets)',
        'category': 'Antimalarials',
        'retailPrice': 2900.0,
        'wholesaleCost': 2175.0,
        'stockUnits': 95,
        'isAvailable': true,
      },
    ];

    // Initial incoming customer orders from regular app users
    final orders = [
      {
        'orderId': 'ORD-CC-90412',
        'patientName': 'Amina Bello',
        'items': 'Coartem 80/480mg (x2), Panadol Extra (x1)',
        'total': 8200.0,
        'status': 'Dispensing',
        'destination': 'Wuse 2, Abuja (Express Courier)',
        'time': '10 mins ago',
      },
      {
        'orderId': 'ORD-CC-90418',
        'patientName': 'Ibrahim Musa',
        'items': 'Augmentin 625mg (x1), Ventolin Inhaler (x1)',
        'total': 12700.0,
        'status': 'Ready for Pickup',
        'destination': 'In-store Pickup (Life Camp)',
        'time': '25 mins ago',
      },
      {
        'orderId': 'ORD-CC-90422',
        'patientName': 'Grace Adeleke',
        'items': 'Lonart Forte (x1)',
        'total': 2900.0,
        'status': 'New Order',
        'destination': 'Gwarinpa Estate, Abuja',
        'time': 'Just now',
      },
    ];

    if (mounted) {
      setState(() {
        _wholesaleCatalog = prods;
        _retailStock = stock;
        _customerOrders = orders;
        _isLoading = false;
      });
    }
  }

  void _orderWholesale(ProductEntity product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Wholesale Restock: ${product.name}'),
        content: Column(
          mainAxisSize: minAxis,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ComfortCare Wholesale Supply Depot Adetokunbo Ademola Crescent'),
            const SizedBox(height: 10),
            Text('Wholesale Price / Carton: ${product.wholesalePrice.toNaira()}'),
            Text('Minimum Order Quantity: 1 Master Carton (50 Packs)'),
            const SizedBox(height: 12),
            const Text(
              'Placing this order will deduct from your wholesale facility balance and add 50 units directly into your MedPlus retail inventory for app users.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                final match = _retailStock.firstWhere(
                  (s) => (s['name'] as String).toLowerCase().contains(product.name.toLowerCase().substring(0, 5)),
                  orElse: () => {
                    'id': 'medplus-${product.id}',
                    'name': product.name,
                    'category': product.category,
                    'retailPrice': product.price,
                    'wholesaleCost': product.wholesalePrice,
                    'stockUnits': 0,
                    'isAvailable': true,
                  },
                );
                if (!_retailStock.contains(match)) {
                  match['stockUnits'] = 50;
                  _retailStock.insert(0, match);
                } else {
                  match['stockUnits'] = (match['stockUnits'] as int) + 50;
                }
              });
              context.showSnackBar(
                'Wholesale order for 1 Carton (50 units) of ${product.name} confirmed! Restocked.',
                isSuccess: true,
              );
            },
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: const Text('Order 1 Carton (50 Units)'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF007A78)),
          ),
        ],
      ),
    );
  }

  static const MainAxisSize minAxis = MainAxisSize.min;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pharmacy Partner Console',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'MedPlus Pharmacy Ltd • Life Camp Hub (PCN-R-90412)',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Store Data',
            onPressed: _loadPharmacyData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/auth/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Badge(
                label: Text('${_customerOrders.length}'),
                child: const Icon(Icons.receipt_long_outlined),
              ),
              text: 'Customer Orders',
            ),
            const Tab(
              icon: Icon(Icons.inventory_2_outlined),
              text: 'Retail Inventory',
            ),
            const Tab(
              icon: Icon(Icons.domain_add_outlined),
              text: 'Wholesale Depot (B2B)',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCustomerOrdersTab(),
                _buildRetailInventoryTab(),
                _buildWholesaleProcurementTab(),
              ],
            ),
    );
  }

  // 1. Customer Orders Tab
  Widget _buildCustomerOrdersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981),
                  const Color(0xFF047857),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incoming User Orders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Orders placed by regular users in the ComfortCare app to be fulfilled by your pharmacy.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Active Dispensing Queue (${_customerOrders.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _customerOrders.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ord = _customerOrders[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                        Text(
                          ord['orderId'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ord['status'] == 'Dispensing'
                                ? Colors.amber.shade100
                                : ord['status'] == 'Ready for Pickup'
                                    ? Colors.green.shade100
                                    : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ord['status'] as String,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: ord['status'] == 'Dispensing'
                                  ? Colors.brown.shade800
                                  : ord['status'] == 'Ready for Pickup'
                                      ? Colors.green.shade800
                                      : Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Customer: ${ord['patientName']} • ${ord['time']}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Items: ${ord['items']}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delivery Route: ${ord['destination']}',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ${(ord['total'] as double).toNaira()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  ord['status'] = 'Dispensing';
                                });
                                context.showSnackBar('Order ${ord['orderId']} marked as Dispensing');
                              },
                              child: const Text('Dispense', style: TextStyle(fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  ord['status'] = 'Ready for Pickup';
                                });
                                context.showSnackBar('Order ${ord['orderId']} marked as Ready for Dispatch!');
                              },
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF007A78)),
                              child: const Text('Mark Ready', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 2. Retail Inventory Tab
  Widget _buildRetailInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Retail Medicines in Stock (${_retailStock.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () => _tabController.animateTo(2),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Wholesale Restock'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _retailStock.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _retailStock[index];
              final isAvailable = item['isAvailable'] as bool;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medication, color: Color(0xFF007A78), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Retail: ${(item['retailPrice'] as double).toNaira()} • Cost: ${(item['wholesaleCost'] as double).toNaira()}',
                            style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                          ),
                          Text(
                            'Available Stock: ${item['stockUnits']} units',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: (item['stockUnits'] as int) < 50 ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isAvailable,
                      activeThumbColor: const Color(0xFF007A78),
                      onChanged: (val) {
                        setState(() {
                          item['isAvailable'] = val;
                        });
                        context.showSnackBar(
                          '${item['name']} is now ${val ? "available" : "hidden"} in the user marketplace.',
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Wholesale Procurement Tab
  Widget _buildWholesaleProcurementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.domain, color: Color(0xFF007A78), size: 30),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ComfortCare Central Depot Wholesale Supply',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Purchase master cartons at wholesale rates (-25% discount). Automatic stock integration into your retail app storefront.',
                        style: TextStyle(fontSize: 11.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Wholesale Bulk Inventory for Restocking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _wholesaleCatalog.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final prod = _wholesaleCatalog[index];
              final wholesalePrice = prod.wholesalePrice;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prod.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Wholesale: ${wholesalePrice.toNaira()} • Retail MSRP: ${prod.price.toNaira()}',
                            style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                          ),
                          const Text(
                            'Carton Size: 50 Packs • 25% Gross Margin',
                            style: TextStyle(fontSize: 10.5, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _orderWholesale(prod),
                      icon: const Icon(Icons.add_shopping_cart, size: 14),
                      label: const Text('Order Carton', style: TextStyle(fontSize: 11)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF007A78),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
