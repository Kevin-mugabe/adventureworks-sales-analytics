# adventureworks-sales-analytics
MySQL → Power BI retail sales analytics: star schema, SQL cleaning/modeling, view for revenue/margin, DAX KPIs, Top-N, map

Turn raw CSV exports into a clean star schema and an executive-ready Power BI dashboard. This project demonstrates SQL data cleaning/modeling, view design, indexing, and DAX-based analytics.

---

##  Problem

**Goal:** Build a repeatable pipeline from CSVs → MySQL → Power BI that answers:
- **What** are revenue and gross margin over time?
- **Which** products drive performance?
- **Where** are the strongest regions?

---

##  Data

Source: AdventureWorks retail sample (CSV).  
Tables used here:
- `products`, `customers`, `territories`
- `sales`, `returns`


---

##  Data Model (Star Schema)

**Fact**: `FactSales` (OrderDate, CustomerKey, TerritoryKey, ProductKey, OrderQuantity, surrogate `SalesID`).  
**Dims**: `DimProducts`, `DimCustomers`, `DimTerritories`.  
**View**: `v_SalesWithProducts` (computes LineRevenue, LineCost, LineMargin).

Relationships (in Power BI):
- `FactSales[ProductKey]` → `DimProducts[ProductKey]`
- `FactSales[TerritoryKey]` → `DimTerritories[SalesTerritoryKey]`

---

##  Quick Start (MySQL)

Use  schema name (`adventureworks`).

