CREATE   VIEW [FO].[vwInventItemType]
AS
SELECT * FROM(VALUES
	(0, 'Item'),
	(1, 'Outdated'),
	(2, 'Service'),
	(3, 'Outdated'),
	(100, 'Fixed assets')
) tab(InventItemType, Description)
