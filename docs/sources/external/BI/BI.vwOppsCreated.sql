CREATE VIEW [BI].[vwOppsCreated]
AS

SELECT
	[Opportunity_Key],
	[SalesCycleStage],
	[Close_Probability],
	[Product Group Description],
	[ProductGroupId],
	[Product Group],
	[Product],
	[Product Group Old],
	[SalesTeamId],
	[Sales Team],
	[Owner],
	[Marketing Source],
	[Marketing Team],
	[Transaction Date],
	[Est_Close_Date],
	[CreatedOn],
	[Created_By],
	[Modified_On],
	[Modified_By],
	[Potential_Customer],
	[Act_Close_Date],
	[Actual Revenue],
	[Est. Revenue],
	[Opportunity_State],
	[Opportunity_Status],
	[Territory],
	[Topic]
FROM [Ext].[PBI02_BI_vwOppsCreated]
