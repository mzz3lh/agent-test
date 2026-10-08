CREATE VIEW [BI].[vwCampaigns]
AS

SELECT
	[Campaigns_Id],
	[ProductGroupId],
	[Product Group Description],
	[Product Group],
	[Campaign Value Type],
	[Transaction Date],
	[Value Target],
	[Value Actual],
	[Sales Target MTD]
FROM [Ext].[PBI02_BI_vwCampaigns]
