CREATE   VIEW [synapse_fo].[vwSubBillDeferralScheduleType]
AS
SELECT CAST(tab.[SubBillDeferralScheduleType] AS INT) AS [SubBillDeferralScheduleType], tab.[Description] FROM(VALUES
(0, 'StraightLine'),
(1, 'EventBased')
) tab (SubBillDeferralScheduleType, Description)
