-- Average discount driving sub-category losses

SELECT 
    sub_category, 
    ROUND((AVG(discount) * 100)::numeric, 2) AS avg_discount_pct, 
    ROUND(SUM(profit)::numeric, 0) AS total_profit
FROM sales_data 
GROUP BY sub_category 
ORDER BY total_profit ASC 
LIMIT 5;