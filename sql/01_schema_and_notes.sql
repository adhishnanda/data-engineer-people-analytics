-- =========================================================
-- 01_schema_and_notes.sql
-- PostgreSQL-style SQL
-- =========================================================

-- This file documents the assumed raw source tables.
-- The raw tables are assumed to already exist:
-- raw_candidates
-- raw_applications
-- raw_interviews

-- The task is solved by:
-- 1. Deduplicating raw_interviews
-- 2. Writing data quality checks
-- 3. Building a final data mart: dm_hiring_process
-- 4. Writing analytical SQL for pipeline and cumulative hires

-- Important assumption:
-- The schema does not include an explicit final "hired" status.
-- Therefore, for the cumulative hires metric, a successful hire is
-- defined as:
--   decision_date IS NOT NULL
--   AND at least one associated interview outcome = 'Passed'
--
-- This assumption is explicitly documented in the README.md file.