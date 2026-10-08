CREATE VIEW [BI].[vwBookshopSales_CRM]
AS

SELECT
	[SalesOrderId],
	[Transaction_Id],
	[OrderNumber],
	[productgroupid],
	[productgroup],
	[targetgroup],
	[Transaction Date],
	[Created_On],
	[CreatedByName],
	[Modified_On],
	[ModifiedByName],
	[ricsv1_ProductOwnerName],
	[Owner],
	[SalesOrder_Name],
	[Description],
	[TotalAmount],
	[Value NET],
	[Payment_Method],
	[StateCode],
	[StatusCode],
	[CustomerIdName],
	[DateFulfilled]
FROM [Ext].[PBI02_BI_vwBookshopSales_CRM]
