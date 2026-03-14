-- =========================================================
-- 05_monthly_active_pipeline.sql
-- Monthly Active Pipeline
-- =========================================================

-- Definition:
-- An application is active in a month if that month falls between:
--   applied_date
--   decision_date
-- If decision_date is null, we treat the application as active until current_date.

with application_month_expansion as (
    select
        a.app_id,
        generate_series(
            date_trunc('month', a.applied_date)::date,
            date_trunc('month', coalesce(a.decision_date, current_date))::date,
            interval '1 month'
        )::date as reporting_month
    from raw_applications a
)
select
    reporting_month,
    count(distinct app_id) as active_applications
from application_month_expansion
group by reporting_month
order by reporting_month;