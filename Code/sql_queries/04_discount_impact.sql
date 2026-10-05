-- Business Question 4: How do discounts impact overall profitability?

SELECT 
    discount,
    CASE 
        WHEN discount = 0 THEN '0 pct'
        WHEN discount <= 0.20 THEN '1-20 pct'
        WHEN discount <= 0.40 THEN '21-40 pct'
        ELSE '41 pct +'
    END AS discount_band,
    COUNT(*) AS total_lines,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales) * 100)::numeric, 2) AS profit_margin_pct
FROM sales_data
GROUP BY discount, discount_band
ORDER BY discount ASC;