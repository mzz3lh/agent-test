CREATE VIEW [BI].[vwDRSAppts_CRM]
AS

SELECT
	[DRS_Appts_Key],
	[Application_Reference],
	[Application_Type],
	[Status_Code_Id],
	[Status_Code],
	[Selection_Required_By_Date],
	[Transaction Date],
	[Owner_Id],
	[Owner],
	[Sales_Team],
	[Modified_On],
	[Modified_By],
	[Created_On],
	[Created_By],
	[Application_Street1],
	[Application_PostCode],
	[Application_City],
	[Payment_Type_Id],
	[Payment_Type],
	[Payment_Status_Id],
	[Payment_Status],
	[Value NET],
	[Payment_Value_Gross],
	[DRS_Panel_Member],
	[Region],
	[Territory],
	[Ccl_Payeeid]
FROM [Ext].[PBI02_BI_vwDRSAppts_CRM]
