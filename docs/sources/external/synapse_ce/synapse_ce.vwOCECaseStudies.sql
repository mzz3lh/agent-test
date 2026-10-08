CREATE   VIEW [synapse_ce].[vwOCECaseStudies]
AS
WITH cte AS
(
	SELECT 
		en.[apuk_enrolmentid],
		en.[apuk_contactid],
		en.[apuk_enrolmentdate],
		ROW_NUMBER() OVER(PARTITION BY en.apuk_contactid ORDER BY en.apuk_enrolmentdate DESC) AS RowNo
	FROM synapse_ce.apuk_enrolment en
	WHERE en.[apuk_enrolmentdate] IS NOT NULL
	AND NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = en.[apuk_contactid]
		)
)

SELECT 
	enr.[apuk_contactid] as [ContactId],
	enr.[apuk_casestudyfeedback],
	enr.[apuk_counsellorid],
	enr.[createdon],
	enr.[createdby],
	enr.[modifiedon],
	enr.[modifiedby],
	enr.[apuk_casestudystatus],
	optStat.[LocalizedLabel] AS [apuk_casestudystatus_description]
	--[CaseStudyTitle],
	--[CandidateStatus],
	--[ReferralFeedback,
	--[LastModofiedDate],
	--[LastModifiedBy],
	--[DocumentUrl],
	--[StatusLastUpdatedDate
FROM cte
	INNER JOIN [synapse_ce].[apuk_enrolment] enr
		ON cte.[apuk_enrolmentid] = enr.[apuk_enrolmentid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optStat
		ON enr.[apuk_casestudystatus] = optStat.[Option]
			AND optStat.[OptionSetName] = 'apuk_casestudystatus'
			AND optStat.[EntityName] = 'apuk_enrolment'
