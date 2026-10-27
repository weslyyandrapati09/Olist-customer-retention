-- 00_validation_checks.sql
-- Basic checks run after loading the Olist tables into BigQuery.
-- Replace the project ID if you re-run this in your own project.

-- 1. Total orders
SELECT COUNT(*) AS total_orders
FROM `elite-variety-512708-t7.olist.Orders`;

-- 2. Order status breakdown (analysis uses 'delivered' only)
SELECT order_status, COUNT(*) AS orders
FROM `elite-variety-512708-t7.olist.Orders`
GROUP BY order_status
ORDER BY orders DESC;

-- 3. customer_id changes with every order; customer_unique_id is the real customer
SELECT
  COUNT(DISTINCT customer_id) AS customer_ids,
  COUNT(DISTINCT customer_unique_id) AS real_customers
FROM `elite-variety-512708-t7.olist.Customers`;

-- 4. Repeat-customer rate (delivered orders, real customers)
WITH cust_orders AS (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT o.order_id) AS orders
  FROM `elite-variety-512708-t7.olist.Orders` o
  JOIN `elite-variety-512708-t7.olist.Customers` c USING (customer_id)
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT
  COUNT(*) AS customers,
  COUNTIF(orders > 1) AS repeat_customers,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(orders > 1), COUNT(*)), 2) AS repeat_rate_pct
FROM cust_orders;

-- 5. Segment summary (run after 02_rfm.sql; re-run 02_rfm.sql and this again
--    to confirm the counts are identical, i.e. the table is reproducible)
SELECT
  segment,
  COUNT(*) AS customers,
  ROUND(AVG(monetary), 2) AS avg_spend,
  ROUND(SUM(monetary), 0) AS total_payments,
  ROUND(100 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS payments_pct
FROM `elite-variety-512708-t7.olist.rfm`
GROUP BY segment
ORDER BY total_payments DESC;

-- 6. Recency cutoffs behind the segment definitions on the dashboard
SELECT r_score, MIN(recency_days) AS min_days, MAX(recency_days) AS max_days, COUNT(*) AS customers
FROM `elite-variety-512708-t7.olist.rfm`
GROUP BY r_score ORDER BY r_score;
