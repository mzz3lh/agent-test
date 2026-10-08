CREATE   VIEW [synapse_fo].[vwSubBillDeferralScheduleStatus]
AS
SELECT CAST(tab.[SubBillDeferralScheduleStatus] AS INT) AS [SubBillDeferralScheduleStatus], tab.[Description] FROM(VALUES
(0, 'Active'),
(1, 'Onhold'),
(2, 'Cancelled'),
(3, 'Completed')
) tab (SubBillDeferralScheduleStatus, Description)
