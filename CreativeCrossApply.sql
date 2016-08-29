USE TSQL2012
GO

----   Creative CROSS APPLY    ----
----   Example from Creative Use of Apply   ----
----   Author: Itzik Ben-Gan    ----
SELECT 
	orderid, orderdate ,a1.orderyear, a2.nextyear
FROM
	sales.Orders
	CROSS APPLY (values(year(orderdate))) AS a1(orderyear) -- 1000 rows in this (values(...),(...),etc) clause
	CROSS APPLY (values(orderyear +1)) AS a2(nextyear) 
WHERE
	orderyear > 2007;
GO