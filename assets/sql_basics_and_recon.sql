/* =============================================================================
   Avanti workshop: SQL basics, then the loan reconciliation

   Tables (sales_intelligence.data):
     test_loan_application : every loan application (398 rows, Jan-Jun 2026)
     test_loan_account     : every loan booked in the loan system (261 rows)
     The two tables are linked by application_id.

   Run each statement one at a time (place the cursor on it and press
   Cmd/Ctrl + Enter).

   Style: dbt conventions. Lowercase keywords and names, one column per
   line, trailing commas, explicit "as" aliases, descriptive table aliases.
   (Snowflake isn't case sensitive, so lowercase and UPPERCASE run the same.)

   CoCo prompts: after each query there's a "CoCo prompt" box. Each phrase in
   the prompt maps to a part of the SQL, shown as [from], [select], [where]...
   A good prompt names: the table, the columns, the filters, the grouping,
   the sort and the row limit. The same things you'd write in SQL.
============================================================================= */

-- Setup: who am I, what compute am I using, where is the data
use role dmp_snowflake_ai_training;
use warehouse sales_intelligence_wh;
use schema sales_intelligence.data;


/* -----------------------------------------------------------------------------
   1. select *  : "show me the data"
   Excel: opening the sheet and scrolling the first few rows.
   - *      = every column
   - limit  = only return the first N rows (good habit on big tables)
----------------------------------------------------------------------------- */
-- Notice: date_received is a real date, but month ('2026-01 Jan') is just a
-- text label. Use date_received for any date logic; text won't sort or
-- compare like a date.
select *
from test_loan_application
limit 10;

/* CoCo prompt ------------------------------------------------------------
   "From test_loan_application [from], show all columns [select *]
    for the first 10 rows [limit]."
   Tip: name the table exactly. "Show me the loan data" makes CoCo guess.
-------------------------------------------------------------------------- */

-- Notice: application_id is in both tables. That's how we'll link them later.
-- Notice: booked_date is also a real date, so we can compare it with
-- date_received from the applications table.
select *
from test_loan_account
limit 10;

/* CoCo prompt ------------------------------------------------------------
   "From test_loan_account [from], show all columns [select *]
    for the first 10 rows [limit]. Which columns does it share with
    test_loan_application?"
   Tip: asking what the tables have in common gets CoCo to find the join key.
-------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
   2. Named columns + where + order by  : "filter and sort"
   Excel: hide columns, use the filter dropdown, sort largest to smallest.
   - List only the columns you need
   - where keeps rows that meet the condition (text goes in 'single quotes')
   - and means both conditions must be true
   - order by ... desc sorts largest first
----------------------------------------------------------------------------- */
select
    application_id,
    product,
    channel,
    loan_amount,
    status
from test_loan_application
where
    status = 'Approved'
    and product = 'Personal Loan'
order by loan_amount desc
limit 5;
-- Expected: top row LA-2026-0059 at $4,850,000. A $4.85M personal loan?
-- Everything else tops out near $50k. Remember this one for the recon.

/* CoCo prompt ------------------------------------------------------------
   "From test_loan_application [from], show application_id, product,
    channel, loan_amount and status [select], only for applications where
    status is 'Approved' and product is 'Personal Loan' [where],
    sorted by loan_amount largest first [order by desc],
    top 5 only [limit]."
   Tip: give exact filter values in quotes. "Approved personal loans" may
   work, but 'Approved' and 'Personal Loan' leave nothing to guess.
-------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
   3. group by + aggregations  : "summarise"
   Excel: a pivot table.
   - count(*) counts rows, sum adds up, avg averages, round tidies decimals
   - as gives a column a friendly name (an alias)
   - Every column in select is either in group by or inside an aggregate
----------------------------------------------------------------------------- */
select
    product,
    count(*) as applications,
    sum(loan_amount) as total_amount,
    round(avg(processing_days), 1) as avg_processing_days
from test_loan_application
where status = 'Approved'
group by product
order by total_amount desc;
-- Expected: 4 rows. Personal Loan 99, Vehicle Loan 74, Property Lending 51,
-- Business Loan 42. Look at the Personal Loan total ($6.4M): one $4.85M
-- "personal loan" (LA-2026-0059) is almost certainly a keying error. Totals
-- hide this; max(loan_amount) or sorting by loan_amount finds it.
-- Total approved = 266. Keep that number in mind for the joins.

