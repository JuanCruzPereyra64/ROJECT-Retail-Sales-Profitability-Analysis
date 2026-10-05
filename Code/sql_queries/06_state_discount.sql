-- Average discount driving state losses

SELECT 
    state, 
    ROUND((AVG(discount) * 100)::numeric, 2) AS avg_discount_pct, 
    ROUND(SUM(profit)::numeric, 0) AS total_profit
FROM sales_data 
GROUP BY state 
ORDER BY total_profit ASC 
LIMIT 5;