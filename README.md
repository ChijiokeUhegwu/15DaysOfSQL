## 15 Days of SQL — PostgreSQL Mastery Journey

### Overview

This repository captures my 15-day deep dive into advanced SQL using PostgreSQL, following [The Complete SQL Masterclass 2025](https://www.udemy.com/course/15-days-of-sql/) by Nikolai Schuler. The goal of this learning sprint was not just to “learn SQL,” but to strengthen my command of PostgreSQL, close long-standing knowledge gaps, and strengthen the areas of SQL that matter most when building scalable, performant, and production-ready database systems.

---

### What This Repository Contains

The notes, scripts, and challenges here explore basic to advanced PostgreSQL concepts, including:

#### Basic concepts

* Functions
* Case statements
* Unions and Joins

#### Advanced Querying

* Correlated subqueries
* Window functions
* GROUPING SETS, CUBE, and ROLLUP
* Common Table Expressions (CTEs)

#### Performance & Optimization

* Indexing strategies
* Query optimization techniques
* Execution plan analysis

#### Database Programming & Management

* User-Defined Functions (UDFs)
* Stored Procedures
* Role and access management

All SQL scripts were written, tested, and executed using PostgreSQL 16, with pgAdmin 16 as the primary database management interface.

---

### Key Skills & Concepts Mastered

* **Window Functions Proficiency**
  Hands-on mastery of `PARTITION BY`, `ORDER BY`, and window functions such as
  `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`, and windowed aggregates.

* **Query Performance Analysis**
  Practical use of `EXPLAIN` and `EXPLAIN ANALYZE` to evaluate query execution paths and apply indexing and optimization strategies.

* **Advanced Data Aggregation**
  Efficient reporting using `GROUPING SETS`, `CUBE`, and `ROLLUP` to produce complex summaries with minimal queries.

* **Procedural SQL Development**
  Writing reusable and modular database logic with PostgreSQL functions and stored procedures.

* **Common Table Expressions (CTEs)**
Structuring complex queries using both standard CTEs for readability and modularity, and recursive CTEs for hierarchical and graph-like problem solving.

---

### Technologies Used

* Database: PostgreSQL 16
* DBMS: pgAdmin 16

---

### Environment Setup

To recreate the environment used in this project:

1. Install **PostgreSQL 16** from the official PostgreSQL website
2. Install **pgAdmin 16**
3. Clone this repository:

   ```bash
   git clone https://github.com/ChijiokeUhegwu/15DaysOfSQL.git
   ```
4. Open pgAdmin and connect to your PostgreSQL server
5. Create a new database named `greencycles`
7. In pgAdmin:

   * Open the Query Tool for the `greencycles` database
   * Load the `pagila-insert-data` SQL file
   * Execute the script (F5) to create the schema and populate sample data
8. Refresh the database to view the created tables

---

### Let’s Connect

Feel free to explore the code and reach out if you’d like to discuss SQL optimization, PostgreSQL development, data analytics, or database design.
You can connect with me on [LinkedIn](https://linkedin.com/in/chijiokeuhegwu) for collaboration or conversations around data.


