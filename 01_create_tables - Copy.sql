-- ============================================================
-- PROJECT: Sales Performance Analysis (2023)
-- FILE: 01_create_tables.sql
-- DESCRIPTION: Creates the relational schema for the retail
--              sales database used in this portfolio project.
-- AUTHOR: Jumoke Akomolafe
-- ============================================================


-- Drop tables if they already exist (for clean re-runs)
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales_reps;
DROP TABLE IF EXISTS customers;


-- ============================================================
-- TABLE 1: products
-- ============================================================
CREATE TABLE products (
    product_id      VARCHAR(10) PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    unit_cost       NUMERIC(10, 2) NOT NULL,
    unit_price      NUMERIC(10, 2) NOT NULL
);


-- ============================================================
-- TABLE 2: sales_reps
-- ============================================================
CREATE TABLE sales_reps (
    rep_id          SERIAL PRIMARY KEY,
    sales_rep       VARCHAR(50) NOT NULL,
    manager         VARCHAR(50) NOT NULL,
    region          VARCHAR(50) NOT NULL
);


-- ============================================================
-- TABLE 3: customers
-- ============================================================
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    customer_type   VARCHAR(50) NOT NULL,
    payment_method  VARCHAR(50) NOT NULL,
    sales_channel   VARCHAR(50) NOT NULL
);


-- ============================================================
-- TABLE 4: transactions (fact table)
-- ============================================================
CREATE TABLE transactions (
    transaction_id      SERIAL PRIMARY KEY,
    product_id          VARCHAR(10) REFERENCES products(product_id),
    rep_id              INT REFERENCES sales_reps(rep_id),
    customer_id         INT REFERENCES customers(customer_id),
    sale_date           DATE NOT NULL,
    quantity_sold       INT NOT NULL,
    unit_price          NUMERIC(10, 2) NOT NULL,
    discount            NUMERIC(5, 2) DEFAULT 0,
    sales_amount        NUMERIC(10, 2) NOT NULL,
    tax_rate            NUMERIC(5, 2) NOT NULL,
    tax_amount          NUMERIC(10, 2) NOT NULL,
    sales_performance   VARCHAR(20) NOT NULL
);
