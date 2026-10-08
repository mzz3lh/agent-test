CREATE VIEW [AX].[vwAXInvoiceType]
AS
SELECT
	[ricinvtype],
	[description],
	[sourcesystem],
	[invgroup]
FROM [Ext].[PBI02_AX_vwAXInvoiceType]
