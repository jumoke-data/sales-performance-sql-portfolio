-- ============================================================
-- PROJECT: Sales Performance Analysis (2023)
-- FILE: 03_analysis_queries.sql
-- DESCRIPTION: Portfolio SQL queries answering the four core
--              business questions from the sales dataset.
--              Covers: aggregation, JOINs, subqueries, CTEs,
--              window functions, CASE WHEN, and date functions.
-- AUTHOR: Jumoke Akomolafe
-- ============================================================


-- ============================================================
-- SECTION 1: PRODUCT & CATEGORY PERFORMANCE
-- ============================================================

-- Q1a. Total revenue by product category (best to worst)
SELECT
    p.category,
    SUM(t.sales_amount)                         AS total_revenue,
    COUNT(t.transaction_id)                     AS total_transactions,
    ROUND(AVG(t.sales_amount), 2)               AS avg_transaction_value
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Q1b. Top 5 best-selling products by revenue
SELECT
    p.product_name,
    p.category,
    SUM(t.sales_amount)                         AS total_revenue,
    SUM(t.quantity_sold)                        AS total_units_sold
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 5;


-- Q1c. Products performing below average revenue
-- (using a subquery to calculate the average)
SELECT
    p.product_name,
    p.category,
    SUM(t.sales_amount)                         AS total_revenue
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.product_name, p.category
HAVING SUM(t.sales_amount) < (
    SELECT AVG(product_total)
    FROM (
        SELECT SUM(sales_amount) AS product_total
        FROM transactions
        GROUP BY product_id
    ) sub
)
ORDER BY total_revenue ASC;


-- Q1d. Profit margin by product
-- (revenue minus cost of goods sold)
SELECT
    p.product_name,
    p.category,
    SUM(t.sales_amount)                                         AS total_revenue,
    SUM(t.quantity_sold * p.unit_cost)                          AS total_cost,
    SUM(t.sales_amount) - SUM(t.quantity_sold * p.unit_cost)    AS gross_profit,
    ROUND(
        (SUM(t.sales_amount) - SUM(t.quantity_sold * p.unit_cost))
        / NULLIF(SUM(t.sales_amount), 0) * 100, 2
    )                                                           AS profit_margin_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY gross_profit DESC;


-- ============================================================
-- SECTION 2: REGIONAL PERFORMANCE
-- ============================================================

-- Q2a. Total revenue by region (best to worst)
SELECT
    sr.region,
    SUM(t.sales_amount)                         AS total_revenue,
    COUNT(t.transaction_id)                     AS total_transactions,
    ROUND(AVG(t.sales_amount), 2)               AS avg_transaction_value
FROM transactions t
JOIN sales_reps sr ON t.rep_id = sr.rep_id
GROUP BY sr.region
ORDER BY total_revenue DESC;


-- Q2b. Revenue by region AND category
-- (to identify where category opportunities lie)
SELECT
    sr.region,
    p.category,
    SUM(t.sales_amount)                         AS total_revenue
FROM transactions t
JOIN products p  ON t.product_id = p.product_id
JOIN sales_reps sr ON t.rep_id = sr.rep_id
GROUP BY sr.region, p.category
ORDER BY sr.region, total_revenue DESC;


-- Q2c. Regions performing below overall average revenue
-- (subquery approach)
SELECT
    sr.region,
    SUM(t.sales_amount)                         AS total_revenue
FROM transactions t
JOIN sales_reps sr ON t.rep_id = sr.rep_id
GROUP BY sr.region
HAVING SUM(t.sales_amount) < (
    SELECT AVG(region_total)
    FROM (
        SELECT sr2.region, SUM(t2.sales_amount) AS region_total
        FROM transactions t2
        JOIN sales_reps sr2 ON t2.rep_id = sr2.rep_id
        GROUP BY sr2.region
    ) sub
);


-- ============================================================
-- SECTION 3: SALES CHANNEL ANALYSIS
-- ============================================================

