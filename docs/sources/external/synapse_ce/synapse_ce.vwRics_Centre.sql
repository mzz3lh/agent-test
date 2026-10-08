/****** Object:  View [dbo].[vwRics_Centre]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwRics_Centre]
AS
SELECT 
	evt.[apuk_assessmenteventid] AS [Rics_centreId],
	evt.[apuk_name] AS [Rics_name],
	evt.[apuk_assessmentvenue] AS [rics_venueid],
	venue.[apuk_name] AS [rics_venueidName],
	--evt.[Rics_FullName],
	evt.[apuk_name] AS [Rics_Description],
	evt.[createdon] AS [Created_On],
	evt.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	evt.[modifiedon] AS [Modified_On],
	evt.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--evt.[OwnerId],
	evt.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	evt.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	evt.[apuk_applicationtypeid] AS [ricsv2_ApplicationType],
	apt.[apuk_name] AS [ricsv2_ApplicationType_Description]
FROM synapse_ce.apuk_assessmentevent evt
	LEFT JOIN synapse_ce.apuk_applicationtype apt
		ON evt.[apuk_applicationtypeid] = apt.[apuk_applicationtypeid]
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON evt.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'apuk_assessmentevent'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON evt.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'apuk_assessmentevent'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON evt.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON evt.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.apuk_assessmentvenue venue
		ON evt.[apuk_assessmentvenue] = venue.[apuk_assessmentvenueid]
--WHERE apuk_assessmenteventid = '00000000-0000-0000-0000-000000000000'
