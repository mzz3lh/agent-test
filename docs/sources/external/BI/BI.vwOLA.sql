CREATE VIEW [BI].[vwOLA]
AS

SELECT
	[Transaction Date],
	[Order_Date],
	[Order_Number],
	[CRM_CM_Code],
	[ProductGroup],
	[SET_Value],
	[Digital_Value],
	[International_SET_Value]
FROM [Ext].[PBI02_BI_vwOLA]
