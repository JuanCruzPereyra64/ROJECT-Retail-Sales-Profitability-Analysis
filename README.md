# Retail Sales & Profitability Analysis

End-to-end financial analysis of a retail superstore: from raw Excel to prescriptive SQL modeling.
**Headline finding:** discounts above 20% systematically destroy margin. Capping them at 20% lifts profit **+39.6%** even if every affected order is lost entirely.

## Architecture

```
Sample-Superstore.xlsx (Orders + Returns)
        │  pandas: clean, dedupe Returns to order grain, impute ZIPs
        ▼
PostgreSQL 16 (Docker) ── table: sales_data (9,994 rows)
        │  SQL analysis: sql_queries/01–07
        ├── Jupyter notebook (EDA + charts)
        ├── sales_cleaned_looker.csv ──► Looker Studio dashboard
        └── Executive Summary PDF
```

## Repo structure

```
Code/
├── Retail Sales & Profitability Analysis.ipynb  # EDA + ETL + SQL execution
├── Dataset/
│   ├── Sample-Superstore.xlsx                   # source of truth (input)
│   ├── sales_cleaned_looker.csv                 # clean extract for Looker (output)
│   └── sales_cleaned_looker.xlsx                # same extract, typed dates (via Drive→Sheets)
├── sql_queries/
│   ├── 01_yearly_performance.sql                 # YoY revenue/profit (used by notebook Step 3)
│   ├── 02_category_profit.sql
│   ├── 03_regional_profitability.sql
│   ├── 04_discount_impact.sql
│   ├── 05_profit_optimization.sql               # 8-scenario sensitivity analysis
│   ├── 06_state_discount.sql
│   └── 07_subcategory_discount.sql
├── docker-compose.yml                           # Postgres 16, persistent volume
├── db/init.sql                                  # schema + indexes
└── .env.example                                 # copy to .env (never commit secrets)
Executive Summary/
└── Retail Sales & Profitability Analysis.pdf
Dashboard/
└── Retail_Sales_&_Profitability_Analysis Static version dashboard.pdf  # static export
```

## Quickstart

```bash
cd Code
cp .env.example .env        # set your DB_PASSWORD
docker compose up -d        # Postgres 16 on localhost:5432
```

Then run the notebook top to bottom. It ingests the XLSX, loads `sales_data`,
executes queries 01–07 via `pd.read_sql`, and regenerates the Looker CSV.
Upload `Dataset/sales_cleaned_looker.csv` to Looker Studio for the dashboard.

## Interactive dashboard

Explore the results live in Looker Studio (4 pages, same verified numbers as the
notebook and the PDF):

**[Retail Sales & Profitability — Interactive Dashboard](https://datastudio.google.com/reporting/a064b6c1-3d75-4d5f-bb52-6fa6df6ae4b8)**

- **Executive** — KPIs (revenue, profit, margin, orders) + revenue/profit evolution 2015–2018
- **Products** — profit by sub-category: Copiers on top, Tables and Bookcases underwater
- **Geography** — profit map by state: Texas as the largest drain
- **Pricing** — the 20% tipping point: margin by discount band (green above, red below)

Source: `Code/Dataset/sales_cleaned_looker.xlsx` via Google Sheets.

## Key findings (verified on 9,994 clean rows)

| # | Finding | Value |
|---|---------|-------|
| 1 | Overall profit margin | 12.5% |
| 2 | Discount tipping point | 20% (11.8% margin at 20%, −10.1% at 30%) |
| 3 | Worst state | Texas, −$25,729 (37.0% avg discount) |
| 4 | Worst sub-category | Tables, −$17,725 (26.1% avg discount) |
| 5 | Cap-at-20% worst case (full order lost) | +39.6% profit, 22.8% margin |

## The bug we caught

The `Returns` table (800 rows, 296 unique orders) joined at line grain multiplied
returned lines (9,994 → 12,420 rows). Fix: `drop_duplicates('Order ID')` before
merging. All figures above are post-fix; the full story is in the PDF.

## Stack

Python (pandas, matplotlib, SQLAlchemy) · PostgreSQL 16 · SQL · Looker Studio
