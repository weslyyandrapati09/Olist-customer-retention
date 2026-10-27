-- 01_cohort_retention.sql
-- Monthly cohort retention for delivered Olist orders.
-- A cohort = customers grouped by the month of their first delivered order.
-- retention_pct = % of that cohort who ordered again N months later.
-- Cohorts before 2017-01 (tiny) and after 2018-06 (incomplete) are excluded.

CREATE OR REPLACE TABLE `elite-variety-512708-t7.olist.cohort_retention` AS
WITH orders_clean AS (
  SELECT c.customer_unique_id,
         DATE_TRUNC(DATE(TIMESTAMP(o.order_purchase_timestamp)), MONTH) AS order_month
  FROM `elite-variety-512708-t7.olist.Orders` o
  JOIN `elite-variety-512708-t7.olist.Customers` c USING (customer_id)
  WHERE o.order_status = 'delivered'
),
cohorts AS (
  SELECT customer_unique_id, MIN(order_month) AS cohort_month
  FROM orders_clean
  GROUP BY 1
),
activity AS (
  SELECT cohort_month,
         DATE_DIFF(oc.order_month, cohort_month, MONTH) AS month_number,
         COUNT(DISTINCT oc.customer_unique_id) AS active_customers
  FROM orders_clean oc
  JOIN cohorts USING (customer_unique_id)
  GROUP BY 1, 2
)
SELECT a.cohort_month, a.month_number, a.active_customers,
       s.cohort_size,
       ROUND(100 * SAFE_DIVIDE(a.active_customers, s.cohort_size), 2) AS retention_pct
FROM activity a
JOIN (SELECT cohort_month, active_customers AS cohort_size
      FROM activity WHERE month_number = 0) s USING (cohort_month)
WHERE a.cohort_month BETWEEN DATE '2017-01-01' AND DATE '2018-06-01'
  AND a.month_number <= 12;
