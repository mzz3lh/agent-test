CREATE    VIEW [FO].[vwPurchaseOrderStatus]
AS
SELECT * FROM(VALUES
	(0, 'None'),
	(1, 'Open Order'),
	(2, 'Received'),
	(3, 'Invoiced'),
	(4, 'Canceled')
) tab (PurchStatus, Description)
