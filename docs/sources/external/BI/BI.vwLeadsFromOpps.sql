CREATE VIEW [BI].[vwLeadsFromOpps]
AS

SELECT
	[Opportunity_Key],
	[Marketing Team],
	[Marketing Source],
	[ProductGroupId],
	[Product Group],
	[Product Group Description],
	[Transaction Date],
	[Created_On],
	[Created_By],
	[Modified_On],
	[Modified_By],
	[Est. Revenue],
	[Exp. Revenue],
	[Probability],
	[Sales Cycle Stage],
	[Leads Status],
	[Status Code],
	[Topic],
	[Sales Team],
	[Owner],
	[Parent_Contact],
	[Company_Name]
FROM [Ext].[PBI02_BI_vwLeadsFromOpps]
