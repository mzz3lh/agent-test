CREATE   VIEW [synapse_fo].[vwSubBillDeferralTransactionType]
AS
SELECT CAST(tab.[SubBillDeferralTransactionType] AS INT) AS [SubBillDeferralTransactionType], tab.[Description] FROM(VALUES
(1, 'SalesOrder'),
(2, 'PurchaseOrder'),
(3, 'GeneralJournal'),
(4, 'FreeTextInvoice'),
(5, 'InvoiceJournal'),
(6, 'ProjectFee'),
(7, 'VendInvoice'),
(8, 'BillingSchedule'),
(9, 'ProjectItem'),
(10, 'ProjectExpense'),
(11, 'ProjectHour'),
(12, 'ExpenseReport'),
(13, 'Timesheet'),
(14, 'ItemReq')
) tab (SubBillDeferralTransactionType, Description)
