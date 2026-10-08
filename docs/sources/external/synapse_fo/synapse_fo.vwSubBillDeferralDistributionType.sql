CREATE   VIEW [synapse_fo].[vwSubBillDeferralDistributionType]
AS
SELECT CAST(tab.[SubBillDeferralDistributionType] AS INT) AS [SubBillDeferralDistributionType], tab.[Description] FROM(VALUES
(0, 'None'),
(1, 'Revenue'),
(2, 'Expense'),
(3, 'Discount'),
(4, 'Consumption'),
(5, 'RevenueCharge'),
(6, 'ExpenseCharge')
) tab (SubBillDeferralDistributionType, Description)
