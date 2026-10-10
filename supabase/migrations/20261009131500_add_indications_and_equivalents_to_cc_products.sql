-- Migration: Add structured AI clinical indications and equivalent drugs to cc_products
-- These columns empower Dr. Comfort AI to ground suggestions, find equivalents, and answer clinical questions.

ALTER TABLE public.cc_products 
ADD COLUMN IF NOT EXISTS indications TEXT DEFAULT '';

ALTER TABLE public.cc_products 
ADD COLUMN IF NOT EXISTS equivalent_drugs TEXT DEFAULT '';

-- Add helpful comment
COMMENT ON COLUMN public.cc_products.indications IS 'Medical conditions, symptoms, and cases where this drug is indicated';
COMMENT ON COLUMN public.cc_products.equivalent_drugs IS 'Alternative brands and generic equivalent medications doing the same medical work';
