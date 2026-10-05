-- Business Question 1: How did sales and profits evolve over time?
-- Executed by Step 3 of the notebook via pd.read_sql (pandas only prepares time columns).
-- The notebook originally computed this with a pandas groupby; this query is its SQL equivalent.

WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::int AS order_year,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit
    FROM sales_data
    GROUP BY 1
)
SELECT
    order_year,
    ROUND(total_revenue::numeric, 2) AS total_revenue,
    ROUND(total_profit::numeric, 2) AS total_profit,
    ROUND((total_profit / total_revenue * 100)::numeric, 2) AS profit_margin_pct,
    ROUND(((total_revenue / LAG(total_revenue) OVER (ORDER BY order_year) - 1) * 100)::numeric, 2) AS yoy_sales_growth_pct,
    ROUND(((total_profit / LAG(total_profit) OVER (ORDER BY order_year) - 1) * 100)::numeric, 2) AS yoy_profit_growth_pct
FROM yearly
ORDER BY order_year;
