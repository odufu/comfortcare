class ApiConstants {
  // Supabase Configuration
  // Connected to live project aqxgbnzfidccmeqpdyaq
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://aqxgbnzfidccmeqpdyaq.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGdibnpmaWRjY21lcXBkeWFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM1MTc0MzYsImV4cCI6MjA5OTA5MzQzNn0.1V03WoumE7E5bxSEzUQfUal6VEQ-8vk2_mDyRrvAoeA',
  );

  // Gemini AI Configuration
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDYU5-TRK1LLBQsTWRUPzlwAscYFeo7ic8',
  );
  static const String geminiModel = 'gemini-2.5-flash';

  // Table Names - Unique ComfortCare 'cc_' Prefix to avoid conflict with other projects
  static const String productsTable = 'cc_products';
  static const String categoriesTable = 'cc_categories';
  static const String ordersTable = 'cc_orders';
  static const String orderItemsTable = 'cc_order_items';
  static const String profilesTable = 'cc_profiles';
  static const String prescriptionsTable = 'cc_prescriptions';
  static const String vitalsTable = 'cc_vitals';
  static const String consultationsTable = 'cc_consultations';
  static const String addressesTable = 'cc_addresses';
}
