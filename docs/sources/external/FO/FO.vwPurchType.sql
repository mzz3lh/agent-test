CREATE    VIEW [FO].[vwPurchType]
AS
SELECT * FROM(VALUES
	(0, 'Journal'),
	(1, 'Quotation'),
	(2, 'Subscription'),
	(3, 'Purchase Order'),
	(4, 'Returned Order'),
	(5, 'Purchase and Sales Agreement')
) tab (PurchType, Description)
