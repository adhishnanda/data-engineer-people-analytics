-- =========================================================
-- 06_cumulative_hires_by_source.sql
-- Cumulative Hires by Source
-- =========================================================

-- Assumption:
-- Since there is no explicit final "hired" status in the schema,
-- a successful hire is defined as:
--   decision_date IS NOT NULL
--   AND at least one associated interview outcome = 'Passed'

with successful_applications as (
    select distinct
        a.app_id,
        a.candidate_id,
        c.source,
        date_trunc('month', a.decision_date)::date as decision_month
    from raw_applications a
    join raw_candidates c
        on a.candidate_id = c.candidate_id
    join stg_interviews_deduplicated i
        on a.app_id = i.app_id
    where a.decision_date is not null
      and i.outcome = 'Passed'
      and date_part('year', a.decision_date) = date_part('year', current_date)
),
monthly_hires as (
    select
        source,
        decision_month,
        count(distinct app_id) as hires_in_month
    from successful_applications
    group by source, decision_month
)
select
    source,
    decision_month,
    hires_in_month,
    sum(hires_in_month) over (
        partition by source
        order by decision_month
        rows between unbounded preceding and current row
    ) as cumulative_hires
from monthly_hires
order by source, decision_month;