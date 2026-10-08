CREATE VIEW [AX].[vwSubsCampaignDates]
AS
SELECT 
	[SubsCampaign],
	[RenewalDate],
	[CampaignStart],
	[CampaignEnd],
	[CurrentCampaign],
	[CurrentCampaignDesc]
FROM [Ext].[PBI02_AX_vwSubsCampaignDates]
