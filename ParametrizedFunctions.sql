/* 1. Create a parametrized function to obtain the top 10 customers by amount ordered within a specific time period and state */
USE SQLBook;
IF object_id(N'A012320272_GetCustomerWithMostOrders', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetCustomerWithMostOrders
GO

CREATE FUNCTION A012320272_GetCustomerWithMostOrders
(   
    @startDate DateTime,
	@endDate DateTime,
	@state varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT TOP(10)
   o.[CustomerId],
   o.[total_orders],
   o.[zipcode],
   zc.[ZIPName],
   zc.[Stab] AS [state]
FROM (
   SELECT
      [CustomerId],
	  [ZipCode],
      [state],
      SUM([TotalPrice]) as [total_orders],
      ROW_NUMBER() OVER (PARTITION BY [CustomerId] ORDER BY SUM([TotalPrice]) DESC) as [row_number]
   FROM [SQLBook].[dbo].[Orders]
   WHERE [orderdate] >= @startDate AND  
	     [orderdate] < @endDate
   AND [state] = @state
   GROUP BY [CustomerId], [state], [ZipCode]
) o
JOIN
      [SQLBook].[dbo].[ZipCensus] zc
      ON zc.[zcta5] = o.[zipcode]
WHERE [row_number] = 1
ORDER BY [total_orders] DESC
);
GO
SELECT * FROM A012320272_GetCustomerWithMostOrders('2014-10-01', '2015-01-31', 'TX');
GO

/* 2. Create a function to find the top 5 cities based on order amount in a particular state and within a specific time period */
USE SQLBook;
IF object_id(N'A012320272_GetCitiesWithMostOrders', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetCitiesWithMostOrders
GO

CREATE FUNCTION A012320272_GetCitiesWithMostOrders
(   
    @startDate DateTime,
	@endDate DateTime,
	@state varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT TOP(5)
   o.[zipcode],
   zc.[ZIPName],
   zc.[Stab] AS [state],
   o.[total_orders]
FROM (
   SELECT
	  [ZipCode],
      [State],
      SUM([TotalPrice]) as [total_orders],
      ROW_NUMBER() OVER (PARTITION BY [ZipCode] ORDER BY SUM([TotalPrice]) DESC) as [row_number]
   FROM [SQLBook].[dbo].[Orders]
   WHERE [orderdate] >= @startDate AND  
	     [orderdate] < @endDate
   AND [State] = @state
   GROUP BY [ZipCode], [State]
) o
JOIN
      [SQLBook].[dbo].[ZipCensus] zc
      ON zc.[zcta5] = o.[zipcode]
WHERE [row_number] = 1
ORDER BY [total_orders] DESC
);
GO
SELECT * FROM A012320272_GetCitiesWithMostOrders('2014-12-01', '2015-01-31', 'TX');
GO

/* 3. Find the top 25 customers of all time based on amount ordered within a particular state and payment method - VI, MC, AE, DB */
USE SQLBook;
IF object_id(N'A012320272_GetCustomerWithMostOrderPerPaymentType', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetCustomerWithMostOrderPerPaymentType
GO

CREATE FUNCTION A012320272_GetCustomerWithMostOrderPerPaymentType
(   
	@state varchar(50),
	@paymentType varchar(10)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT TOP(25)
   o.[CustomerId],
   o.[total_orders],
   o.[zipcode],
   o.[PaymentType],
   zc.[ZIPName],
   zc.[Stab] AS [state]
FROM (
   SELECT
      [CustomerId],
	  [ZipCode],
      [state],
	  [PaymentType],
	  SUM([TotalPrice]) as [total_orders],
      ROW_NUMBER() OVER (PARTITION BY [CustomerId] ORDER BY SUM([TotalPrice]) DESC) as [row_number]
   FROM [SQLBook].[dbo].[Orders] 
   WHERE [State] = @state AND  
	     [PaymentType] = @paymentType
   GROUP BY [CustomerId], [ZipCode], [State], [PaymentType]
) o
JOIN
      [SQLBook].[dbo].[ZipCensus] zc
      ON zc.[zcta5] = o.[zipcode]
WHERE [row_number] = 1
ORDER BY [total_orders] DESC
);
GO
SELECT * FROM A012320272_GetCustomerWithMostOrderPerPaymentType('CA', 'AE');
GO

/* 4.  Create function to obtain top 10 cities based on average order amount per state and campaign id - also list number of orders */ 
USE SQLBook;
IF object_id(N'A012320272_GetCitiesWithHighestAvgOrdersperCampaign', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetCitiesWithHighestAvgOrdersperCampaign
GO

CREATE FUNCTION A012320272_GetCitiesWithHighestAvgOrdersperCampaign
(   
	@state varchar(50),
	@campaignId int
)
RETURNS TABLE 
AS
RETURN 
(
SELECT TOP(10)
   o.[zipcode],
   o.[CampaignId],
   o.[City],
   zc.[ZIPName],
   zc.[Stab] AS [state],
   o.[avg_order],
   o.[num_of_orders]
FROM (
   SELECT
	  [ZipCode],
	  [City],
      [State],
	  [CampaignId],
	  COUNT(*) AS [num_of_orders],
      AVG([TotalPrice]) as [avg_order],
      ROW_NUMBER() OVER (PARTITION BY [ZipCode] ORDER BY AVG([TotalPrice]) DESC) as [row_number]
   FROM [SQLBook].[dbo].[Orders]
   WHERE [State] = @state
   AND [CampaignId] = @campaignId
   GROUP BY [ZipCode], [City], [State], [CampaignId]
) o
JOIN
      [SQLBook].[dbo].[ZipCensus] zc
      ON zc.[zcta5] = o.[zipcode]
WHERE [row_number] = 1
ORDER BY [avg_order] DESC
);
GO
SELECT * FROM A012320272_GetCitiesWithHighestAvgOrdersperCampaign('TX', '2236');
GO

/* 5.  Create a function to find ZIPNames in a state where percentage of people in the age group of 25 - 34 is more than a certain amount*/
USE SQLBook;
IF object_id(N'A012320272_GetCitiesWithPercentageofPeople2534', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetCitiesWithPercentageofPeople2534
GO

CREATE FUNCTION A012320272_GetCitiesWithPercentageofPeople2534
(   
	@state varchar(50),
	@pctAge25_34 int
)
RETURNS TABLE 
AS
RETURN 
(
SELECT TOP(25)
   [ZIPName],
   [Stab],
   [pctAge25_34]
   FROM [SQLBook].[dbo].[ZipCensus]
   WHERE [pctAge25_34] > @pctAge25_34
   AND [Stab] = @state
ORDER BY [pctAge25_34] DESC
);
GO
SELECT * FROM A012320272_GetCitiesWithPercentageofPeople2534('TX', 0.4);
GO   

/* 6. Create a function to obtain top 10 customers based on total orders within a specified time period, specific state and campaign id */ 
USE SQLBook;
IF object_id(N'A012320272_GetCustomerwithMostOrderPerStatePerCampaignWithinDateRange', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetCustomerwithMostOrderPerStatePerCampaignWithinDateRange
GO

CREATE FUNCTION A012320272_GetCustomerwithMostOrderPerStatePerCampaignWithinDateRange
(   
    @startDate DateTime,
	@endDate DateTime,
	@state varchar(50),
	@campaignid int
)
RETURNS TABLE 
AS
RETURN 
(
SELECT TOP(10)
   o.[CustomerId],
   zc.[ZIPName],
   o.[total_orders],
   o.[CampaignId],
   zc.[Stab] AS [state]
FROM (
   SELECT
	  [CustomerId],
      [State],
	  [CampaignId],
	  [zipcode],
      SUM([TotalPrice]) as [total_orders],
      ROW_NUMBER() OVER (PARTITION BY [CustomerId] ORDER BY SUM([TotalPrice]) DESC) as [row_number]
   FROM [SQLBook].[dbo].[Orders]
   WHERE [orderdate] >= @startDate AND  
	     [orderdate] < @endDate
		AND [State] = @state
		AND [CampaignId] = @campaignid
   GROUP BY [CustomerId], [ZipCode], [State], [CampaignId]
) o
JOIN
      [SQLBook].[dbo].[ZipCensus] zc
      ON zc.[zcta5] = o.[zipcode]
WHERE [row_number] = 1
ORDER BY [total_orders] DESC
);
GO
SELECT * FROM A012320272_GetCustomerwithMostOrderPerStatePerCampaignWithinDateRange('2014-12-01', '2015-01-31', 'TX', '2236');
GO

/*7. Create function to get product ID within a certain group code that are in and out of stock */
USE SQLBook;
IF object_id(N'A012320272_InandOutofStock', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_InandOutofStock
GO

CREATE FUNCTION A012320272_InandOutofStock
(   
	@groupCode varchar(50),
	@IsInStock char(1)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT
   o.[ProductId],
   o.[GroupCode],
   o.[IsInStock]
FROM (
   SELECT
      [ProductId],
	  [GroupCode],
      [IsInStock]
   FROM [SQLBook].[dbo].[Products] 
   WHERE [GroupCode] = @groupCode AND  
	     [IsInStock] = @IsInStock
) o
);
GO
SELECT * FROM A012320272_InandOutofStock('AR', 'N');
GO

/* 8. Create a function to see the products that have difference in order date and ship date within certain time period  */
USE SQLBook;
IF object_id(N'A012320272_GetDelayedOrders', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetDelayedOrders
GO

CREATE FUNCTION A012320272_GetDelayedOrders
(   
    @startDate DateTime,
	@endDate DateTime,
	@delay int
)
RETURNS TABLE 
AS
RETURN 
(
SELECT
   tbl.[OrderId],
   tbl.[CustomerId],
   tbl.[ProductId],
   tbl.[Delay],
   tbl.[City]
FROM (
   SELECT 
	od.OrderId,
	o.CustomerId,
	o.City,
	od.ProductId,
	(DATEDIFF(Day, o.[OrderDate], od.[ShipDate])) AS [Delay]	
	FROM [SQLBook].[dbo].[OrderLines] od
	JOIN [SQLBook].[dbo].[Orders] o
	ON Od.OrderId = O.OrderId
	WHERE [BillDate] >= @startDate 
	AND  [BillDate] < @endDate
	AND (DATEDIFF(Day, o.[OrderDate], od.[ShipDate])) > @delay
) tbl
);
GO
SELECT * FROM A012320272_GetDelayedOrders('2014-12-01', '2015-01-31', 30);
GO

/* 9. Create a function to see what the top 25 most ordered product is in a particular state during a particular time period*/
USE SQLBook;
IF object_id(N'A012320272_MostOrderedProduct', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_MostOrderedProduct
GO

CREATE FUNCTION A012320272_MostOrderedProduct
(   
    @startDate DateTime,
	@endDate DateTime,
	@state varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
   tbl.[ProductId],
   tbl.[units_ordered]
FROM (
   SELECT TOP(25)
	od.ProductId,
	SUM(od.NumUnits) AS [units_ordered]
	FROM [SQLBook].[dbo].[OrderLines] od
	JOIN [SQLBook].[dbo].[Orders] o
	ON Od.OrderId = O.OrderId
	WHERE [BillDate] >= @startDate 
	AND  [BillDate] < @endDate
	AND [State] = @state
	GROUP BY od.ProductId
	ORDER BY [units_ordered] DESC
) tbl
);
GO
SELECT * FROM A012320272_MostOrderedProduct('2014-12-01', '2015-01-31', 'CA');
GO
/* 10.  Create a function to find the top 25 tenure subscribers based on their rate plan, market and channel*/
USE SQLBook;
IF object_id(N'A012320272_GetLongestTenure', N'IF') IS NOT NULL
    DROP FUNCTION A012320272_GetLongestTenure
GO

CREATE FUNCTION A012320272_GetLongestTenure
(   
    @ratePlan VARCHAR(6),
	@market VARCHAR(10),
	@channel VARCHAR(6)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT
   tbl.[SubscriberId],
   tbl.[Tenure]
FROM (
   SELECT TOP(25)
	SubscriberId,
	Tenure
	FROM [SQLBook].[dbo].[Subscribers]
	WHERE [RatePlan] = @ratePlan
	AND  [Market] = @market
	AND [Channel] = @channel
	ORDER BY [Tenure] DESC
) tbl
);
GO
SELECT * FROM A012320272_GetLongestTenure('Bottom', 'Gotham', 'Mail');
GO

