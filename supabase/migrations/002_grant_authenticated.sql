-- Migration: 002_grant_authenticated.sql
-- Deskripsi: Memberikan hak akses DML tabel kos kepada role authenticated dan anon

GRANT SELECT ON public.kos TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kos TO authenticated;
