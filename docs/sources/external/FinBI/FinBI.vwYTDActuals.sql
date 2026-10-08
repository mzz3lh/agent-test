CREATE VIEW [FinBI].[vwYTDActuals]
AS
SELECT 
	[TransPeriod],
	[GLAccount],
	[CostCentre],
	[Entity],
	[SumAmountCur],
	[CURRENCYCODE],
	[SumAmountGBP],
	[SumAmountMST]
FROM [Ext].[PBI02_FinBI_vwYTDActuals]
