CREATE VIEW [BI].[vwMarketingInfluencedWorking]
AS

SELECT
	[Opportunity_Key],
	[Marketing Team],
	[Marketing Source],
	[ProductGroupId],
	[Product Group],
	[Product Group Description],
	[Transaction Date],
	[Estimated Close Date],
	[Created_On],
	[Created_By],
	[Modified_On],
	[Modified_By],
	[Act_Close_Date],
	[Est. Revenue],
	[Exp. Revenue],
	[Act. Revenue],
	[Probability],
	[Sales Cycle Stage],
	[Leads Status],
	[Topic],
	[Owner],
	[Sales Team],
	[Company_Name],
	[Opportunity_State],
	[Opportunity_Status]
FROM [Ext].[PBI02_BI_vwMarketingInfluencedWorking]
