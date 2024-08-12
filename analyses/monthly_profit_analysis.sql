WITH
    filtered_data AS (
        SELECT
            EXTRACT(YEAR FROM to_timestamp(order_date_kyiv, 'YYYY-MM-DD')) AS year,
    EXTRACT(MONTH FROM to_timestamp(order_date_kyiv, 'YYYY-MM-DD')) AS month,
    SUM(full_profit) AS current_full_profit
FROM sample_data.fct_sales
GROUP BY year, month
ORDER BY year, month
    ),

    monthly_profit AS (
SELECT
    month,
    year,
    SUM(current_full_profit) AS current_full_profit
FROM filtered_data
GROUP BY year, month
    ),

    profit_with_lag AS (
SELECT
    year,
    month,
    current_full_profit,
    LAG(current_full_profit) OVER (ORDER BY month) AS prev_month_profit
FROM monthly_profit
    )

SELECT
    year,
    month,
    current_full_profit, -- прибуток за поточний місяць
    prev_month_profit, -- прибуток за попередній місяць
    CASE
    WHEN prev_month_profit IS NULL THEN NULL
    ELSE ROUND((current_full_profit - prev_month_profit) / prev_month_profit * 100, 2)
END AS percentage_change   -- зріст/спад в процентному співвідношенні
FROM profit_with_lag
ORDER BY  year, month