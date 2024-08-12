{{ config(materialized = 'table') }}
WITH base AS (
    SELECT
        reference_id                   ,
        COALESCE(country, 'N/A') AS country,
        COALESCE(product_code, 'N/A') AS product_code,
        COALESCE(product_name, 'N/A') AS product_name,
        COALESCE(subscription_start_date, 'N/A') AS subscription_start_date,
        COALESCE(subscription_deactivation_date, 'N/A') AS subscription_deactivation_date,
        COALESCE(subscription_duration_months, 0) AS subscription_duration_months,
        COALESCE(last_rebill_date_kyiv, 'N/A') AS last_rebill_date_kyiv,
        COALESCE(has_chargeback, 'N/A') AS has_chargeback,
        COALESCE(has_refund, 'N/A') AS has_refund,
        COALESCE(sales_agent_name, 'N/A') AS sales_agent_name,
        COALESCE(source, 'N/A') AS source,
        COALESCE(campaign_name, 'N/A') AS campaign_name,
        COALESCE(total_amount, 0) AS total_amount,
        COALESCE(discount_amount, 0) AS discount_amount,
        COALESCE(number_of_rebills, 0) AS number_of_rebills,
        COALESCE(original_amount, 0) AS original_amount,
        COALESCE(returned_amount, 0) AS returned_amount,
        COALESCE(total_rebill_amount, 0) AS total_rebill_amount,

        to_char(
                to_timestamp(order_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM') ,
                'YYYY-MM-DD HH24:MI'
        ) AS order_date_kyiv,
        to_char(
                to_timestamp(order_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM')::TIMESTAMPTZ AT TIME ZONE 'UTC'
                    AT TIME ZONE 'Europe/Kiev',
                'YYYY-MM-DD HH24:MI'
        ) AS order_date_utc,
        to_char(
                to_timestamp(order_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM')
                    AT TIME ZONE 'Europe/Kiev' AT TIME ZONE 'America/New_York',
                'YYYY-MM-DD HH24:MI'
        ) AS order_date_new_york,

        to_char(
                to_timestamp(return_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM') ,
                'YYYY-MM-DD HH24:MI'
        ) AS return_date_kyiv,
            to_char(
                    to_timestamp(return_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM')::TIMESTAMPTZ AT TIME ZONE 'UTC'
                    AT TIME ZONE 'Europe/Kiev',
                    'YYYY-MM-DD HH24:MI'
            ) AS return_date_utc,
        to_char(
                to_timestamp(return_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM')
                    AT TIME ZONE 'Europe/Kiev' AT TIME ZONE 'America/New_York',
                'YYYY-MM-DD HH24:MI'
        ) AS return_date_new_york,

        (
            to_timestamp(return_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM')::date -
            to_timestamp(order_date_kyiv, 'FMMonth DD, YYYY, HH12:MI AM')::date
        ) AS days_between_order_return, -- Різниця днів від дати повернення коштів та датою покупки

        (number_of_rebills * total_amount) + total_amount - (
            CASE
                WHEN has_refund = 'Yes' OR has_chargeback = 'Yes' THEN returned_amount
                ELSE 0
                END
            ) AS full_profit, -- Дохід компанії від продажі, враховуючи повторні оплати (rebill) та повернення коштів
                -- TODO  запитати за total_rebill_amount

        number_of_rebills * total_amount AS rebills_profit, -- Дохід компанії тільки від ребілів
        -- TODO  запитати за total_rebill_amount
        (
            CASE
             WHEN has_refund = 'Yes' OR has_chargeback = 'Yes' THEN returned_amount
             ELSE 0
            END
        ) AS returned_amount_sum -- Сума повернених коштів

    FROM "sample_data"."sample"
)

SELECT *
FROM base
