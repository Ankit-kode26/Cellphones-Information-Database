--SQL Advance Case Study


--Q1--BEGIN 

	Select distinct L.State from DIM_LOCATION AS L 
	INNER JOIN FACT_TRANSACTIONS AS FT 
	ON L.IDLocation = FT.IDLocation
	INNER JOIN DIM_CUSTOMER AS C 
	ON FT.IDCustomer = C.IDCustomer
	WHERE FT.Date BETWEEN CAST('01/01/2005' AS DATE) 
									AND 
						  CAST(GETDATE() AS DATE)


--Q1--END

--Q2--BEGIN
	
select top 1 STATE from DIM_LOCATION as L
inner join FACT_TRANSACTIONS as FT 
ON L.IDLocation=FT.IDLocation

inner JOIN DIM_MODEL AS M 
ON FT.IDModel = M.IDModel

inner JOIN DIM_MANUFACTURER AS MA
ON M.IDManufacturer = MA.IDManufacturer

WHERE MA.Manufacturer_Name LIKE 'SAMSUNG'
GROUP BY STATE
ORDER BY COUNT(M.IDModel) desc	

 
--Q2--END

--Q3--BEGIN      
	

SELECT  DISTINCT Model_Name,STATE,ZipCode, COUNT(FT.IDLocation) AS NUM_OF_TRANSAC FROM DIM_LOCATION AS L
LEFT JOIN FACT_TRANSACTIONS AS FT 
ON L.IDLocation = FT.IDLocation
INNER JOIN DIM_MODEL AS M 
ON FT.IDModel = M.IDModel
GROUP BY Model_Name,STATE,ZipCode


--Q3--END

--Q4--BEGIN

SELECT TOP 1  *
FROM DIM_MODEL
ORDER BY Unit_price ASC 

--Q4--END

--Q5--BEGIN

--- METHOD 1

SELECT * FROM FACT_TRANSACTIONS AS FT 
INNER JOIN DIM_MODEL AS D
ON D.IDModel = FT.IDModel
INNER JOIN DIM_MANUFACTURER AS DM
ON D.IDManufacturer = DM.IDManufacturer

-- METHOD 2 

WITH TOP5_MANUFACTURER AS 

(
		SELECT TOP 5 
		    MA.Manufacturer_Name, 
		    SUM(FT.Quantity) AS QUANTITY,
		    AVG(FT.TotalPrice) AS AVG_PRICE
		FROM FACT_TRANSACTIONS AS FT 
		INNER JOIN DIM_MODEL AS M ON FT.IDModel = M.IDModel
		INNER JOIN DIM_MANUFACTURER AS MA ON M.IDManufacturer = MA.IDManufacturer
		GROUP BY MA.Manufacturer_Name
		ORDER BY QUANTITY ASC,AVG_PRICE ASC
	
) 


SELECT MM.Manufacturer_Name AS MANUFACTURER,M.Model_Name AS MODEL_NAME
,AVG(FT.TotalPrice) AS AVG_PRICE_MODEL_WISE
FROM FACT_TRANSACTIONS AS FT 
INNER JOIN DIM_MODEL AS M 
ON FT.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS MM 
ON M.IDManufacturer = MM.IDManufacturer
WHERE MM.Manufacturer_Name IN (SELECT Manufacturer_Name FROM TOP5_MANUFACTURER)
GROUP BY MM.Manufacturer_Name , M.Model_Name




--Q5--END

--Q6--BEGIN

Select C.Customer_Name,YEAR(Date) AS YEAR,AVG(TotalPrice) AS AVG_SPENT_IN_2009 
from DIM_CUSTOMER as C
inner join FACT_TRANSACTIONS AS FT
on C.IDCustomer = FT.IDCustomer
WHERE YEAR(DATE) = 2009
GROUP BY Customer_Name,Date
HAVING AVG(TotalPrice) > 500

--Q6--END
	
--Q7--BEGIN  
	
SELECT * from (
	SELECT top 5 M.IDModel,m.Model_Name,YEAR(FT.Date) AS YEARS,Sum(FT.Quantity) AS TOTAL_QTY FROM DIM_MODEL AS M 
	INNER JOIN FACT_TRANSACTIONS AS FT 
	ON M.IDModel = FT.IDModel
	WHERE YEAR(FT.DATE) = 2008
	GROUP BY M.IDModel,m.Model_Name,YEAR(FT.Date)
	ORDER BY TOTAL_QTY DESC
) AS X

INTERSECT

