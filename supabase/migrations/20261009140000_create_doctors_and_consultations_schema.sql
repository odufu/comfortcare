-- Migration: 20261009140000_create_doctors_and_consultations_schema.sql
-- Description: Creates tables for Doctors, Telehealth Consultation Sessions, and Consultant Reviews

-- 1. CC_DOCTORS Table
CREATE TABLE IF NOT EXISTS public.cc_doctors (
    id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT NOT NULL,
    license_number TEXT NOT NULL UNIQUE,
    specialty TEXT NOT NULL,
    qualifications TEXT NOT NULL,
    hospital_affiliation TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    consultation_fee NUMERIC(12, 2) NOT NULL DEFAULT 5000.00,
    rating NUMERIC(3, 2) NOT NULL DEFAULT 5.00,
    review_count INTEGER NOT NULL DEFAULT 0,
    is_available BOOLEAN NOT NULL DEFAULT true,
    is_video_enabled BOOLEAN NOT NULL DEFAULT true,
    is_audio_enabled BOOLEAN NOT NULL DEFAULT true,
    specializations TEXT[] DEFAULT '{}',
    experience_years INTEGER NOT NULL DEFAULT 5,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. CC_CONSULTATION_SESSIONS Table
CREATE TABLE IF NOT EXISTS public.cc_consultation_sessions (
    id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    patient_name TEXT NOT NULL,
    doctor_id TEXT NOT NULL REFERENCES public.cc_doctors(id) ON DELETE CASCADE,
    doctor_name TEXT NOT NULL,
    chief_complaint TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'waiting', -- waiting, active, completed, cancelled
    call_type TEXT NOT NULL DEFAULT 'video', -- video, audio
    channel_name TEXT NOT NULL,
    rating INTEGER,
    feedback TEXT,
    notes TEXT,
    scheduled_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3. CC_DOCTOR_REVIEWS Table
CREATE TABLE IF NOT EXISTS public.cc_doctor_reviews (
    id TEXT PRIMARY KEY,
    doctor_id TEXT NOT NULL REFERENCES public.cc_doctors(id) ON DELETE CASCADE,
    patient_id TEXT NOT NULL,
    patient_name TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Indices for rapid querying
CREATE INDEX IF NOT EXISTS idx_cc_doctors_specialty ON public.cc_doctors(specialty);
CREATE INDEX IF NOT EXISTS idx_cc_doctors_availability ON public.cc_doctors(is_available);
CREATE INDEX IF NOT EXISTS idx_cc_sessions_doctor ON public.cc_consultation_sessions(doctor_id);
CREATE INDEX IF NOT EXISTS idx_cc_sessions_patient ON public.cc_consultation_sessions(patient_id);
CREATE INDEX IF NOT EXISTS idx_cc_reviews_doctor ON public.cc_doctor_reviews(doctor_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.cc_doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cc_consultation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cc_doctor_reviews ENABLE ROW LEVEL SECURITY;

-- Permissive public read access for doctors and reviews
CREATE POLICY "Public read cc_doctors" ON public.cc_doctors FOR SELECT USING (true);
CREATE POLICY "Public read cc_doctor_reviews" ON public.cc_doctor_reviews FOR SELECT USING (true);
CREATE POLICY "Public insert cc_doctor_reviews" ON public.cc_doctor_reviews FOR INSERT WITH CHECK (true);
CREATE POLICY "Public access cc_consultation_sessions" ON public.cc_consultation_sessions FOR ALL USING (true);
CREATE POLICY "Public manage cc_doctors" ON public.cc_doctors FOR ALL USING (true);

-- Seed Abuja MDCN Certified Specialists
INSERT INTO public.cc_doctors (
    id, full_name, email, phone, license_number, specialty, qualifications, hospital_affiliation,
    avatar_url, bio, consultation_fee, rating, review_count, is_available, is_video_enabled, is_audio_enabled,
    specializations, experience_years
) VALUES
(
    'doc-abj-01',
    'Dr. Chinedu Eze',
    'doctor@comfortcare.ng',
    '+234 803 112 4455',
    'MDCN-61842-FMC',
    'Infectious Diseases & Tropical Medicine',
    'MBBS, FWACP, MSc Tropical Med (London)',
    'National Hospital Abuja & ComfortCare Telehealth',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
    'Senior Consultant specializing in severe malaria, typhoid, respiratory fevers, and antimicrobial stewardship.',
    6500.00,
    4.95,
    148,
    true,
    true,
    true,
    ARRAY['Malaria', 'Typhoid', 'Infectious Diseases', 'Antibiotics', 'Fever', 'Sepsis'],
    14
),
(
    'doc-abj-02',
    'Dr. Fatima Al-Hassan',
    'dr.fatima@comfortcare.ng',
    '+234 802 889 0123',
    'MDCN-74219-PED',
    'Pediatrics & Child Health',
    'MBBS (Ib), FMCPaed, Fellow Neonatology',
    'Maitama District Hospital, Abuja',
    'https://images.unsplash.com/photo-1594824813583-a7d519bdf0e9?w=400&auto=format&fit=crop&q=80',
    'Compassionate pediatrician treating infants, toddlers, and adolescents for acute fevers, respiratory infections, and neonatal care.',
    5000.00,
    4.92,
    215,
    true,
    true,
    true,
    ARRAY['Pediatrics', 'Child Health', 'Infant Fever', 'Neonatal Care', 'Asthma in Children', 'Vaccinations'],
    11
),
(
    'doc-abj-03',
    'Dr. Babatunde Adeleke',
    'dr.adeleke@comfortcare.ng',
    '+234 805 443 2190',
    'MDCN-52908-CAR',
    'Cardiology & Internal Medicine',
    'MBBS, FMCP (Cardio), FACC',
    'Cedarcrest Hospitals, Apo Dutse, Abuja',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=80',
    'Interventional cardiologist focusing on resistant hypertension, heart failure, lipid management, and preventive heart health.',
    8000.00,
    4.89,
    172,
    true,
    true,
    true,
    ARRAY['Cardiology', 'Hypertension', 'Chest Pain', 'Heart Failure', 'Dyslipidemia', 'High Blood Pressure'],
    16
),
(
    'doc-abj-04',
    'Dr. Zainab Mustapha',
    'dr.zainab@comfortcare.ng',
    '+234 809 334 1177',
    'MDCN-81045-END',
    'Endocrinology & Diabetology',
    'MBBS, FWACP (Endocrinology)',
    'Garki Hospital, Area 8, Abuja',
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80',
    'Expert endocrinologist specializing in Type 1 & 2 Diabetes, insulin regimen tuning, gestational diabetes, and thyroid disorders.',
    6000.00,
    4.94,
    134,
    true,
    true,
    true,
    ARRAY['Diabetes', 'Insulin Management', 'Thyroid Disorders', 'Metabolic Syndrome', 'Endocrinology'],
    10
),
(
    'doc-abj-05',
    'Dr. Emeka Okonkwo',
    'dr.emeka@comfortcare.ng',
    '+234 806 778 9901',
    'MDCN-49112-MED',
    'Family Medicine & General Practice',
    'MBBS, FMCGP',
    'Wuse District Hospital, Abuja',
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&auto=format&fit=crop&q=80',
    'Primary care physician delivering comprehensive acute and chronic disease management, general checkups, and triage.',
    4500.00,
    4.88,
    310,
    true,
    true,
    true,
    ARRAY['General Practice', 'Family Medicine', 'Headache', 'Flu & Cold', 'Health Screening', 'Primary Care'],
    12
),
(
    'doc-abj-06',
    'Dr. Halima Bello',
    'dr.halima@comfortcare.ng',
    '+234 803 992 0044',
    'MDCN-68340-OBS',
    'Obstetrics & Gynecology',
    'MBBS, FWACS (OB-GYN)',
    'Federal Medical Centre, Jabi, Abuja',
    'https://images.unsplash.com/photo-1594824813616-56540c49fc09?w=400&auto=format&fit=crop&q=80',
    'Women’s health specialist focusing on antenatal guidance, menstrual health, PCOS, and high-risk pregnancy telehealth consultations.',
    7000.00,
    4.96,
    188,
    true,
    true,
    true,
    ARRAY['Obstetrics', 'Gynecology', 'Pregnancy', 'Antenatal Care', 'PCOS', 'Women Health'],
    15
)
ON CONFLICT (id) DO NOTHING;
