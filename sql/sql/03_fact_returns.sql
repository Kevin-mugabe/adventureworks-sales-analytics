DROP TABLE IF EXISTS FactReturns;
CREATE TABLE FactReturns AS
SELECT
  STR_TO_DATE(TRIM(ReturnDate), '%m/%d/%Y')   AS ReturnDate,
  CAST(TerritoryKey AS SIGNED)                AS TerritoryKey,
  CAST(ProductKey AS SIGNED)                  AS ProductKey,
  CAST(ReturnQuantity AS SIGNED)              AS ReturnQuantity
FROM returns;
ALTER TABLE FactReturns
  ADD INDEX idx_fr (ReturnDate, TerritoryKey, ProductKey);
DROP VIEW IF EXISTS v_SalesWithProducts;
CREATE VIEW v_SalesWithProducts AS
SELECT
  fs.OrderDate,
  fs.CustomerKey,
  fs.TerritoryKey,
  fs.ProductKey,
  fs.OrderQuantity,
  p.ProductName,
  p.ProductPrice,
  p.ProductCost,
  (fs.OrderQuantity * p.ProductPrice) AS LineRevenue,
  (fs.OrderQuantity * p.ProductCost)  AS LineCost,
  (fs.OrderQuantity * (p.ProductPrice - p.ProductCost)) AS LineMargin
FROM FactSales fs
JOIN DimProducts p ON fs.ProductKey = p.ProductKey;
