DROP VIEW IF EXISTS stg_products;
CREATE VIEW stg_products AS SELECT * FROM products;

DROP VIEW IF EXISTS stg_customers;
CREATE VIEW stg_customers AS SELECT * FROM customers;

DROP VIEW IF EXISTS stg_territories;
CREATE VIEW stg_territories AS SELECT * FROM territories;

DROP VIEW IF EXISTS stg_sales_all;
CREATE VIEW stg_sales_all AS
SELECT * FROM sales;

DROP VIEW IF EXISTS stg_returns;
CREATE VIEW stg_returns AS SELECT * FROM returns;
