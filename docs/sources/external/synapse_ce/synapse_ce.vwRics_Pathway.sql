/****** Object:  View [dbo].[vwRics_Pathway]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwRics_Pathway]
AS
SELECT
	ptw.[apuk_pathwayId] AS [Rics_pathwayId],
	ptw.[apuk_code] AS [Rics_Code],
	ptw.[apuk_name] AS [Rics_name],
	ptw.[apuk_PathwayGroup] AS [Rics_PathwayGroup],
	pg.[LocalizedLabel] AS [Rics_PathwayGroup_Description],
	ptw.[apuk_ProfessionalGroupId] AS [Rics_ProfessionalGroupId],
	profgp.[apuk_name] AS [Rics_ProfessionalGroupIdName],
	ptw.[createdon] AS [Created_On],
	ptw.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ptw.[modifiedon] AS [Modified_On],
	ptw.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--ptw.[OwnerId],
	ptw.[Statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ptw.[Statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_pathway ptw
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ptw.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_pathway'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ptw.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_pathway'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ptw.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ptw.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata pg
		ON ptw.[apuk_pathwaygroup] = pg.[Option]
			AND pg.[OptionSetName] = 'apuk_pathwaygroup'
			AND pg.[EntityName] = 'apuk_pathway'
	LEFT JOIN synapse_ce.apuk_professionalgroup profgp
		ON ptw.[apuk_professionalgroupid] = profgp.[apuk_professionalgroupid]
