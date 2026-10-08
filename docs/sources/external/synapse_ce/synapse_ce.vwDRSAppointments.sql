CREATE   VIEW [synapse_ce].[vwDRSAppointments]
AS
SELECT 
	drs.[apuk_casedrsid] AS [DRS_Appts_Key],
	drs.[apuk_name] AS [Application_Reference],
	drs.[rics_drstype] AS [Application_Type], --Need to find
	drstype.[apuk_name] AS [Application_Type_Description],
	drs.[statuscode] AS [Status_Code_Id],
	drs.[statuscode] AS [Status_Code], --Need to get from statusmetadata
	drs.[apuk_appointmentrequiredby] AS  [Selection_Required_By_Date], --Need to find
	drs.[apuk_applicationdate] AS [Application_Date],
	drs.[ownerid] AS [Owner_Id],
	ownid.[fullname] AS [OwnerIdName],
	-1 AS [SalesTeamId], --tblSalesTeam
	drs.[modifiedon] AS [Modified_On],
	drs.[modifiedby] AS [Modified_By],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	drs.[createdon] AS [Created_On],
	drs.[createdby] AS [Created_By],
	usrcreatedby.[fullname] AS [CreatedByName],
	drs.[rics_street1] AS [Application_Street1],
	drs.[rics_zippostcode] AS [Application_PostCode],
	drs.[rics_city] AS [Application_City],
	--drs.[Payment_Type_Id],
	--drs.[Payment_Type],
	--drs.[Payment_Status_Id],
	--drs.[Payment_Status],
	--drs.[Payment_Value_Net],
	--drs.[Payment_Value_Gross],
	drs.[rics_drspanelmember] AS [DRS_Panel_Member],
	drs.[rics_country]
--	drs.[Region],
--	drs.[Territory]
FROM [synapse_ce].[apuk_casedrs] drs
	LEFT JOIN synapse_ce.apuk_drstype drstype
		ON drs.[rics_drstype] = drstype.[apuk_drstypeid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON drs.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON drs.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON drs.[ownerid] = ownid.[systemuserid]
