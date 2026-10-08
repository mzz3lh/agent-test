CREATE   VIEW [synapse_ce].[vwOceExperiences]
AS
SELECT  
	--rec.[apuk_contactid] AS [ContactID],
	ccy.[apuk_summaryofexperience] AS SummaryOfExperience,
	ccy.[apuk_counsellorfeedback] AS CounsellorFeedback,
	ccy.[createdon],
	ccy.[createdby],
	ccy.[modifiedon],
	ccy.[modifiedby],
	ccy.[apuk_competencyid] as CompetencyID,
	ccy.[apuk_status] as [Status],
	stat.[LocalizedLabel] AS [Status_Description],
	ccy.[apuk_level]
	--[LastModifiedBy],
	--StatusLastUpdatedDate
	,ccy.apuk_enrolmentid
	,enr.apuk_contactid
	,ccy.apuk_daysspent
FROM synapse_ce.apuk_candidatecompetency ccy
	LEFT JOIN synapse_ce.apuk_enrolment enr
		ON ccy.apuk_enrolmentid = enr.apuk_enrolmentid
	--LEFT JOIN synapse_ce.apuk_ricsrecord rec
	--	ON ccy.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata stat
		ON ccy.[apuk_status] = stat.[Option]
			AND stat.OptionSetName = 'apuk_status'
			AND stat.[EntityName] = 'apuk_candidatecompetency'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = enr.apuk_contactid
		)
