CREATE VIEW [DQ].[vwDomain] AS 

	SELECT 
	L1 AS 'Domain'
	FROM [DQ].[DataMap]
	GROUP BY L1
