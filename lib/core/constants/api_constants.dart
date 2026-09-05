class ApiConstants {
  // Supabase Configuration
  // In production, these should be supplied via environment variables or secure remote config
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://comfortcare.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.comfortcare_anon_public_key',
  );

  // Table Names
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String profilesTable = 'profiles';
  static const String prescriptionsTable = 'prescriptions';
  static const String vitalsTable = 'vitals';
  static const String consultationsTable = 'consultations';
  static const String addressesTable = 'addresses';
}