SELECT * FROM 
(
	SELECT top 5 M.IDModel,m.Model_Name,YEAR(FT.Date) AS YEARS,Sum(FT.Quantity) AS TOTAL_QTY FROM DIM_MODEL AS M 
	INNER JOIN FACT_TRANSACTIONS AS FT 
	ON M.IDModel = FT.IDModel
	WHERE YEAR(FT.DATE) = 2009
	GROUP BY M.IDModel,m.Model_Name,YEAR(FT.Date)
	ORDER BY TOTAL_QTY DESC
) AS Y

INTERSECT

SELECT * FROM (
	SELECT top 5 M.IDModel,m.Model_Name,YEAR(FT.Date) AS YEARS,Sum(FT.Quantity) AS TOTAL_QTY FROM DIM_MODEL AS M 
	INNER JOIN FACT_TRANSACTIONS AS FT 
	ON M.IDModel = FT.IDModel
	WHERE YEAR(FT.DATE) = 2010
	GROUP BY M.IDModel,m.Model_Name,YEAR(FT.Date)
	ORDER BY TOTAL_QTY DESC
) AS Z

--Q7--END	

--Q8--BEGIN

--- manufacturer with the 2nd top sales in the year of 2009
SELECT distinct Manufacturer_Name,[year], sales from 
(

SELECT MA.Manufacturer_Name,YEAR(Date) AS [Year],SUM(TotalPrice) AS SALES,
DENSE_RANK() OVER (ORDER BY SUM(FT.TotalPrice) DESC) AS SALESRANK

FROM FACT_TRANSACTIONS AS FT 
INNER JOIN DIM_MODEL AS M 
ON FT.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS MA 
ON M.IDManufacturer = MA.IDManufacturer

WHERE YEAR(FT.Date) = 2009
GROUP BY MA.Manufacturer_Name,FT.Date

)as RankedSales
Where SALESRANK = 2

Union 

---manufacturer with the 2nd top sales in the year of 2010
SELECT Distinct Manufacturer_Name,[year], sales from 
(

SELECT MA.Manufacturer_Name,YEAR(Date) AS [Year],SUM(TotalPrice) AS SALES,
DENSE_RANK() OVER (ORDER BY SUM(FT.TotalPrice) DESC) AS SALESRANK

FROM FACT_TRANSACTIONS AS FT 
INNER JOIN DIM_MODEL AS M 
ON FT.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS MA 
ON M.IDManufacturer = MA.IDManufacturer

WHERE YEAR(FT.Date) = 2010
GROUP BY MA.Manufacturer_Name,FT.Date
)as RankedSales
Where SALESRANK = 2

--Q8--END
--Q9--BEGIN

SELECT MA.Manufacturer_Name AS MANUFACTURE_NAME_2010 FROM FACT_TRANSACTIONS AS FT 
INNER JOIN DIM_MODEL AS M 
ON FT.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS MA 
ON M.IDManufacturer = MA.IDManufacturer
WHERE  YEAR(FT.Date) =2010

EXCEPT

SELECT MA.Manufacturer_Name AS MANUFACTURE_NAME_2009  FROM FACT_TRANSACTIONS AS FT 
INNER JOIN DIM_MODEL AS M 
ON FT.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS MA 
ON M.IDManufacturer = MA.IDManufacturer
WHERE YEAR(FT.Date) =2009

--Q9--END

--Q10--BEGIN
	
WITH TOP_10 AS (
    SELECT TOP 10 IDCustomer 
    FROM FACT_TRANSACTIONS
    GROUP BY IDCustomer
    ORDER BY SUM(TotalPrice) DESC
),
AVG_SPEND_YEAR AS (
    SELECT 
        FT.IDCustomer, 
        YEAR(FT.DATE) AS YEARS, 
        AVG(FT.TotalPrice) AS AVG_SPEND, 
        AVG(FT.QUANTITY) AS AVGV_QUANTITY,
        LAG(AVG(FT.TotalPrice)) OVER (PARTITION BY FT.IDCustomer ORDER BY YEAR(FT.DATE)) AS PREVIOUS_SPEND
    FROM FACT_TRANSACTIONS AS FT 
    INNER JOIN DIM_CUSTOMER AS D
    ON FT.IDCustomer = D.IDCustomer
    WHERE FT.IDCustomer IN (SELECT IDCustomer FROM TOP_10)
    GROUP BY FT.IDCustomer, YEAR(FT.DATE)
)
SELECT * FROM AVG_SPEND_YEAR

--Q10--END	