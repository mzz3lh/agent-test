CREATE   VIEW [CE].[vwDRSAppointments]
AS 
SELECT 
	[DRS_Appts_Key],
	[Application_Reference],
	[Application_Type],
	[Application_Type_Description],
	[Status_Code_Id],
	[Status_Code],
	[Selection_Required_By_Date],
	[Application_Date],
	[Owner_Id],
	[OwnerIdName],
	[SalesTeamId],
	[Modified_On],
	[Modified_By],
	[ModifiedByName],
	[Created_On],
	[Created_By],
	[CreatedByName],
	[Application_Street1],
	[Application_PostCode],
	[Application_City],
	[DRS_Panel_Member],
	[rics_country]
FROM [synapse_ce].[vwDRSAppointments]
