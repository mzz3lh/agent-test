CREATE   VIEW [synapse_ce].[vwOCEUserCompetencies]
AS

SELECT  
	rrd.[apuk_contactid] as ContactID,
	mcy.[apuk_competencyid] as CompetencyId,
	mcy.[apuk_competencylevel] as Level,
	mcy.[apuk_competencytype] as CompetencyType,
	optarcstats.LocalizedLabel As CompetencyType_Description,
	mcy.[createdon],
	mcy.[createdby],
	mcy.[modifiedon] as LastUpdated,
	mcy.[modifiedby],
	mcy.[statecode],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	mcy.[statuscode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_membercompetency mcy
	LEFT JOIN synapse_ce.apuk_ricsrecord rrd
		ON mcy.apuk_ricsrecordid= rrd.apuk_ricsrecordid
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optarcstats
		ON  mcy.apuk_competencytype = optarcstats.[Option] 
		AND optarcstats.OptionSetName='apuk_competencytype'
		AND optarcstats.[EntityName] = 'apuk_membercompetency'
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON mcy.[statecode] = statecode.[State]
			AND statecode.[EntityName] = 'apuk_membercompetency'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON mcy.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'apuk_membercompetency'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = rrd.[apuk_contactid]
		)
