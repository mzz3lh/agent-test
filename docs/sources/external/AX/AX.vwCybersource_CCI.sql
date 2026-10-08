CREATE VIEW [AX].[vwCybersource_CCI]
AS

SELECT
	[rics_contactno],
	[subscampaign],
	[orderreference],
	[scheduleamount],
	[ExpectedPayments],
	[currency],
	[PaymentsMade],
	[SumPayments],
	[startdate],
	[EndDate],
	[subscriptionid]
FROM [Ext].[PBI02_AX_vwCybersource_CCI]
