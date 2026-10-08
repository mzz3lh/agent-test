CREATE   VIEW [FO].[vwVendHoldStatus] AS

SELECT * FROM (
	VALUES
	(0, 'No'),
	(1, 'Invoice'),
	(2, 'All'),
	(3, 'Payment'),
	(4, 'Requisition')
) tab (HoldStatus, HoldStatusDescription)
