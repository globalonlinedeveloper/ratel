-- Ratel — Migration 002: persist completed lesson codes on the profile.
-- Run this once in the Supabase SQL Editor (same place you ran the schema).
-- Adds a text[] column to public.profiles to store which lessons a user
-- has completed (by app lesson code, e.g. 'u1l1'). RLS already protects it.

alter table public.profiles
  add column if not exists completed_lessons text[] not null default '{}';
