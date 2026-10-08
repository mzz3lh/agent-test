CREATE   VIEW [synapse_fo].[vwSubBillDeferralScheduleCreationSource] 
AS

SELECT CAST(tab.[SubBillDeferralScheduleCreationSource] AS INT) AS [SubBillDeferralScheduleCreationSource], tab.[Description] FROM(VALUES
	(0, 'StandardTransaction'),
	(1, 'Imported'),
	(2, 'BillingSchedule')
) tab (SubBillDeferralScheduleCreationSource, Description)
