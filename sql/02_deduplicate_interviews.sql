-- =========================================================
-- 02_deduplicate_interviews.sql
-- Deduplicate raw_interviews
-- =========================================================

-- Assumption:
-- A duplicate interview record is defined as the same:
--   app_id
--   interview_date
--   outcome
--
-- We keep the first record by interview_id.

drop view if exists stg_interviews_deduplicated;

create view stg_interviews_deduplicated as
with ranked_interviews as (
    select
        interview_id,
        app_id,
        interview_date,
        outcome,
        row_number() over (
            partition by app_id, interview_date, outcome
            order by interview_id
        ) as rn
    from raw_interviews
)
select
    interview_id,
    app_id,
    interview_date,
    outcome
from ranked_interviews
where rn = 1;