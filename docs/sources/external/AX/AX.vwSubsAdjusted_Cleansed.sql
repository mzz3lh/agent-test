CREATE VIEW [AX].[vwSubsAdjusted_Cleansed]
AS
SELECT 
	[SubsAdjustedId],
	[AccountNum],
	[rics_contactno],
	[Rics_LapsedDate],
	[Rics_MemberGrade],
	[Voucher],
	[SubsCampaign],
	[CostCentre],
	[OriginalAmount],
	[AdjustedAmount],
	[Paid],
	[TotalPaid],
	[diff],
	[BalanceGBP],
	[Movement],
	[LocalGroup],
	[rics_concessioncode],
	[trainee_qualified_code],
	[dncCategory],
	[rics_lapsedcode]
FROM [Ext].[PBI02_AX_vwSubsAdjusted_Cleansed]
