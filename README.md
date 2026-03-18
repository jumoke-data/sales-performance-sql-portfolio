# 🛍️ Sales Performance Analysis (2023) — SQL Portfolio

**Author:** Jumoke Akomolafe  
**Tool:** PostgreSQL (pgAdmin)  
**Dataset:** 1,000 retail sales transactions across 2023  
**LinkedIn:** [linkedin.com/in/jumoke-data](https://linkedin.com/in/jumoke-data)

---

## 📌 Project Overview

This SQL portfolio project analyses a fictional retail sales dataset to answer four core business questions:

1. Which products and categories are the best and worst performers?
2. Which regions are over- and underperforming?
3. Which sales channel drives more revenue — Online or Retail?
4. Who is the top-performing sales rep, and what is the performance gap?

This project is the SQL companion to my [Excel Sales Dashboard Portfolio](https://docs.google.com/spreadsheets/d/1KaNP-yrgC3g8y64UsR_9MtE9xyOQ42UD/edit), which analysed the same business problem using Microsoft Excel.

---

## 🗂️ Database Schema

The dataset is structured into four relational tables:

```
products        — product details (name, category, cost, price)
sales_reps      — rep details (name, manager, region)
customers       — customer profiles (type, payment method, channel)
transactions    — fact table linking all entities (sales data)
```

### Entity Relationships
- `transactions.product_id` → `products.product_id`
- `transactions.rep_id` → `sales_reps.rep_id`
- `transactions.customer_id` → `customers.customer_id`

---

## 📁 Files

| File | Description |
|------|-------------|
| `01_create_tables.sql` | Creates all four tables with primary and foreign keys |
| `02_insert_data.sql` | Inserts sample data (representative of 1,000 transactions) |
| `03_analysis_queries.sql` | All analysis queries — see sections below |

---

## 🔍 SQL Concepts Demonstrated

| Concept | Used In |
|---------|---------|
| `SELECT`, `WHERE`, `ORDER BY` | All sections |
| `GROUP BY`, `HAVING` | Sections 1, 2, 3, 4 |
| `JOIN` (INNER, multi-table) | All sections |
| Subqueries (WHERE & FROM clause) | Sections 1, 2 |
| `CASE WHEN` | Sections 4, 6 |
| CTEs (`WITH`) | Section 4, 7 |
| Chained CTEs | Section 7 |
| Window Functions (`RANK`, `SUM OVER`) | Sections 3, 4, 5, 7 |
| Date Functions (`TO_CHAR`, `EXTRACT`) | Section 5 |
| Aggregate Functions (`SUM`, `AVG`, `COUNT`) | All sections |
| `NULLIF` (division safety) | Section 1 |

---

## 📊 Query Sections

### Section 1 — Product & Category Performance
- Revenue by category
- Top 5 best-selling products
- Products below average revenue (subquery)
- Profit margin by product

### Section 2 — Regional Performance
- Revenue by region
- Revenue by region and category
- Regions below average (subquery)

### Section 3 — Sales Channel Analysis
- Online vs Retail revenue and transaction share (window function)
- Channel performance by category
- Payment method breakdown by channel

### Section 4 — Sales Rep Performance
- Revenue per rep
- Rep ranking with gap from top performer (CTE + window function)
- Performance rating breakdown (Exceeded / Met / Below Target)
- Manager-level team summary

### Section 5 — Time-Based Analysis
- Monthly revenue trend
- Best performing quarter
- Running total of revenue across 2023 (window function)

### Section 6 — Discount & Tax Analysis
- Revenue impact by discount band (CASE WHEN)
- Tax collected by region

### Section 7 — Advanced: Chained CTEs
- Full rep performance summary using three chained CTEs

---

## 💡 Key Findings

| Metric | Result |
|--------|--------|
| Total Revenue | $5,019,265.23 |
| Top Category | Clothing |
| Lowest Category | Food |
| Top Region | North |
| Weakest Region | South |
| Online vs Retail Split | 51% vs 49% |
| Top Sales Rep | Bob |
| Lowest Sales Rep | Charlie |

---

## 🚀 How to Run

1. Open **pgAdmin** and connect to your PostgreSQL server
2. Create a new database (e.g. `sales_portfolio`)
3. Run the files **in order**:
   - `01_create_tables.sql`
   - `02_insert_data.sql`
   - `03_analysis_queries.sql`

---

## 🔗 Related Projects

- 📊 [Excel Sales Dashboard Portfolio](https://docs.google.com/spreadsheets/d/1KaNP-yrgC3g8y64UsR_9MtE9xyOQ42UD/edit?gid=303094215#gid=303094215) — same dataset, analysed in Microsoft Excel

---

*Part of my self-directed data analytics learning journey — documenting progress publicly on [LinkedIn](https://linkedin.com/in/jumoke-data).*