/* CoCo prompt ------------------------------------------------------------
   "From test_loan_application [from], for applications where status is
    'Approved' [where], show for each product [group by] the number of
    applications, total loan_amount and average processing_days rounded to
    1 decimal [select + aggregates], sorted by total amount largest first
    [order by]."
   Tip: "for each X" or "by X" = group by. Say which calculation you want
   (count, total, average). "Summarise by product" leaves CoCo to choose.
   Follow-up to try: "Are there any loan amounts that look unusual for their product?"
   Another: "Group by channel. Do any channel values look wrong?" (4 rows
   have product or channel names in the wrong column, e.g. channel =
   'Business Loan'. A real data-entry issue in the source file.)
-------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
   4. inner join  : "match the two systems"
   Excel: XLOOKUP the application ID into the loan sheet, then keep ONLY the
   rows that found a match.
   - applications and accounts are aliases (short names) for the two tables
   - applications.loan_amount vs accounts.loan_amount: both tables have that
     column, so we must say which one we mean
   - on is the matching rule
----------------------------------------------------------------------------- */
select
    count(*) as matched_rows,
    sum(applications.loan_amount) as application_amount,
    sum(accounts.loan_amount) as booked_amount
from test_loan_application as applications
inner join test_loan_account as accounts
    on applications.application_id = accounts.application_id
where applications.status = 'Approved';
-- Expected: 253 rows (not 266!). An inner join SILENTLY DROPS approved
-- applications that have no booked loan. They just vanish from the report.

/* CoCo prompt ------------------------------------------------------------
   "Join test_loan_application to test_loan_account [from + join] on
    application_id [on], using an inner join so only matching rows are
    kept [inner join]. Only include applications where status is
    'Approved' [where]. Show the number of matched rows, total application
    loan_amount and total booked loan_amount [select + aggregates]."
   Tip: always say the join key AND the join type. If you don't, CoCo picks
   one, and as this step shows, the join type changes the answer.
-------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
   5. left join  : "what's missing?"
   Excel: XLOOKUP, then filter for #N/A.
   - left join keeps EVERY row from the left (first) table
   - Where there's no match, the right-hand columns come back as null
     (SQL's version of #N/A)
   - count(*) counts all rows; count(column) skips nulls
----------------------------------------------------------------------------- */
select
    count(*) as approved_rows,
    count(accounts.loan_account_id) as booked,
    count(*) - count(accounts.loan_account_id) as not_booked
from test_loan_application as applications
left join test_loan_account as accounts
    on applications.application_id = accounts.application_id
where applications.status = 'Approved';
-- Expected: 266 approved, 253 booked, 13 not booked.
-- Same tables, same filter. Changing inner to left kept every approved row.
-- The join type changes the answer.

/* CoCo prompt ------------------------------------------------------------
   "Left join test_loan_application to test_loan_account [from + left join]
    on application_id [on], keeping every application even if it has no
    booked loan. Only include applications where status is 'Approved'
    [where]. Show the total approved rows, how many have a booked loan, and
    how many don't [select + count]."
   Tip: "keeping every row from X even if there's no match" is plain-English
   for left join. Useful if you forget the SQL term.
-------------------------------------------------------------------------- */

-- List the 13: "is null" finds the rows where no loan matched
select
    applications.application_id,
    applications.product,
    applications.loan_amount,
    applications.date_received,
    accounts.loan_account_id  -- null on every row = never booked
from test_loan_application as applications
left join test_loan_account as accounts
    on applications.application_id = accounts.application_id
where
    applications.status = 'Approved'
    and accounts.loan_account_id is null;

/* CoCo prompt ------------------------------------------------------------
   "Using the same left join, list [select] application_id, product,
    loan_amount, date_received and loan_account_id for approved
    applications [where] that have no matching row in test_loan_account
    [where ... is null]."
   Tip: "have no matching row" = is null after a left join. Building on the
   previous prompt ("using the same...") keeps CoCo consistent.
-------------------------------------------------------------------------- */


/* =============================================================================
   6. THE RECONCILIATION
   6a builds it step by step, 6b shows the same logic saved as a view,
   6c summarises it.

   Question: "Does every approved application have a matching booked loan,
              for the right amount, in the right month?"

   Structure (the dbt pattern): import CTEs -> logic CTEs -> final select.
   Each CTE is one step, like a separate tab in an Excel recon workbook.

   New ideas:
   - with ... as   : named steps (CTEs)
   - full outer join : match BOTH ways, so we also catch loans booked
                       with no approved application
   - coalesce      : take the first non-null value
   - date_trunc('month', ...)   : compare dates by month
   - case when     : SQL's nested IF. First true condition wins, so order matters

   Expected: 274 records (one per transaction), which summarise to:
     Matched                          230
     Amount mismatch                   15
     Approved, not booked              13
     Timing difference                  8
     Booked, no approved application    8
============================================================================= */
with

-- Import: loan applications
applications as (

    select
        application_id,
        status,
        initcap(product) as product,
        loan_amount,
        date_received
    from test_loan_application

),

-- Import: booked loans
accounts as (

    select
        loan_account_id,
        application_id,
        initcap(product) as product,
        loan_amount,
        booked_date
    from test_loan_account

),

