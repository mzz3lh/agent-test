CREATE VIEW [AX].[vwSubsRenewals]
AS
SELECT 
	[SubsCampaign],
	[rics_contactno],
	[axaccountno],
	[subsduemst],
	[subsduecur],
	[currency],
	[localgroup],
	[rics_membergrade],
	[CostCentre],
	[CountryCode],
	[rics_concessioncode],
	[rics_paymentmethod],
	[rics_paymentcycle],
	[dualmembership],
	[membercount],
	[ACCOUNTNUM],
	[TransDate]
FROM [Ext].[PBI02_AX_vwSubsRenewals]
