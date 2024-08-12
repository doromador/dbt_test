WITH discount_agents AS (
    SELECT
        sales_agent_name,
        AVG(discount_amount) AS avg_discount_amount
    FROM sample_data.fct_sales
    WHERE discount_amount IS NOT NULL AND discount_amount != 0
GROUP BY sales_agent_name
    ),

    overall_avg_discount AS (
SELECT
    AVG(avg_discount_amount) AS avg_discount
FROM discount_agents
    ),

    agents_above_avg AS (
SELECT
    da.sales_agent_name,
    da.avg_discount_amount
FROM discount_agents da
    CROSS JOIN overall_avg_discount o
WHERE da.avg_discount_amount > o.avg_discount
    )

SELECT
    sales_agent_name,
    Round(avg_discount_amount, 2)
FROM agents_above_avg
ORDER BY avg_discount_amount DESC