-- Logic: match both ways and label every record
reconciled as (

    select
        coalesce(applications.application_id, accounts.application_id) as application_id,
        accounts.loan_account_id,
        applications.status as application_status,
        coalesce(applications.product, accounts.product) as product,
        applications.loan_amount as application_amount,
        accounts.loan_amount as booked_amount,
        accounts.loan_amount - applications.loan_amount as amount_difference,
        applications.date_received,
        accounts.booked_date,
        case
            when accounts.loan_account_id is null
                then 'Approved, not booked'
            when applications.application_id is null or applications.status != 'Approved'
                then 'Booked, no approved application'
            when applications.loan_amount != accounts.loan_amount
                then 'Amount mismatch'
            when date_trunc('month', applications.date_received)
                != date_trunc('month', accounts.booked_date)
                then 'Timing difference'
            else 'Matched'
        end as recon_result
    from applications
    full outer join accounts
        on applications.application_id = accounts.application_id
    -- Declined, withdrawn or pending applications that were never booked are out of scope
    where
        applications.status = 'Approved'
        or accounts.loan_account_id is not null

),

-- Final: one row per record, exceptions first (the recon "worksheet")
final as (

    select *
    from reconciled

)

select * from final
order by
    recon_result = 'Matched',   -- false sorts first, so exceptions come first
    recon_result,
    application_id;

-- Expected: 274 rows (266 approved applications + 8 loans booked without
-- an approved application). Each row says which bucket it's in and why.
--
-- Things to point out:
--   - The $4.85M "personal loan" from query 2 is in 'Amount mismatch':
--     it was booked as $48,500. A keying error, caught automatically.
--   - 'Approved, not booked' rows have no loan_account_id: nothing was booked.
--   - 'Booked, no approved application' is the one audit cares about:
--     money went out with no approval trail. 3 were booked while the
--     application was still Pending, 1 was Declined, and 4 point at an
--     application_id that doesn't exist at all.
--   - Written once, this re-runs on next month's data in seconds.

/* CoCo prompt ------------------------------------------------------------
   Structure the prompt in the same steps as the CTEs above:

   "Reconcile approved loan applications against booked loans.
    Step 1 [applications CTE]: from test_loan_application, take the
      applications and standardise product casing.
    Step 2 [accounts CTE]: from test_loan_account, take the booked loans
      and standardise product casing.
    Step 3 [reconciled CTE]: full outer join the two on application_id so
      unmatched rows from both sides are kept. Exclude declined, withdrawn
      or pending applications that were never booked. Label each record, checking in
      this order:
        - 'Approved, not booked' if there's no booked loan
        - 'Booked, no approved application' if there's no application or
          it isn't 'Approved'
        - 'Amount mismatch' if the loan amounts differ
        - 'Timing difference' if the month of date_received differs from
          the month of booked_date
        - otherwise 'Matched'
    Step 4 [final]: show every record with application_id, loan_account_id,
      both amounts, the difference, both dates and the label. Put the
      exceptions first."

   Tips:
   - Numbered steps give CoCo the same structure as the CTEs, and make its
     SQL easier to check.
   - Say the label order: like case when, the first true check wins.
   - Check you get 274 rows. If not, ask CoCo why. Usually it's a one-way join or the
     wrong label order.
-------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
   6b. The same logic, saved as a view
   We've already saved the query above as a view: v_loan_reconciliation.
   A view is a saved query with a name. Anyone can select from it without
   rewriting the logic, and it re-runs on the latest data every time.
   Excel: a recon template everyone reuses, instead of rebuilding it monthly.
   This view is also what CoWork uses later, so everyone gets the same breaks.
----------------------------------------------------------------------------- */
select *
from v_loan_reconciliation
order by
    recon_result = 'Matched',
    recon_result,
    application_id;

-- Expected: the same 274 rows as 6a, plus a few extra columns (region,
-- channel, account_status) so the results can be sliced further.

/* CoCo prompt ------------------------------------------------------------
   "Show every record in v_loan_reconciliation [from], exceptions first
    [order by]."
   Tip: once logic lives in a view, the prompt gets much shorter. CoCo
   doesn't need the rules, just the name of the view.
-------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
   6c. Summarise the reconciliation
   Excel: a pivot table on the recon worksheet, with the label as rows.
----------------------------------------------------------------------------- */
select
    recon_result,
    count(*) as records,
    sum(application_amount) as application_amount,
    sum(booked_amount) as booked_amount,
    sum(amount_difference) as amount_difference
from v_loan_reconciliation
group by recon_result
order by records desc;

-- Expected:
--   Matched                         230
--   Amount mismatch                  15
--   Approved, not booked             13
--   Timing difference                 8
--   Booked, no approved application   8
-- Notice the amount mismatch row: $8.0M applied vs $3.2M booked. Most of
-- that is the one $4.85M keying error. A total can hide a single bad row,
-- which is why 6a/6b (the detail) comes first.

/* CoCo prompt ------------------------------------------------------------
   "Using v_loan_reconciliation [from], for each recon_result [group by]
    show the number of records, total application_amount, total
    booked_amount and total amount_difference [select + aggregates], most
    records first [order by]."
   Follow-ups to try:
   - "Show the amount mismatches, biggest difference first."
   - "Break the exceptions down by product and region."
-------------------------------------------------------------------------- */
