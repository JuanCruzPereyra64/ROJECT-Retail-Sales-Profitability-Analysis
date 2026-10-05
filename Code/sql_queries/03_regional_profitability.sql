-- Business Question 3: Which regions and states are the most and least profitable?

SELECT 
    region,
    state,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales) * 100)::numeric, 2) AS profit_margin_pct
FROM sales_data
GROUP BY region, state
ORDER BY total_profit ASC;