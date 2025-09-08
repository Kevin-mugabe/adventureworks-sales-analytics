DROP TABLE IF EXISTS FactSales;
CREATE TABLE FactSales AS
SELECT
  STR_TO_DATE(TRIM(OrderDate), '%m/%d/%Y')    AS OrderDate,
  CAST(CustomerKey AS SIGNED)                 AS CustomerKey,
  CAST(TerritoryKey AS SIGNED)                AS TerritoryKey,
  CAST(ProductKey AS SIGNED)                  AS ProductKey,
  CAST(OrderQuantity AS SIGNED)               AS OrderQuantity
FROM sales;


ALTER TABLE `FactSales`
  ADD COLUMN `SalesID` BIGINT AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE `FactSales`
  MODIFY `CustomerKey`  INT,
  MODIFY `TerritoryKey` INT,
  MODIFY `ProductKey`   INT;


ALTER TABLE `FactSales`
  ADD INDEX idx_fs_date (`OrderDate`),
  ADD INDEX idx_fs_prod (`ProductKey`),
  ADD INDEX idx_fs_terr (`TerritoryKey`);