-- Q3a. Online vs Retail — total revenue and transaction share
SELECT
    c.sales_channel,
    SUM(t.sales_amount)                         AS total_revenue,
    COUNT(t.transaction_id)                     AS total_transactions,
    ROUND(
        COUNT(t.transaction_id) * 100.0
        / SUM(COUNT(t.transaction_id)) OVER (), 2
    )                                           AS transaction_share_pct,
    ROUND(
        SUM(t.sales_amount) * 100.0
        / SUM(SUM(t.sales_amount)) OVER (), 2
    )                                           AS revenue_share_pct
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.sales_channel
ORDER BY total_revenue DESC;


-- Q3b. Channel performance by product category
SELECT
    c.sales_channel,
    p.category,
    SUM(t.sales_amount)                         AS total_revenue
FROM transactions t
JOIN customers c  ON t.customer_id = c.customer_id
JOIN products p   ON t.product_id = p.product_id
GROUP BY c.sales_channel, p.category
ORDER BY c.sales_channel, total_revenue DESC;


-- Q3c. Payment method breakdown by sales channel
SELECT
    c.sales_channel,
    c.payment_method,
    COUNT(t.transaction_id)                     AS transaction_count,
    SUM(t.sales_amount)                         AS total_revenue
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.sales_channel, c.payment_method
ORDER BY c.sales_channel, total_revenue DESC;


-- ============================================================
-- SECTION 4: SALES REP PERFORMANCE
-- ============================================================

-- Q4a. Total revenue per sales rep (ranked)
SELECT
    sr.sales_rep,
    sr.region,
    sr.manager,
    SUM(t.sales_amount)                         AS total_revenue,
    COUNT(t.transaction_id)                     AS total_transactions,
    ROUND(AVG(t.sales_amount), 2)               AS avg_deal_value
FROM transactions t
JOIN sales_reps sr ON t.rep_id = sr.rep_id
GROUP BY sr.sales_rep, sr.region, sr.manager
ORDER BY total_revenue DESC;


-- Q4b. Sales rep performance using a CTE
-- (adds rank and gap from top performer)
WITH rep_revenue AS (
    SELECT
        sr.sales_rep,
        sr.region,
        SUM(t.sales_amount)                     AS total_revenue
    FROM transactions t
    JOIN sales_reps sr ON t.rep_id = sr.rep_id
    GROUP BY sr.sales_rep, sr.region
),
ranked_reps AS (
    SELECT
        sales_rep,
        region,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC)   AS revenue_rank,
        MAX(total_revenue) OVER ()                  AS top_revenue
    FROM rep_revenue
)
SELECT
    sales_rep,
    region,
    total_revenue,
    revenue_rank,
    ROUND(top_revenue - total_revenue, 2)           AS gap_from_top
FROM ranked_reps
ORDER BY revenue_rank;


-- Q4c. Sales performance rating breakdown per rep
-- (how many transactions were Exceeded / Met / Below Target)
SELECT
    sr.sales_rep,
    t.sales_performance,
    COUNT(*)                                    AS transaction_count
FROM transactions t
JOIN sales_reps sr ON t.rep_id = sr.rep_id
GROUP BY sr.sales_rep, t.sales_performance
ORDER BY sr.sales_rep, transaction_count DESC;


-- Q4d. Manager-level revenue summary
SELECT
    sr.manager,
    COUNT(DISTINCT sr.sales_rep)                AS reps_managed,
    SUM(t.sales_amount)                         AS total_team_revenue,
    ROUND(AVG(t.sales_amount), 2)               AS avg_transaction_value
FROM transactions t
JOIN sales_reps sr ON t.rep_id = sr.rep_id
GROUP BY sr.manager
ORDER BY total_team_revenue DESC;


-- ============================================================
-- SECTION 5: TIME-BASED ANALYSIS
-- ============================================================

-- Q5a. Monthly revenue trend
SELECT
    TO_CHAR(t.sale_date, 'YYYY-MM')             AS sale_month,
    SUM(t.sales_amount)                         AS monthly_revenue,
    COUNT(t.transaction_id)                     AS monthly_transactions
