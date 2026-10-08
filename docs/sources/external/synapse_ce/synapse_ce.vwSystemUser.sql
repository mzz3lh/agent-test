CREATE   VIEW [synapse_ce].[vwSystemUser]
AS
SELECT
	suser.[SystemUserId],
	bu.[name] AS [BusinessUnitIdName],
	suser.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	suser.[createdon] AS [Created_On],
	suser.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	suser.[modifiedon] AS [Modified_On],
	suser.[OrganizationId],
	org.[name] AS [OrganizationIdName],
	suser.[TerritoryId],
	ter.[name] AS [TerritoryIdName],
	suser.[FirstName],
	suser.[MiddleName],
	suser.[LastName],
	suser.[FullName],
	suser.[Title],
	suser.[JobTitle],
	suser.[DomainName],
	suser.[IsDisabled],
	suser.[IsActiveDirectoryUser],
	suser.[salutation],
	suser.[internalemailaddress],
	suser.[positionid],
	suser.[parentsystemuserid],
	suser.[apitil_department],
	suser.[address1_country],
	suser.[address1_city],
	suser.[businessunitid],
	bunit.[name] AS [BusinessUnit_Name]
FROM [synapse_ce].[systemuser] suser
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON suser.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON suser.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN  synapse_ce.businessunit bu
		ON suser.[businessunitid] = bu.[businessunitid]
	LEFT JOIN synapse_ce.territory ter
		ON suser.[territoryid] = ter.[territoryid]
	LEFT JOIN synapse_ce.organization org
		ON suser.[organizationid] = org.[organizationid]
	LEFT JOIN [synapse_ce].[businessunit] bunit
		ON suser.[businessunitid] = bunit.[businessunitid]
