# Olist Customer Retention & RFM Analysis

## Business problem
Olist is a Brazilian e-commerce marketplace. If few customers return after
their first order, growth depends on constantly acquiring new customers.
**Question: how many customers come back, and which are worth keeping?**

## Key findings
- Only **3.0%** of 93,357 customers placed a second order.
- Retention stays **below 1%** in every monthly cohort (2017-2018).
- Repeat customers are 3% of customers but **5.6%** of total payments (R$15.4M).
- 14,404 "New Big Spenders" average ~R$302 per customer, about 4x "New Customers".

## Recommendations
1. Test a second-purchase offer for New Big Spenders within 30-60 days of their first order.
2. Run it as an A/B test (offer vs no offer) before any rollout.
3. Treat win-back of inactive one-timers as a small experiment, not a main bet.

## Approach
1. Loaded 4 Olist tables into BigQuery; used delivered orders only.
2. 2. Found that `customer_id` changes per order, so used `customer_unique_id`
 93,357 customer_ids vs 2801 real customers in the Customers table.
3. Built monthly cohort retention (SQL) and RFM segmentation (6 segments).
4. Made RFM scoring deterministic after noticing counts shifting between runs.
5. Built a 3-page Looker Studio dashboard.

**Live dashboard:**https://datastudio.google.com/reporting/9b7b1476-461e-47d0-853a-c7b12acc46d3

**Data:** [Olist Brazilian E-Commerce Public Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Limitations
About two years of data, one marketplace, no marketing/channel data,
payments include freight, segment thresholds are my own design.
Findings describe behaviour; they don't prove cause.

## Tools & skills practised
BigQuery SQL (CTEs, window functions, cohort analysis), Looker Studio, RFM

## Files
- [`00_validation_checks.sql`](00_validation_checks.sql): data checks and the repeat-rate query
- [`01_cohort_retention.sql`](01_cohort_retention.sql): monthly cohort retention table
- [`02_rfm.sql`](02_rfm.sql): RFM scoring and segments
- [Dashboard PDF](Olist_Customer_Retention_%26_RFM_Dashboard.pdf): all 3 dashboard pages

## Next
Python analysis: do late deliveries and low review scores reduce repeat purchase?
