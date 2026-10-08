CREATE VIEW [BI].[vwIPGSales_CRM_Digital]
AS

SELECT
	[SalesOrderId],
	[SalesOrder_Name],
	[ProductGroupId],
	[Description],
	[Date_Fulfilled],
	[Total_LineItem_Amount],
	[SalesTeamId],
	[Created_On],
	[CreatedBy],
	[Modified_On],
	[Subscription_Renewal],
	[Subscription_Auto_Renewal],
	[Customer_Name],
	[Registered_Name],
	[Organisation],
	[Contact_No],
	[OnBehalf_Of_Organisation],
	[OnBehalf_Of_Organisation_Renewal],
	[Office_Number],
	[Payment_Method],
	[Transaction_Id],
	[Order_Id],
	[Sales_Type],
	[IPG_Code]
FROM [Ext].[PBI02_BI_vwIPGSales_CRM_Digital]
