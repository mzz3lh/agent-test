CREATE VIEW [AX].[vwSubsPayments]
AS
SELECT 
	[SubsPaymentsId],
	[AccountNum],
	[rics_contactno],
	[SubsCampaign],
	[SettlementDate],
	[SettlementPayGroup],
	[trainee_qualified_code],
	[LocalGroup],
	[CostCentre],
	[Movement],
	[Diff],
	[Payments],
	[AdjustedPayments],
	[NumOfTransactions],
	[rics_concessioncode],
	[rics_paymentcycle]
FROM [Ext].[PBI02_AX_vwSubsPayments]
