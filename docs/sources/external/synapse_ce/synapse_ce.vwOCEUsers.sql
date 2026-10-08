CREATE   VIEW [synapse_ce].[vwOCEUsers]
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
	cte.[apuk_contactid] AS [ContactId],
	pth.[apuk_name] AS [Pathway],
	cnt.[apuk_pathwayid] AS [PthwayId],
	rec.[apuk_routeid] AS [RouteId],
	rt.[apuk_name] AS [Route],
	enr.[apuk_competencyselectioncompleteddate] AS [CompetencySelectionCompleted],
	enr.[apuk_arcassessmentstatus] AS [AssessmentStatus],
	optArcStats.[LocalizedLabel] AS [AssessmentStatus_Description],
	enr.[apuk_counsellorid] AS [CounsellorId],
	cnt.[apuk_contactnumber] AS [ContactNumber],
	enr.[apuk_arclastloggedin] AS [LastLoginDate],
	enr.[apuk_approvedbycounsellor] AS [ApprovedByCounsellor],
	optAppr.[LocalizedLabel] AS [ApprovedByCounsellor_Description]
FROM cte 
	INNER JOIN synapse_ce.apuk_enrolment enr
		ON cte.[apuk_enrolmentid] = enr.[apuk_enrolmentid]
	INNER JOIN synapse_ce.contact cnt
		ON cte.apuk_contactid = cnt.ContactId
	LEFT JOIN synapse_ce.apuk_pathway pth
		ON cnt.[apuk_pathwayid] = pth.[apuk_pathwayid]
	LEFT JOIN synapse_ce.apuk_ricsrecord rec
		ON cnt.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
	LEFT JOIN synapse_ce.apuk_route rt
		ON rec.[apuk_routeid] = rt.[apuk_routeid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optArcStats
		ON enr.[apuk_arcassessmentstatus] = optArcStats.[Option]
			AND optArcStats.[OptionSetName] = 'apuk_arcassessmentstatus'
			AND optArcStats.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.OptionSetMetadata optAppr
		ON enr.[apuk_approvedbycounsellor] = optAppr.[Option]
			AND optAppr.[OptionSetName] = 'apuk_approvedbycounsellor'
			AND optAppr.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.apuk_applicationtype aptype
		ON enr.[apuk_applicationtypeid] = aptype.[apuk_applicationtypeid]

WHERE RowNo = 1
	AND aptype.[apuk_managedbyarc] = 1
	AND aptype.[apuk_name] = 'APC'
