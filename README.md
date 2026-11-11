# Iron Ore Sales Reporting

A self-directed project: a cleaned dataset, a star-schema model, and the
data-quality checks underneath them.

**The data is synthetic.** It is modelled on spot iron ore sales into China —
1,843 transactions across 2025–2026, 13 counterparties, 8 ports, 7 ore grades
— and was generated for this project. No real or employer data appears
anywhere in this repository. Dimension values are in Chinese because the
scenario is.

## What I found, and what I decided

The findings matter less than what was done about them. Each of these is a
number that is arithmetically correct and still wrong.

### Unit price is a measure, not a calculated column

A per-row unit price averaged across rows is an average of averages. Against
the weighted figure — total amount divided by total tonnes — it runs about
**0.9 yuan per tonne high in 2025 and 1.3 low in 2026**: roughly 16.6 million
and 15.0 million yuan on those years' volumes.

Neither version raises an error, and the sign flips with whether a year's
largest shipments priced above or below the rest, so there is no constant to
correct for. The calculated column was deleted from the model rather than left
in place — anything left in the field list is eventually dragged into a report.

### Stock is semi-additive

Summing the weekly inventory snapshots for one month gives **134,572,344
tonnes against a true month-end figure of 27,100,241**, because the same stock
is counted again each week. Stock is additive across ports and not across
time, so the model reports a period-end snapshot.

### Orphan records are kept, not deleted

Five transactions reference customers that do not exist, worth **0.19% of
transaction value** (51,915,733.61). Deleting them changes the totals; leaving
them unhandled puts them under Power BI's automatic blank row, where they are
invisible. They are routed to an explicit unknown member, so they stay in the
totals and can still be traced.

## Cleaning

The source is a hand-kept ledger with eleven classes of problem: mixed date
formats, text that looks numeric, subtotal rows inside the detail, blank rows
between months, duplicate records, and eight ports recorded under twenty-four
spellings.

It is now 729 rows that reconcile to the source to the cent
(10,961,104,269.06). Two rules the cleaning follows:

- **Filter by rule, not by position.** Rows are kept on "ID starts with SH",
  not by deleting the last N rows; columns are dropped by name, not by index.
  A step that hard-coded a column count made a field disappear silently when
  the source changed, and the error surfaced three steps downstream.
- **Resolve names with a mapping table someone else can maintain**, rather
  than with one-off replacements.

## Layout

| | |
|---|---|
| `data/` | Synthetic source data, including the dirty ledger the cleaning starts from |
| `sql/` | A seven-check data-quality suite, and the exercise queries behind it |
| `excel/` | Power Query cleaning of the dirty ledger |
| `powerbi/` | The star-schema model |
| `notes/` | Working notes on dimensional modelling, and on measures vs calculated columns |

## Reproducing it

Paths inside the scripts are relative to the repository root, so run them from
there, against DuckDB:

1. `data/load_into_duckdb.sql` creates the tables and prints the expected row
   counts (fact_sales 1843, dim_customer 13, fact_port_inventory 4872, and so on).
2. `sql/data_quality_checks.sql` runs the seven checks. The fifth reports the
   orphan records above; the others return zero rows.

## A note on the model

There are no report pages, and that is deliberate. A chart built over a wrong
relationship or an average of averages looks correct and is wrong, so the
model, the relationships and the checks came first. All relationships are
single-direction, and the date table is marked as a date table.

Built with DuckDB, SQL, Power Query and Power BI.
