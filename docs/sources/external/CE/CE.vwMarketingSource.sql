CREATE   VIEW [CE].[vwMarketingSource]
AS 
SELECT 
	[Marketing_Source_Id],
	[Marketing_Source],
	[Marketing_Team],
	[RICS_MarketingSource_Id],
	[State_Code],
	[Created_On],
	[Created_By],
	[Modified_On],
	[Modified_By]
FROM [synapse_ce].[vwMarketingSource]
