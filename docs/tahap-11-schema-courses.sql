-- Tahap 11: Dokumentasi schema tabel courses
-- Schema telah dibuat dan diverifikasi di Supabase Dashboard.

-- Kolom:
-- id         : bigint identity, primary key
-- code       : text, unique, not null
-- title      : text, not null
-- credits    : integer, not null
-- status     : text, not null, default 'planned'
-- created_at : timestamptz, not null, default now()

-- CHECK constraint:
-- status IN ('planned', 'active', 'done')

-- Row Level Security:
-- Enabled pada public.courses.

-- Policy yang telah diverifikasi:
-- Lab allow read courses
-- SELECT TO anon, authenticated USING (true).

-- Data awal:
-- IF101 | Algoritma dan Pemrograman | 3 | active
-- IF102 | Basis Data                | 3 | planned
-- IF103 | Pemrograman Mobile        | 3 | planned
