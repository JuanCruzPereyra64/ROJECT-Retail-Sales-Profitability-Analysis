-- Business Question 2: Which categories and sub-categories generate the most profit?

SELECT 
    category,
    sub_category,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales) * 100)::numeric, 2) AS profit_margin_pct
FROM sales_data
GROUP BY category, sub_category
ORDER BY total_profit DESC;