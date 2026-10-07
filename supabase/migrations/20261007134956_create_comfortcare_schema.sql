-- ============================================================================
-- COMFORTCARE PHARMACEUTICALS & DIGITAL HEALTH PLATFORM SCHEMA
-- Unique Project Prefix: cc_ (prevents conflicts with Novacare / other projects)
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. CATEGORIES TABLE (cc_categories)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.cc_categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  icon TEXT,
  description TEXT,
  item_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.cc_categories DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. PRODUCTS TABLE (cc_products)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.cc_products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  brand TEXT NOT NULL,
  generic_name TEXT NOT NULL,
  pack_size TEXT NOT NULL,
  price NUMERIC NOT NULL DEFAULT 0,
  wholesale_price NUMERIC NOT NULL DEFAULT 0,
  category TEXT NOT NULL DEFAULT 'General',
  description TEXT DEFAULT '',
  dosage_instructions TEXT DEFAULT '',
  active_ingredients TEXT DEFAULT '',
  nafdac_number TEXT DEFAULT '',
  requires_prescription BOOLEAN NOT NULL DEFAULT FALSE,
  is_cold_chain BOOLEAN NOT NULL DEFAULT FALSE,
  storage_temp TEXT DEFAULT 'Store below 30°C',
  stock INT NOT NULL DEFAULT 50,
  image_url TEXT DEFAULT '',
  badge1 TEXT DEFAULT NULL,
  badge1_icon TEXT DEFAULT NULL,
  badge2 TEXT DEFAULT NULL,
  badge2_icon TEXT DEFAULT NULL,
  pack_label TEXT DEFAULT NULL,
  carton_text TEXT DEFAULT NULL,
  is_carton_highlight BOOLEAN NOT NULL DEFAULT FALSE,
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.cc_products DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 3. ORDERS TABLE (cc_orders)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.cc_orders (
  id TEXT PRIMARY KEY,
  order_number TEXT UNIQUE,
  customer_name TEXT NOT NULL,
  customer_email TEXT,
  customer_phone TEXT NOT NULL,
  delivery_address TEXT NOT NULL,
  city TEXT DEFAULT 'Abuja',
  state TEXT DEFAULT 'FCT',
  items JSONB NOT NULL DEFAULT '[]',
  subtotal NUMERIC NOT NULL DEFAULT 0,
  delivery_fee NUMERIC NOT NULL DEFAULT 0,
  total NUMERIC NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'Pending',
  payment_method TEXT DEFAULT 'Pay on Delivery',
  payment_status TEXT DEFAULT 'Pending',
  prescription_url TEXT,
  notes TEXT,
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.cc_orders DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. PRESCRIPTIONS TABLE (cc_prescriptions)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.cc_prescriptions (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  patient_name TEXT,
  doctor_name TEXT,
  prescription_url TEXT NOT NULL,
  status TEXT DEFAULT 'Under Review',
  verified_by TEXT,
  clinical_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.cc_prescriptions DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 5. VITALS TABLE (cc_vitals)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.cc_vitals (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id TEXT,
  systolic INT,
  diastolic INT,
  pulse INT,
  blood_glucose NUMERIC,
  oxygen_level NUMERIC,
  recorded_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.cc_vitals DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. PROFILES TABLE (cc_profiles)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.cc_profiles (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'customer',
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.cc_profiles DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 7. SEED CATEGORIES (cc_categories)
-- ============================================================================
INSERT INTO public.cc_categories (id, name, icon, description, item_count) VALUES
('cat-antimalarials', 'Antimalarials', 'healing', 'ACT combinations, malaria therapy, rapid tests', 12),
('cat-antibiotics', 'Antibiotics', 'medication', 'Broad spectrum oral & injectable antibacterial agents', 24),
('cat-cardio', 'Cardiovascular & BP', 'favorite', 'Hypertension management, cardiac care, insulin', 18),
('cat-vitamins', 'Vitamins & Immunity', 'health_and_safety', 'Daily multivitamins, minerals, immune support', 30),
('cat-devices', 'Health Devices', 'medical_services', 'Digital BP monitors, pulse oximeters, glucometers', 15),
('cat-consumables', 'Hospital Consumables', 'inventory_2', 'Sterile latex gloves, syringes, swabs, dressings', 45)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 8. SEED CORE COMFORTCARE PRODUCTS (cc_products)
-- ============================================================================
INSERT INTO public.cc_products (
  id, name, brand, generic_name, pack_size, price, wholesale_price, category,
  description, dosage_instructions, active_ingredients, nafdac_number,
  requires_prescription, is_cold_chain, storage_temp, stock, image_url,
  badge1, badge1_icon, badge2, badge2_icon, pack_label, carton_text, is_carton_highlight
) VALUES
(
  'prod-coartem-80-480',
  'Coartem 80/480mg',
  'Novartis',
  'Novartis • 6 Tablets',
  '6 Tablets Blister Pack',
  4200.0,
  3833.33,
  'Antimalarials',
  'Coartem is a fixed-dose artemisinin-based combination therapy (ACT) indicated for the clinical treatment of acute uncomplicated Plasmodium falciparum malaria infections.',
  'Take 1 tablet twice daily with fatty food or milk for 3 consecutive days (total of 6 tablets). Complete full course.',
  'Artemether (80 mg), Lumefantrine (480 mg)',
  'NAFDAC: 04-2011',
  false,
  false,
  'Store below 30°C in dry conditions',
  140,
  'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoLw9r-RmsXTnOXgJM3rXNLOWTp4aNanpbJT4yg1dHRH5bh8wBJw_eZkLeWPOHuZZ_kVoP-UXzPUtD-sfGLck1C3w9gjm4SZ56JuI0g4F_HK7Ob0BQbZ3Bi0BW4x66DmgyxUZGJx_OLz-TnFNPyQg49zsaiNsncvjT35QqHDYEHcDPjQ54vxtV0J_wBbh5rV6n2cXy_EKqVhLe6jV77o16zZPiZGVmHho2akb6gLVW1oRjZXo8o5CaNgYsVNmVvK3mQ',
  'In Stock',
  'verified',
  'NAFDAC: 04-2011',
  'verified',
  'Retail Pack',
  'Carton (30): ₦115,000',
  true
),
(
  'prod-omron-m2',
  'Omron M2 Basic BP',
  'Omron',
  'Upper Arm Digital',
  '1 Complete Device with Cuff',
  38500.0,
  32000.0,
  'Health Devices',
  'Clinically validated digital blood pressure monitor with Intellisense technology, hypertension indicator, and irregular heartbeat alert.',
  'Measure seated after 5 minutes of rest, morning and evening.',
  'Oscillometric Sensor, Clinical Validation Protocol',
  '3yr Warranty',
  false,
  false,
  'Store in protective case',
  35,
  'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=600&auto=format&fit=crop&q=80',
  'Device',
  'medical_services',
  '3yr Warranty',
  'verified_user',
  'Digital Monitor',
  'Free Delivery',
  true
),
(
  'prod-amoxil-500',
  'Amoxil 500mg',
  'GSK',
  'GSK • 20 Capsules',
  '20 Capsules Blister Pack',
  3600.0,
  2880.0,
  'Antibiotics',
  'Broad spectrum antibacterial therapy for respiratory tract, ENT, and dental bacterial infections.',
  'Take 1 capsule every 8 hours with plenty of water as directed by your physician.',
  'Amoxicillin (500 mg)',
  'NAFDAC Reg. No. 04-1120',
  true,
  false,
  'Store below 25°C in a cool dry place',
  110,
  'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
  'Rx Required',
  'prescriptions',
  'Wholesale Avail',
  'inventory_2',
  'Pack of 20',
  'Pack of 20',
  false
),
(
  'prod-latex-gloves',
  'Latex Gloves (100s)',
  'SafeTouch',
  'Powder-Free Medium',
  'Single Box (100 pcs)',
  6500.0,
  5800.0,
  'Hospital Consumables',
  'Medical sterile powder-free latex examination gloves with textured grip for healthcare procedures, clinic use, and patient care.',
  'Single use disposable gloves. Discard after each clinical examination.',
  'Natural Rubber Latex, Polymer Coated',
  'Clinic Grade',
  false,
  false,
  'Store in dry hospital stockroom',
  300,
  'https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=600&auto=format&fit=crop&q=80',
  'Bulk Deal',
  'inventory_2',
  'Clinic Grade',
  'verified',
  'Single Box (100 pcs)',
  'Carton: ₦58k',
  true
),
(
  'prod-augmentin-625',
  'Augmentin 625mg',
  'GSK',
  'Amoxicillin + Clavulanic Acid (14 Tabs)',
  '14 Film-Coated Tablets',
  7500.0,
  6200.0,
  'Antibiotics',
  'Broad spectrum antibacterial therapy for respiratory tract, urinary tract, and soft tissue bacterial infections.',
  'Take 1 tablet every 12 hours at the start of a meal as directed by your physician.',
  'Amoxicillin Trihydrate (500 mg), Potassium Clavulanate (125 mg)',
  'NAFDAC Reg. No. 04-2194',
  true,
  false,
  'Store below 25°C in moisture-proof foil',
  85,
  'https://lh3.googleusercontent.com/aida-public/AB6AXuCvRFtfhY1CZMrdW6GR2-AFf7eBxEjGi0yfEf-bdUQV5O_S-oj4eV5iV0WylJ1dM-2knDIf0oPguNIa4SGr7pmZHKHAuMQgNUFUW5VK1z0QY5W2RtE_b2D7zSLND7XlH5H0npyqlutF9FPCgW74_Gapenn7XZLj2_o6MvopsBRmdKAqqhUnQVMaU87Z959jC9WMAuimo9QPmEEO-U6aQjGnxUhqwQCaTgGdJn-x0jMJAeK10cph4Ec-',
  'Rx Required',
  'prescriptions',
  'Life Camp Hub',
  'pin_drop',
  'Retail Pack',
  'Doctor Rx validation at checkout',
  false
),
(
  'prod-emzor-paracetamol',
  'Emzor Paracetamol 500mg',
  'Emzor Nigeria',
  'Pain & Fever Relief (100 Tablets Dispenser)',
  '100 Tablets Dispenser',
  1200.0,
  950.0,
  'Vitamins & Immunity',
  'Antipyretic and analgesic symptom control for rapid relief of headache, feverish conditions, body pains, and chills.',
  'Take 2 tablets every 8 hours after food with water. Do not exceed 8 tablets in 24 hours.',
  'Paracetamol BP (500 mg)',
  'NAFDAC Approved 04-0125',
  false,
  false,
  'Store below 30°C in dry conditions',
  350,
  'https://lh3.googleusercontent.com/aida-public/AB6AXuCG62rWr9JxPQ9S2YUheX_IV-3Z7b3R-0iE31gDJAYwxN_ZujSybiUkPJ-lGbFumwZqaBqkz749PIdssh9GLR_Zh3RqLolYgmipDWk4YiVqtlUXFGJjcvV7dUMj5LCgiqEoEDDRy9QdCxjuCaORKcyjhgyon9Tm6M7yQf6lH-B1ap5BkzBQQEouCNunxIoDlzSL0-GXsf0GNJFvnDX27doXELYtgvFIbnw6vcwIWn2A1z1iWT03rkAq',
  'Everyday Essential',
  'verified',
  'NAFDAC Approved',
  'done_all',
  'Box Pack',
  'Wholesale outer carton available',
  true
),
(
  'prod-mixtard-insulin',
  'Mixtard 30/70 Insulin 100 IU/ml',
  'Novo Nordisk',
  'Biphasic Isophane Human Insulin',
  '10 ml Injectable Vial',
  14200.0,
  12100.0,
  'Cardiovascular & BP',
  'Premixed human insulin for diabetes mellitus glycemic control. Strictly transported under certified cold-chain protocol.',
  'Administer subcutaneously 30 minutes before meal according to individual endocrinologist prescription.',
  '30% Soluble Insulin, 70% Isophane Insulin',
  'NAFDAC Reg. No. 04-8910',
  true,
  true,
  'Strict Cold-Chain 2°C to 8°C (Do not freeze)',
  42,
  'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
  'Cold-Chain',
  'ac_unit',
  'Life Camp Hub',
  'pin_drop',
  '10ml Vial',
  'Strict Cold-Chain Direct Delivery',
  true
),
(
  'prod-panadol-extra',
  'Panadol Extra Tablets',
  'GlaxoSmithKline (GSK)',
  'Paracetamol 500mg + Caffeine 65mg',
  '10 Blister Packs (20 Tabs)',
  1850.0,
  1450.0,
  'Vitamins & Immunity',
  'Tough on pain, gentle on stomach. Formulated for fast relief of febrile pains, headache, and body aches.',
  'Take 1-2 tablets every 4-6 hours as needed. Do not exceed 8 tablets in 24 hours.',
  'Paracetamol (500 mg), Caffeine (65 mg)',
  'NAFDAC Reg. No. 04-0312',
  false,
  false,
  'Store below 30°C',
  220,
  'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
  'Fast Relief',
  'flash_on',
  'NAFDAC Verified',
  'verified',
  'Retail Pack',
  '20 Strips outer carton available',
  false
),
(
  'prod-carestart-rdt',
  'CareStart Malaria RDT Kit',
  'Access Bio',
  'Single Antigen Cassette Test',
  '1 Test Cassette + Lancet + Buffer',
  1800.0,
  1400.0,
  'Antimalarials',
  'Point-of-care rapid diagnostic test for qualitative detection of Plasmodium falciparum histidine-rich protein 2 in fingerstick whole blood.',
  'Collect 5µL blood using provided capillary pipette, apply to well A, add 2 drops buffer to well B. Read results at 15 minutes.',
  'P. falciparum HRP-2 Monoclonal Antibodies',
  'WHO Pre-qualified',
  false,
  false,
  'Store 1°C - 40°C',
  95,
  'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=500&auto=format&fit=crop&q=60',
  'Rapid Test',
  'biotech',
  'WHO Pre-qualified',
  'verified_user',
  'Single Test Kit',
  'Box of 25 available',
  false
),
(
  'prod-glucerna-sr',
  'Glucerna SR Vanilla 400g',
  'Abbott',
  'Diabetes Specific Nutrition Formula',
  '400g Powder Canister',
  16500.0,
  14200.0,
  'Cardiovascular & BP',
  'Complete, balanced nutritional formula scientifically designed for people with diabetes or impaired glucose tolerance.',
  'Mix 5 level scoops with 200ml cold water. Consume as meal replacement or healthy clinical snack.',
  'Slow-release Carbohydrate Blend (Fibregers), MUFA, Chromium, Myo-inositol',
  'NAFDAC Reg. No. 04-7123',
  false,
  false,
  'Store unopened can at room temperature',
  60,
  'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
  'Diabetic Formula',
  'monitor_heart',
  'Abbott Nutrition',
  'verified',
  '400g Canister',
  'Carton of 6: ₦88,000',
  true
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  brand = EXCLUDED.brand,
  generic_name = EXCLUDED.generic_name,
  pack_size = EXCLUDED.pack_size,
  price = EXCLUDED.price,
  wholesale_price = EXCLUDED.wholesale_price,
  category = EXCLUDED.category,
  description = EXCLUDED.description,
  dosage_instructions = EXCLUDED.dosage_instructions,
  active_ingredients = EXCLUDED.active_ingredients,
  nafdac_number = EXCLUDED.nafdac_number,
  requires_prescription = EXCLUDED.requires_prescription,
  is_cold_chain = EXCLUDED.is_cold_chain,
  storage_temp = EXCLUDED.storage_temp,
  stock = EXCLUDED.stock,
  image_url = EXCLUDED.image_url,
  badge1 = EXCLUDED.badge1,
  badge1_icon = EXCLUDED.badge1_icon,
  badge2 = EXCLUDED.badge2,
  badge2_icon = EXCLUDED.badge2_icon,
  pack_label = EXCLUDED.pack_label,
  carton_text = EXCLUDED.carton_text,
  is_carton_highlight = EXCLUDED.is_carton_highlight,
  updated_at = timezone('utc'::text, now());

-- Reload schema cache in PostgREST
NOTIFY pgrst, 'reload schema';
