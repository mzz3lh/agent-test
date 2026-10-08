CREATE    VIEW [FO].[vwPaymentSchedule]
AS

SELECT 
	[NAME] AS [PaymentScheduleId],
	[NUMOFPAYMENT] AS [NumberOfPayments],
	[DataAreaId], 
	[LOWESTAMOUNT] AS [MinPayAmount],
	[PAYMBY] AS [AllocationMethod],
	[PERIODUNIT] AS [PaymentFrequencyUnits],
	[MCRMAXORDERVALUE] AS [InstallmentMaximumOrderAmount], 
	[MCRMINORDERVALUE] AS [InstallmentMinimumOrderAmount]
FROM [synapse_fo].[PAYMSCHED]
