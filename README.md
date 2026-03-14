# Data Engineer Intern Task: People & HR Analytics

This repository contains my solution for the **Data Engineer Intern technical assessment** in the **People / HR Analytics** domain.

The solution focuses on:

- data cleaning and deduplication
- data quality validation
- dimensional-style data mart construction
- advanced analytical SQL for hiring pipeline reporting

---

## Repository Structure

```text
data-engineer-people-analytics/
├── README.md
└── sql/
    ├── 01_schema_and_notes.sql
    ├── 02_deduplicate_interviews.sql
    ├── 03_data_quality_checks.sql
    ├── 04_dm_hiring_process.sql
    ├── 05_monthly_active_pipeline.sql
    └── 06_cumulative_hires_by_source.sql
```

---

# Task 1: Motivation & Vision

The written answer for the motivation question is provided on the website.

---

# Task 2: Technical Implementation

## Source Tables

The task assumes the following raw source tables from the ATS:

- `raw_candidates`
- `raw_applications`
- `raw_interviews`

---

## Part A: Data Cleaning & Modeling (ETL)

The SQL solution performs the following:

### 1. Deduplication of `raw_interviews`

Duplicates are defined as records with the same:

- `app_id`
- `interview_date`
- `outcome`

The solution keeps only the first row using `ROW_NUMBER()`.

### 2. Data Quality Checks

The solution includes SQL checks for:

- interview date before application date
- decision date before application date
- applications linked to missing candidates
- interviews linked to missing applications
- invalid or missing salary values
- unexpected role levels
- unexpected interview outcomes

### 3. Final Data Mart

A final view named: `dm_hiring_process` is created.

Each row represents one application and includes:

- candidate name
- candidate source
- profile created date
- role level
- applied date
- decision date
- expected salary
- time-to-decision in days
- total number of passed interviews

---

# Part B: Advanced Analytical SQL

## 1. Monthly Active Pipeline

The solution generates a row for every month an application was active.

Definition used:

An application is active in a reporting month if that month falls between:

- `applied_date`
- `decision_date`

If `decision_date` is null, the application is treated as active through `current_date`.

This is implemented using `generate_series()` and monthly date expansion.

## 2. Cumulative Hires by Source

The solution calculates monthly hires by candidate source and then computes a cumulative total over time.

### Important Assumption

The provided schema does **not** contain an explicit final `hired` status.

Therefore, I define a successful hire as:

- `decision_date IS NOT NULL`
- and at least one associated interview with `outcome = 'Passed'`

This assumption is made explicitly so that the cumulative hires metric can be computed consistently.

---

# SQL Dialect

The solution is written in **PostgreSQL-style SQL**.

It uses common SQL features such as:

- CTEs
- window functions
- `generate_series()`
- date truncation
- conditional logic

---

# Notes on Design Choices

## Why a view for deduplicated interviews?

A staging view keeps the cleaning logic transparent and reusable. It also separates raw data from cleaned analytical logic.

## Why a view for the data mart?

Using a view for `dm_hiring_process` makes the final business-ready table easy to query and easy to validate.

## Why explicit data quality checks?

In HR analytics, logical consistency is important because pipeline metrics can be misleading if dates or joins are wrong.

---

# How This Could Be Extended

In a production environment, this solution could be extended with:

- dbt models for testing and documentation
- Airflow orchestration
- incremental loading
- slowly changing dimensions for candidate attributes
- a proper fact/dimension warehouse design
- explicit hiring status events from the ATS

# Example Outputs

---

# Example Output: Data Mart

### `dm_hiring_process`

| app_id | full_name | source | role_level | applied_date | decision_date | time_to_decision_days | passed_interviews_count |
|---|---|---|---|---|---|---|---|
| 101 | Alice Smith | LinkedIn | Senior | 2024-01-10 | 2024-01-25 | 15 | 2 |
| 102 | Rahul Verma | Referral | Junior | 2024-02-05 | 2024-02-18 | 13 | 1 |
| 103 | Emma Chen | Career Page | Executive | 2024-02-20 | NULL | NULL | 1 |

**Explanation:**

- Each row represents **one application**
- Includes **candidate details**
- Includes **time to decision**
- Includes **number of successful interviews**

---

# Example Output: Monthly Active Pipeline

| reporting_month | active_applications |
|---|---|
| 2024-01-01 | 3 |
| 2024-02-01 | 5 |
| 2024-03-01 | 4 |

**Explanation:**

Applications remain active from:

`applied_date → decision_date`

If a decision has not yet been made, the application is treated as active until **current date**.

---

# Example Output: Cumulative Hires by Source

| source | decision_month | hires_in_month | cumulative_hires |
|---|---|---|---|
| LinkedIn | 2024-01-01 | 1 | 1 |
| LinkedIn | 2024-02-01 | 2 | 3 |
| Referral | 2024-01-01 | 1 | 1 |
| Referral | 2024-03-01 | 1 | 2 |

**Explanation:**

This allows recruiters to understand:

- which channels produce hires
- growth of hires over time
- hiring funnel efficiency

---

**Note:**

The outputs shown above are **illustrative examples**, since the task description does not provide an actual dataset. 
They demonstrate the expected structure and interpretation of the SQL query results.
