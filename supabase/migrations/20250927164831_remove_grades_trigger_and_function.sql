-- Migration: Remove grades automatic updated_at trigger and function
-- Date: 2025-09-27
--
-- This migration removes the automatic trigger and function that was previously
-- handling the updated_at and updated_by fields for the grades table.
--
-- IMPORTANT: After this migration, the frontend application MUST handle
-- the following fields manually when creating or updating grades records:
--
-- - created_at: Should be set to current timestamp on creation
-- - updated_at: Should be set to current timestamp on both creation and updates
-- - created_by: Should be set to current user ID on creation
-- - updated_by: Should be set to current user ID on both creation and updates
--
-- These fields are no longer automatically managed by database triggers.

-- Drop the trigger first
DROP TRIGGER IF EXISTS trigger_grades_updated_at ON public.grades;

-- Drop the function
DROP FUNCTION IF EXISTS public.handle_grades_updated_at();