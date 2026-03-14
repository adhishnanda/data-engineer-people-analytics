-- =========================================================
-- 04_dm_hiring_process.sql
-- Create final data mart: dm_hiring_process
-- =========================================================

drop view if exists dm_hiring_process;

create view dm_hiring_process as
with passed_interviews as (
    select
        app_id,
        count(*) as passed_interviews_count
    from stg_interviews_deduplicated
    where outcome = 'Passed'
    group by app_id
)
select
    a.app_id,
    a.candidate_id,
    c.full_name,
    c.source,
    c.profile_created_date,
    a.role_level,
    a.applied_date,
    a.decision_date,
    a.expected_salary,
    case
        when a.decision_date is not null
        then (a.decision_date - a.applied_date)
        else null
    end as time_to_decision_days,
    coalesce(pi.passed_interviews_count, 0) as passed_interviews_count
from raw_applications a
join raw_candidates c
    on a.candidate_id = c.candidate_id
left join passed_interviews pi
    on a.app_id = pi.app_id;