FROM transactions t
GROUP BY sale_month
ORDER BY sale_month;


-- Q5b. Best performing quarter
SELECT
    EXTRACT(QUARTER FROM t.sale_date)           AS quarter,
    SUM(t.sales_amount)                         AS quarterly_revenue,
    COUNT(t.transaction_id)                     AS quarterly_transactions
FROM transactions t
GROUP BY quarter
ORDER BY quarterly_revenue DESC;


-- Q5c. Running total of revenue across 2023 (window function)
SELECT
    TO_CHAR(t.sale_date, 'YYYY-MM')             AS sale_month,
    SUM(t.sales_amount)                         AS monthly_revenue,
    SUM(SUM(t.sales_amount))
        OVER (ORDER BY TO_CHAR(t.sale_date, 'YYYY-MM'))
                                                AS running_total
FROM transactions t
GROUP BY sale_month
ORDER BY sale_month;


-- ============================================================
-- SECTION 6: DISCOUNT & TAX ANALYSIS
-- ============================================================

-- Q6a. Impact of discounts on revenue
SELECT
    CASE
        WHEN t.discount = 0         THEN 'No Discount'
        WHEN t.discount <= 0.05     THEN '1-5% Discount'
        WHEN t.discount <= 0.10     THEN '6-10% Discount'
        ELSE 'Over 10% Discount'
    END                                         AS discount_band,
    COUNT(t.transaction_id)                     AS transaction_count,
    SUM(t.sales_amount)                         AS total_revenue,
    ROUND(AVG(t.sales_amount), 2)               AS avg_transaction_value
FROM transactions t
GROUP BY discount_band
ORDER BY total_revenue DESC;


-- Q6b. Total tax collected by region
SELECT
    sr.region,
    SUM(t.tax_amount)                           AS total_tax_collected,
    SUM(t.sales_amount)                         AS total_revenue,
    ROUND(SUM(t.tax_amount) / SUM(t.sales_amount) * 100, 2)
                                                AS effective_tax_rate_pct
FROM transactions t
JOIN sales_reps sr ON t.rep_id = sr.rep_id
GROUP BY sr.region
ORDER BY total_tax_collected DESC;


-- ============================================================
-- SECTION 7: ADVANCED — CHAINED CTEs
-- ============================================================

-- Q7. Full performance summary per rep
-- Chains three CTEs: revenue, targets, and final ranking

WITH rep_revenue AS (
    -- Step 1: Calculate total revenue per rep
    SELECT
        sr.rep_id,
        sr.sales_rep,
        sr.region,
        sr.manager,
        SUM(t.sales_amount)                     AS total_revenue,
        COUNT(t.transaction_id)                 AS total_transactions
    FROM transactions t
    JOIN sales_reps sr ON t.rep_id = sr.rep_id
    GROUP BY sr.rep_id, sr.sales_rep, sr.region, sr.manager
),
rep_targets AS (
    -- Step 2: Count how often each rep exceeded, met, or missed target
    SELECT
        sr.rep_id,
        SUM(CASE WHEN t.sales_performance = 'Exceeded Target' THEN 1 ELSE 0 END) AS exceeded_count,
        SUM(CASE WHEN t.sales_performance = 'Met Target'      THEN 1 ELSE 0 END) AS met_count,
        SUM(CASE WHEN t.sales_performance = 'Below Target'    THEN 1 ELSE 0 END) AS below_count
    FROM transactions t
    JOIN sales_reps sr ON t.rep_id = sr.rep_id
    GROUP BY sr.rep_id
),
final_summary AS (
    -- Step 3: Join both CTEs and add revenue rank
    SELECT
        r.sales_rep,
        r.region,
        r.manager,
        r.total_revenue,
        r.total_transactions,
        t.exceeded_count,
        t.met_count,
        t.below_count,
        RANK() OVER (ORDER BY r.total_revenue DESC) AS revenue_rank
    FROM rep_revenue r
    JOIN rep_targets t ON r.rep_id = t.rep_id
)
SELECT *
FROM final_summary
ORDER BY revenue_rank;
