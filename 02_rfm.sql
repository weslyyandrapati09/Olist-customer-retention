-- 02_rfm.sql
-- RFM segmentation of real customers (customer_unique_id), delivered orders only.
--   Recency   = days since last order (relative to the latest order date in the data)
--   Frequency = number of delivered orders
--   Monetary  = total payments (includes freight, so this is customer payments,
--               not Olist's own revenue)
-- Scores: recency and monetary use NTILE(5); a customer_unique_id tie-breaker keeps
-- the result identical on every run (without it, tied customers can be assigned to
-- different buckets between runs and segment counts shift slightly).
-- Segment rules are my own design, not an industry standard.

CREATE OR REPLACE TABLE `elite-variety-512708-t7.olist.rfm` AS
WITH base AS (
  SELECT c.customer_unique_id, o.order_id,
         DATE(TIMESTAMP(o.order_purchase_timestamp)) AS order_date
  FROM `elite-variety-512708-t7.olist.Orders` o
  JOIN `elite-variety-512708-t7.olist.Customers` c USING (customer_id)
  WHERE o.order_status = 'delivered'
),
pay AS (
  SELECT order_id, SUM(payment_value) AS order_value
  FROM `elite-variety-512708-t7.olist.payments`
  GROUP BY 1
),
rfm_raw AS (
  SELECT b.customer_unique_id,
         DATE_DIFF((SELECT MAX(order_date) FROM base), MAX(b.order_date), DAY) AS recency_days,
         COUNT(DISTINCT b.order_id) AS frequency,
         ROUND(SUM(p.order_value), 2) AS monetary
  FROM base b
  JOIN pay p USING (order_id)
  GROUP BY 1
),
scored AS (
  SELECT *,
         NTILE(5) OVER (ORDER BY recency_days DESC, customer_unique_id) AS r_score,
         CASE WHEN frequency = 1 THEN 1 WHEN frequency = 2 THEN 3 ELSE 5 END AS f_score,
         NTILE(5) OVER (ORDER BY monetary, customer_unique_id) AS m_score
  FROM rfm_raw
)
SELECT *,
  CASE
    WHEN f_score >= 3 AND r_score >= 4 THEN 'Champions'
    WHEN f_score >= 3 THEN 'Repeat - At Risk'
    WHEN r_score >= 4 AND m_score >= 4 THEN 'New Big Spenders'
    WHEN r_score >= 4 THEN 'New Customers'
    WHEN r_score <= 2 THEN 'Inactive One-Timers'
    ELSE 'Need Attention'
  END AS segment
FROM scored;