```sql
USE adventureworks;

-- Peek tables/columns
SHOW TABLES;
DESCRIBE products;
DESCRIBE customers;
DESCRIBE territories;
DESCRIBE sales;
DESCRIBE returns;

-- Staging views (simple aliases; adjust names if yours differ)
DROP VIEW IF EXISTS stg_products;    CREATE VIEW stg_products    AS SELECT * FROM products;
DROP VIEW IF EXISTS stg_customers;   CREATE VIEW stg_customers   AS SELECT * FROM customers;
DROP VIEW IF EXISTS stg_territories; CREATE VIEW stg_territories AS SELECT * FROM territories;
DROP VIEW IF EXISTS stg_sales_all;   CREATE VIEW stg_sales_all   AS SELECT * FROM sales;
DROP VIEW IF EXISTS stg_returns;     CREATE VIEW stg_returns     AS SELECT * FROM returns;

-- Counts
SELECT COUNT(*) AS products    FROM stg_products;
SELECT COUNT(*) AS customers   FROM stg_customers;
SELECT COUNT(*) AS territories FROM stg_territories;
SELECT COUNT(*) AS sales_rows  FROM stg_sales_all;
SELECT COUNT(*) AS returns_rows FROM stg_returns;

-- Dimensions
DROP TABLE IF EXISTS DimProducts;
CREATE TABLE DimProducts AS
SELECT
  CAST(ProductKey AS SIGNED)             AS ProductKey,
  CAST(ProductSubcategoryKey AS SIGNED)  AS ProductSubcategoryKey,
  TRIM(ProductName)                      AS ProductName,
  NULLIF(TRIM(ProductColor), '')         AS ProductColor,
  NULLIF(TRIM(ProductSize),  '')         AS ProductSize,
  NULLIF(TRIM(ProductStyle), '')         AS ProductStyle,
  CAST(REPLACE(REPLACE(ProductCost,'$',''),  ',','') AS DECIMAL(12,2)) AS ProductCost,
  CAST(REPLACE(REPLACE(ProductPrice,'$',''), ',','') AS DECIMAL(12,2)) AS ProductPrice
FROM products;
ALTER TABLE DimProducts ADD PRIMARY KEY (ProductKey);

DROP TABLE IF EXISTS DimCustomers;
CREATE TABLE DimCustomers AS
SELECT
  CAST(CustomerKey AS SIGNED)                          AS CustomerKey,
  NULLIF(TRIM(FirstName), '')                          AS FirstName,
  NULLIF(TRIM(LastName),  '')                          AS LastName,
  NULLIF(TRIM(EmailAddress), '')                       AS EmailAddress,
  CAST(REPLACE(REPLACE(AnnualIncome,'$',''), ',','')   AS DECIMAL(14,2)) AS AnnualIncome,
  CAST(NULLIF(TRIM(TotalChildren), '') AS SIGNED)      AS TotalChildren,
  NULLIF(TRIM(EducationLevel), '')                     AS EducationLevel,
  NULLIF(TRIM(Occupation), '')                         AS Occupation;
ALTER TABLE DimCustomers ADD PRIMARY KEY (CustomerKey);

DROP TABLE IF EXISTS DimTerritories;
CREATE TABLE DimTerritories AS
SELECT
  CAST(SalesTerritoryKey AS SIGNED) AS SalesTerritoryKey,
  TRIM(Region)                      AS Region,
  TRIM(Country)                     AS Country,
  TRIM(Continent)                   AS Continent
FROM territories;
ALTER TABLE DimTerritories ADD PRIMARY KEY (SalesTerritoryKey);

-- Fact
DROP TABLE IF EXISTS FactSales;
CREATE TABLE FactSales AS
SELECT
  COALESCE(
    STR_TO_DATE(TRIM(OrderDate), '%Y-%m-%d'),
    STR_TO_DATE(TRIM(OrderDate), '%m/%d/%Y'),
    STR_TO_DATE(TRIM(OrderDate), '%d/%m/%Y')
  )                              AS OrderDate,
  CAST(CustomerKey AS SIGNED)    AS CustomerKey,
  CAST(TerritoryKey AS SIGNED)   AS TerritoryKey,
  CAST(ProductKey AS SIGNED)     AS ProductKey,
  CAST(OrderQuantity AS SIGNED)  AS OrderQuantity
FROM sales;

-- Surrogate key + indexes
ALTER TABLE FactSales
  ADD COLUMN SalesID BIGINT AUTO_INCREMENT PRIMARY KEY FIRST;
ALTER TABLE FactSales
  MODIFY CustomerKey INT, MODIFY TerritoryKey INT, MODIFY ProductKey INT;
ALTER TABLE FactSales
  ADD INDEX idx_fs_date (OrderDate),
  ADD INDEX idx_fs_prod (ProductKey),
  ADD INDEX idx_fs_terr (TerritoryKey);

-- Returns (optional)
DROP TABLE IF EXISTS FactReturns;
CREATE TABLE FactReturns AS
SELECT
  COALESCE(
    STR_TO_DATE(TRIM(ReturnDate), '%Y-%m-%d'),
    STR_TO_DATE(TRIM(ReturnDate), '%m/%d/%Y'),
    STR_TO_DATE(TRIM(ReturnDate), '%d/%m/%Y')
  )                              AS ReturnDate,
  CAST(TerritoryKey AS SIGNED)   AS TerritoryKey,
  CAST(ProductKey AS SIGNED)     AS ProductKey,
  CAST(ReturnQuantity AS SIGNED) AS ReturnQuantity
FROM returns;
ALTER TABLE FactReturns
  ADD INDEX idx_fr (ReturnDate, TerritoryKey, ProductKey);

-- Revenue/Margin view
DROP VIEW IF EXISTS v_SalesWithProducts;
CREATE VIEW v_SalesWithProducts AS
SELECT
  fs.OrderDate, fs.CustomerKey, fs.TerritoryKey, fs.ProductKey, fs.OrderQuantity,
  p.ProductName, p.ProductPrice, p.ProductCost,
  (fs.OrderQuantity * p.ProductPrice)                         AS LineRevenue,
  (fs.OrderQuantity * p.ProductCost)                          AS LineCost,
  (fs.OrderQuantity * (p.ProductPrice - p.ProductCost))       AS LineMargin
FROM FactSales fs
JOIN DimProducts p ON fs.ProductKey = p.ProductKey;
