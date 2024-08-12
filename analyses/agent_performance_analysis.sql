WITH agent_metrics AS (
    SELECT
        sales_agent_name,
        COUNT(*) AS num_sales,
        AVG(full_profit) AS avg_profit
    FROM sample_data.fct_sales
    GROUP BY sales_agent_name
),

     discount_agents AS (
         SELECT
             sales_agent_name,
             AVG(discount_amount) AS avg_discount_amount
         FROM sample_data.fct_sales
         WHERE discount_amount != 0
GROUP BY sales_agent_name
    ),

    ranked_agents AS (
SELECT
    am.sales_agent_name,
    am.num_sales,
    am.avg_profit,
    RANK() OVER (ORDER BY am.avg_profit DESC) AS rank
FROM agent_metrics am
    )

SELECT
    ra.sales_agent_name,
    ra.num_sales,
    ROUND(ra.avg_profit, 2) as avg_profit,
    ra.rank,
    ROUND(COALESCE(da.avg_discount_amount, 0), 2) AS avg_discount_amount
FROM ranked_agents ra
         LEFT JOIN discount_agents da ON ra.sales_agent_name = da.sales_agent_name
ORDER BY ra.rank;
