CREATE VIEW [AX].[vwRenewalsConcessionsRemoved]
AS
SELECT 
	[SubsCampaign],
	[ACCOUNTNUM],
	[CostCentre],
	[currency],
	[Discounted],
	[DiscountedGBP],
	[FullGradeFee],
	[FullGradeFeeGBP],
	[rics_membergrade],
	[rics_concessioncode]
FROM [Ext].[PBI02_AX_vwRenewalsConcessionsRemoved]
