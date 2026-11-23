-- Migration: 001_init.sql
-- Deskripsi: Inisialisasi skema tabel kos dan kebijakan Row Level Security (RLS)

-- 1. Buat tabel kos
CREATE TABLE IF NOT EXISTS public.kos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    area TEXT NOT NULL,
    address TEXT NOT NULL,
    description TEXT NOT NULL,
    price_per_month BIGINT NOT NULL CHECK (price_per_month > 0),
    gender_type TEXT NOT NULL CHECK (gender_type IN ('putra', 'putri', 'campur')),
    has_wifi BOOLEAN NOT NULL DEFAULT false,
    has_ac BOOLEAN NOT NULL DEFAULT false,
    has_private_bathroom BOOLEAN NOT NULL DEFAULT false,
    includes_electricity BOOLEAN NOT NULL DEFAULT false,
    whatsapp_number TEXT NOT NULL,
    available_rooms INTEGER NOT NULL DEFAULT 1 CHECK (available_rooms >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Index untuk mendukung query pencarian, filter, dan relasi pemilik
CREATE INDEX IF NOT EXISTS idx_kos_price ON public.kos (price_per_month);
CREATE INDEX IF NOT EXISTS idx_kos_area ON public.kos (area);
CREATE INDEX IF NOT EXISTS idx_kos_owner_id ON public.kos (owner_id);

-- 3. Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- 4. Kebijakan Keamanan RLS

-- US01: Siapa saja (publik / unauthenticated maupun authenticated) dapat melihat daftar dan detail kos
CREATE POLICY "Publik dapat melihat seluruh data kos"
ON public.kos
FOR SELECT
USING (true);

-- US05: Hanya pemilik terautentikasi yang dapat menambah kos miliknya sendiri
CREATE POLICY "Pemilik kos dapat menambahkan data kos"
ON public.kos
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

-- US06: Hanya pemilik kos yang berhak mengubah kos miliknya sendiri
CREATE POLICY "Pemilik kos dapat mengubah kos miliknya"
ON public.kos
FOR UPDATE
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- US07: Hanya pemilik kos yang berhak menghapus kos miliknya sendiri
CREATE POLICY "Pemilik kos dapat menghapus kos miliknya"
ON public.kos
FOR DELETE
TO authenticated
USING (auth.uid() = owner_id);
