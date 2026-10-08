CREATE   VIEW [synapse_ce].[vwRics_Route]
AS
SELECT 
	rt.[apuk_routeid] AS [Rics_routeId],
	rt.[apuk_name] AS [Rics_name],
	rt.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	rt.[createdon] AS [Created_On],
	rt.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	rt.[modifiedon] AS [Modified_On],
	rt.[apuk_enrolmenttype] [ricsv2_EnrolmentTypeId],
	entype.[LocalizedLabel] AS [ricsv2_EnrolmentTypeIdName],
	rt.[apuk_applicationtypeid] AS [rics_applicationtypeid],
	aptype.[apuk_name] AS [rics_applicationtypeidName],
	--NULL AS [OwnerId],
	--NULL AS [OwnerIdName],
	--NULL AS [OwnerIdDsc],
	--NULL AS [OwnerIdType],
	--NULL AS [OwningUser],
	--NULL AS [OwningTeam],
	rt.[ImportSequenceNumber],
	rt.[OverriddenCreatedOn],
	--NULL AS [OwningBusinessUnit],
	rt.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	rt.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM [synapse_ce].[apuk_route] rt
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON rt.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON rt.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON rt.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_route'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON rt.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_route'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata entype
		ON rt.[apuk_enrolmenttype] = entype.[Option]
			AND entype.[OptionSetName] = 'apuk_enrolmenttype'
	LEFT JOIN synapse_ce.apuk_applicationtype aptype
		ON rt.[apuk_applicationtypeid] = aptype.[apuk_applicationtypeid]
