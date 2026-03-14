-- =========================================================
-- 03_data_quality_checks.sql
-- Data quality checks
-- =========================================================

-- 1. Interviews before application date
select
    i.interview_id,
    i.app_id,
    i.interview_date,
    a.applied_date
from stg_interviews_deduplicated i
join raw_applications a
    on i.app_id = a.app_id
where i.interview_date < a.applied_date;

-- 2. Decision date before applied date
select
    app_id,
    candidate_id,
    applied_date,
    decision_date
from raw_applications
where decision_date is not null
  and decision_date < applied_date;

-- 3. Applications linked to missing candidates
select
    a.app_id,
    a.candidate_id
from raw_applications a
left join raw_candidates c
    on a.candidate_id = c.candidate_id
where c.candidate_id is null;

-- 4. Interviews linked to missing applications
select
    i.interview_id,
    i.app_id
from stg_interviews_deduplicated i
left join raw_applications a
    on i.app_id = a.app_id
where a.app_id is null;

-- 5. Invalid or suspicious salary values
select
    app_id,
    candidate_id,
    expected_salary
from raw_applications
where expected_salary is null
   or expected_salary <= 0;

-- 6. Unexpected role levels
select
    app_id,
    role_level
from raw_applications
where role_level not in ('Junior', 'Senior', 'Executive');

-- 7. Unexpected interview outcomes
select
    interview_id,
    app_id,
    outcome
from stg_interviews_deduplicated
where outcome not in ('Passed', 'Rejected', 'No Show');