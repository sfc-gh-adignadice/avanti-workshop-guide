# Wrap-up

## What we covered today

- **Snowflake foundations:** One platform for data, compute and AI. Accounts hold databases, schemas and tables, and roles control what each person can see.
- **Governed by design:** Tags, masking and row access policies protect sensitive data, and every AI answer respects the same access rules.
- **Write better SQL:** Select only the columns you need, join on unique keys, and keep ORDER BY and LIMIT for the final result.
- **AI that works with you:** CoCo writes and explains the SQL; CoWork answers business questions in plain English. Be specific, iterate and check the numbers.

> Snowflake does the heavy lifting, Excel does the thinking.

## Same recon, three ways

| | SQL | CoCo | CoWork |
|---|---|---|---|
| You write | Every line of SQL | A prompt; CoCo writes SQL you can check | A question in plain English |
| Best for | Full control, learning | Analysts/engineers building queries and pipelines | Business users, quick answers, charts, reports |
| Output | Result grid | SQL + results | Answers, charts, artifacts, skills |

## Prompting habits

These apply to both CoCo and CoWork.

- **Be specific:** Name the data, the time period and the output you want, such as Jan to Feb 2026, by channel, as a table.
- **Use your terms:** Use Avanti's business language, and define anything ambiguous, such as whether approval rate includes Pending.
- **Iterate:** Start simple, check the answer, then refine. Several short prompts beat one long one.
- **Check the numbers:** Compare results with a figure you already trust, such as 230 matched loans.

## Next steps

- Try the skill on your own month-end questions
- Talk to your Snowflake team about connecting real loan system data
