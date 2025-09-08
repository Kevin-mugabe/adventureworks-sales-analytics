DROP TABLE IF EXISTS DimProducts;
CREATE TABLE DimProducts AS
SELECT
  CAST(ProductKey AS SIGNED)                           AS ProductKey,
  CAST(ProductSubcategoryKey AS SIGNED)               AS ProductSubcategoryKey,
  TRIM(ProductName)                                   AS ProductName,
  NULLIF(TRIM(ProductColor), '')                      AS ProductColor,
  NULLIF(TRIM(ProductSize), '')                       AS ProductSize,
  NULLIF(TRIM(ProductStyle), '')                      AS ProductStyle,
  CAST(REPLACE(REPLACE(ProductCost,  '$',''), ',','') AS DECIMAL(12,2)) AS ProductCost,
  CAST(REPLACE(REPLACE(ProductPrice, '$',''), ',','') AS DECIMAL(12,2)) AS ProductPrice
FROM products;
ALTER TABLE DimProducts ADD PRIMARY KEY (ProductKey);
DROP TABLE IF EXISTS DimCustomers;
CREATE TABLE DimCustomers AS
SELECT
  CAST(CustomerKey AS SIGNED)                         AS CustomerKey,
  NULLIF(TRIM(FirstName), '')                         AS FirstName,
  NULLIF(TRIM(LastName), '')                          AS LastName,
  NULLIF(TRIM(EmailAddress), '')                      AS EmailAddress,
  CAST(REPLACE(REPLACE(AnnualIncome,'$',''), ',','')  AS DECIMAL(14,2)) AS AnnualIncome,
  CAST(NULLIF(TRIM(TotalChildren), '') AS SIGNED)     AS TotalChildren,
  NULLIF(TRIM(EducationLevel), '')                    AS EducationLevel,
  NULLIF(TRIM(Occupation), '')                        AS Occupation,
  CASE
    WHEN UPPER(TRIM(HomeOwnerFlag)) IN ('Y','YES','1','TRUE') THEN 1
    WHEN UPPER(TRIM(HomeOwnerFlag)) IN ('N','NO','0','FALSE') THEN 0
    ELSE NULL
  END                                                 AS HomeOwnerFlag
FROM customers;
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
