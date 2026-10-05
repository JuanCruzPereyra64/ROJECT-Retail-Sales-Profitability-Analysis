-- Business Question 5: Sensitivity Analysis on capping discounts at 20 pct

WITH base_calc AS (
    SELECT 
        order_id,
        sales,
        profit,
        discount,
        -- Identify target lines
        CASE WHEN profit < 0 AND discount > 0.20 THEN 1 ELSE 0 END AS is_affected,
        CASE WHEN profit < 0 AND discount >= 0.50 THEN 1 ELSE 0 END AS is_affected_50,
        -- Formulas for simulated recovery
        (sales / NULLIF(1 - discount, 0)) * 0.80 AS capped_sales,
        ((sales / NULLIF(1 - discount, 0)) * 0.80) - (sales - profit) AS capped_profit
    FROM sales_data
),
order_calc AS (
    SELECT order_id, MAX(is_affected) AS order_has_affected_line
    FROM base_calc
    GROUP BY order_id
),
totals AS (
    SELECT SUM(profit) AS base_profit, SUM(sales) AS base_sales FROM base_calc
),
scenarios AS (
    -- 1. Actual Baseline
    SELECT '1. Current Actuals' AS scenario_name, SUM(profit) AS total_profit, SUM(sales) AS total_sales FROM base_calc
    UNION ALL
    -- 2. Optimistic (0 pct lost)
    SELECT '2. Cap 20 pct (0 pct Lost Sales)' AS scenario_name, 
           SUM(CASE WHEN is_affected = 1 THEN capped_profit ELSE profit END),
           SUM(CASE WHEN is_affected = 1 THEN capped_sales ELSE sales END)
    FROM base_calc
    UNION ALL
    -- 3. Realistic (-25 pct)
    SELECT '3. Cap 20 pct (25 pct Lost Sales)' AS scenario_name, 
           SUM(CASE WHEN is_affected = 1 THEN capped_profit * 0.75 ELSE profit END),
           SUM(CASE WHEN is_affected = 1 THEN capped_sales * 0.75 ELSE sales END)
    FROM base_calc
    UNION ALL
    -- 4. Realistic (-50 pct)
    SELECT '4. Cap 20 pct (50 pct Lost Sales)' AS scenario_name, 
           SUM(CASE WHEN is_affected = 1 THEN capped_profit * 0.50 ELSE profit END),
           SUM(CASE WHEN is_affected = 1 THEN capped_sales * 0.50 ELSE sales END)
    FROM base_calc
    UNION ALL
    -- 5. Pessimistic (-75 pct)
    SELECT '5. Cap 20 pct (75 pct Lost Sales)' AS scenario_name, 
           SUM(CASE WHEN is_affected = 1 THEN capped_profit * 0.25 ELSE profit END),
           SUM(CASE WHEN is_affected = 1 THEN capped_sales * 0.25 ELSE sales END)
    FROM base_calc
    UNION ALL
    -- 6. Rejected (100 pct lost line)
    SELECT '6. Cap 20 pct (100 pct Lost Sales / Rejected)' AS scenario_name, 
           SUM(CASE WHEN is_affected = 1 THEN 0 ELSE profit END),
           SUM(CASE WHEN is_affected = 1 THEN 0 ELSE sales END)
    FROM base_calc
    UNION ALL
    -- 7. Entire Order Lost (Collateral damage)
    SELECT '7. Full Order Lost if Affected Line' AS scenario_name, 
           SUM(CASE WHEN o.order_has_affected_line = 1 THEN 0 ELSE b.profit END),
           SUM(CASE WHEN o.order_has_affected_line = 1 THEN 0 ELSE b.sales END)
    FROM base_calc b JOIN order_calc o ON b.order_id = o.order_id
    UNION ALL
    -- 8. Conservative Rollout (Only >=50 pct cap)
    SELECT '8. Conservative Rollout (Cap >= 50 pct only, 0 pct Lost)' AS scenario_name, 
           SUM(CASE WHEN is_affected_50 = 1 THEN capped_profit ELSE profit END),
           SUM(CASE WHEN is_affected_50 = 1 THEN capped_sales ELSE sales END)
    FROM base_calc
)
SELECT 
    scenario_name,
    ROUND(total_profit::numeric, 0) AS simulated_profit,
    ROUND(((total_profit - totals.base_profit) / totals.base_profit * 100)::numeric, 1) AS profit_improve_pct,
    ROUND((total_profit / total_sales * 100)::numeric, 1) AS simulated_margin_pct,
    ROUND(((total_profit / total_sales * 100) - (totals.base_profit / totals.base_sales * 100))::numeric, 1) AS margin_improve_pp,
    ROUND(((total_sales - totals.base_sales) / totals.base_sales * 100)::numeric, 1) AS sales_variation_pct
FROM scenarios CROSS JOIN totals
ORDER BY scenario_name;