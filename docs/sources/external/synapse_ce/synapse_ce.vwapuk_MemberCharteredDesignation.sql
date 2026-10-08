CREATE   VIEW [synapse_ce].[vwapuk_MemberCharteredDesignation]
AS

SELECT 
	cd.[id],
	cd.[apuk_memberchartereddesignationid],
	cd.[apuk_name],
	cd.[createdon],
	cd.[createdby],
	cd.[createdbyname],
	cd.[modifiedon],
	cd.[modifiedby],
	cd.[modifiedbyname],
	cd.[ownerid],
	cd.[owneridname],
	cd.[createdonbehalfby],
	cd.[createdonbehalfbyname],
	cd.[modifiedonbehalfby],
	cd.[modifiedonbehalfbyname],
	cd.[owningteam],
	cd.[owningteamname],
	cd.[owninguser],
	usrOwningUser.[fullname] AS [owningusername], 
	cd.[apuk_chartereddesignationid],
	cd.[apuk_chartereddesignationidname],
	cd.[owningbusinessunit],
	cd.[owningbusinessunitname],
	cd.[apuk_ricsrecordid],
	cd.[apuk_ricsrecordidname],
	cd.[apuk_startdate],
	cd.[apuk_enddate],
	cd.[overriddencreatedon],
	cd.[statecode], 
	ststatecode.[LocalizedLabel] AS [StateCode_Description],
	cd.[statuscode],
	ststatuscode.[LocalizedLabel] AS [StatusCode_Description]
FROM [synapse_ce].[apuk_memberchartereddesignation] cd
	LEFT JOIN [synapse_ce].[systemuser] usrOwningUser
		ON cd.[owninguser] = usrOwningUser.[systemuserid]
	LEFT JOIN [synapse_ce].[StateMetadata] ststatecode
		ON cd.[statecode] = ststatecode.[State]
		AND ststatecode.[EntityName] = 'apuk_memberchartereddesignation'
	LEFT JOIN [synapse_ce].[StatusMetadata] ststatuscode
		ON cd.[statuscode] = ststatuscode.[Status]
		AND ststatuscode.[EntityName] = 'apuk_memberchartereddesignation'
