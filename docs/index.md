# Avanti Finance: Snowflake AI Workshop

Welcome! Today we run the same loan reconciliation three ways:

1. **SQL**: write it by hand, step by step
2. **CoCo** (Cortex Code): let the AI write the SQL with you
3. **CoWork**: ask questions in plain English, get charts and a sign-off pack

> Snowflake does the heavy lifting. Excel does the thinking.

## Log in

1. Open **https://avantifinance-data.snowflakecomputing.com**
2. Sign in with your Avanti Microsoft account (SSO)
3. Check your role is **DMP_SNOWFLAKE_AI_TRAINING** (bottom-left, under your name)

!!! tip "Can't log in?"
    Try **https://app.snowflake.com/avantifinance**, or flag one of the facilitators.

## The data

| Table | What it holds |
|---|---|
| `SALES_INTELLIGENCE.DATA.TEST_LOAN_APPLICATION` | Every loan application, Jan–Jun 2026 |
| `SALES_INTELLIGENCE.DATA.TEST_LOAN_ACCOUNT` | Every loan booked in the loan system (test data) |

The two tables are linked by `APPLICATION_ID`.

## Agenda

| Part | Page |
|---|---|
| SQL basics and the reconciliation | [SQL basics & recon](sql_basics.md) |
| CoWork reconciliation investigation | [CoWork reconciliation](cowork_recon.md) |
| Recap and next steps | [Wrap-up](wrap_up.md) |
