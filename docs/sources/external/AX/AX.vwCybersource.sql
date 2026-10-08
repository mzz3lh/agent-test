CREATE VIEW [AX].[vwCybersource]
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
FROM [Ext].[PBI02_AX_vwCybersource]
