# CoWork reconciliation investigation

Work through these four prompts **in one conversation** with the **Loan Applications Analyst** agent.
They follow a month-end reconciliation: headline numbers, then where the exceptions are, then a follow-up list, then a sign-off pack.
At the end you turn the whole conversation into a reusable **skill**.

!!! tip "How to use this page"
    Click the copy icon on each prompt box, paste it into CoWork, and read the answer before moving on.

## Before you start

1. Open **CoWork** (Snowflake Intelligence) from the left-hand menu
2. Select the agent **Loan Applications Analyst**
3. Start a **new conversation**

## 1. Headline position

```text
Give me the month-end loan reconciliation summary for Jan–Jun 2026: how many records fall into each reconciliation result, the match rate, and the total dollar value of the exceptions. Show the counts as a chart.
```

**Look for:** a chart of reconciliation results.
:material-content-save: **Save the chart as an artifact** (name it *Recon summary*).

## 2. Where are the exceptions?

```text
Break the exceptions (everything that isn't Matched) down by channel and by month. Use a stacked bar chart by month, coloured by reconciliation result, and tell me which channel contributes the most exceptions.
```

**Look for:** you never named a table or column. The agent works it out from the semantic view.
:material-content-save: **Save this chart as an artifact.**

## 3. Build the follow-up list

```text
Give me the top 10 individual exceptions by dollar value as a follow-up list: application ID, loan account ID, exception type, channel, application amount, booked amount, exception value, and a one-line suggested action for each (e.g. book the loan, correct the amount, find the missing application).
```

**Look for:** a record-level worklist you could export to Excel, plus any data quality issues the agent spots without being asked.

## 4. Sign-off pack

```text
Write a one-page month-end reconciliation sign-off summary for the finance manager. Include headline numbers, the exception breakdown, the top 5 items from the follow-up list, any data quality issues, and recommended next steps with an owner for each exception type. Include one chart.
```

:material-content-save: **Save it as an artifact**, then open your saved artifacts to find all three.

## Bonus: turn it into a skill

```text
Turn this conversation into a reusable skill called "Month-End Loan Reconciliation" that runs these same steps for any month or date range I give it.
```

Then test it in a **new conversation**:

```text
Run Month-End Loan Reconciliation for Q2 2026 only.
```

!!! success "What you just built"
    A repeatable month-end check that anyone on the team can run, for any period, with one sentence.
