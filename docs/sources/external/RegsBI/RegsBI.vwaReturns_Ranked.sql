CREATE   VIEW [RegsBI].[vwaReturns_Ranked]
AS
	WITH
	AR AS -- Completed Annual Returns
	(SELECT
	apuk_regulatoryreturnid AS [RR_ID],
	apuk_regulatedschemeid AS [RR_SchemeID],
	CAST(apuk_submitteddate AS Datetime) AS [RR_SubmittedDate],
	[apuk_regulatedfirmid] AS [RR_FirmID],
	[apuk_regulatedmemberid] AS [RR_ContactID],
	CASE WHEN [apuk_regulatedmemberid] IS NOT NULL AND [apuk_regulatedfirmid] IS NULL THEN 
	ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedmemberid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) --Adds ranking to returns
	WHEN [apuk_regulatedfirmid] IS NOT NULL THEN
	ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC)
	END AS [RR_Order],
	[apuk_returntypeName] AS [RR_Type]
	FROM RegsBI.vwRegulatoryreturn_CE
	WHERE apuk_returnstatus_Description = 'Payment Complete'
	AND statuscode = '1'
	AND [apuk_returntypeName] IN ('Annual Return', 'Application for Valuer Registration', 'Registration for Regulation', 'Responsible Principal')
	AND apuk_regulatedschemeid IS NOT NULL
	AND apuk_submitteddate IS NOT NULL),

	DPBR AS -- Completed DPB Registrations
	(SELECT
	apuk_regulatoryreturnid AS [RR_ID],
	apuk_regulatedschemeid AS [RR_SchemeID],
	CAST(apuk_submitteddate AS Datetime) AS [RR_SubmittedDate],
	[apuk_regulatedfirmid] AS [RR_FirmID],
	[apuk_regulatedmemberid] AS [RR_ContactID],
	ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) AS [RR_Order],
	[apuk_returntypeName] AS [RR_Type]
	FROM RegsBI.vwRegulatoryreturn_CE

	WHERE apuk_returnstatus_Description = 'Payment Complete'
	AND statuscode = '1'
	AND [apuk_returntypeName] LIKE 'Application for DPB'
	AND apuk_regulatedschemeid IS NOT NULL
	AND apuk_submitteddate IS NOT NULL),

	CMR
	AS -- Completed CMPS return
	(SELECT
	apuk_regulatoryreturnid AS [RR_ID],
	apuk_regulatedschemeid AS [RR_SchemeID],
	CAST(apuk_submitteddate AS Datetime) AS [RR_SubmittedDate],
	[apuk_regulatedfirmid] AS [RR_FirmID],
	[apuk_regulatedmemberid] AS [RR_ContactID],
	ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) AS [RR_Order],
	[apuk_returntypeName] AS [RR_Type]
	FROM RegsBI.vwRegulatoryreturn_CE

	WHERE apuk_returnstatus_Description = 'Payment Complete'
	AND statuscode = '1'
	AND [apuk_returntypeName] LIKE 'Application for Clients% Money'
	AND apuk_regulatedschemeid IS NOT NULL
	AND apuk_submitteddate IS NOT NULL),

	VRSR
	AS -- Completed VR Returns
	(SELECT
	apuk_regulatoryreturnid AS [RR_ID],
	apuk_regulatedschemeid AS [RR_SchemeID],
	CAST(apuk_submitteddate AS Datetime) AS [RR_SubmittedDate],
	[apuk_regulatedfirmid] AS [RR_FirmID],
	[apuk_regulatedmemberid] AS [RR_ContactID],
	ROW_NUMBER () OVER(PARTITION BY [apuk_regulatedfirmid] ORDER BY [vwRegulatoryreturn_CE].[apuk_submitteddate] DESC) AS [RR_Order],
	[apuk_returntypeName] AS [RR_Type]
	FROM RegsBI.vwRegulatoryreturn_CE

	WHERE apuk_returnstatus_Description = 'Payment Complete'
	AND statuscode = '1'
	AND [apuk_returntypeName] LIKE 'Application to Sponsor for Valuer Registration'
	AND apuk_regulatedschemeid IS NOT NULL
	AND apuk_submitteddate IS NOT NULL),

	RTNS AS
	(SELECT* FROM AR
	UNION
	SELECT* FROM DPBR
	UNION
	SELECT* FROM CMR
	UNION
	SELECT* FROM VRSR),

	FINAL AS
	(SELECT* FROM RTNS
	LEFT JOIN
	[RegsBI].[vwRegulatoryreturn_CE] ON [apuk_regulatoryreturnid]=[RR_ID])

	SELECT
		[apuk_regulatoryreturnid] AS [Return ID],
		[apuk_regulatedschemeid] AS [Scheme ID],
		[apuk_regulatedfirmid] AS [FIRM ID],
		[apuk_regulatedmemberid] AS [Member ID],
		[apuk_submittedbyid] AS [Submitter ID],
		COALESCE([apuk_caseannualreturnid],[apuk_caseregulatedschemeregistrationid],[apuk_casecomplianceid]) AS [Case ID],
		[apuk_regulatoryreturnreference] AS [Return Reference],
		[apuk_regulationtype_Description] AS [Regulation type],
		CAST([apuk_returnduedate] AS DATE) AS [Due Date],
		CAST([apuk_extendedsubmissiondate] AS DATE) AS [Extended Due Date],
		[apuk_extensionreason_Description] AS [Extension Reason],
		CAST([apuk_submitteddate] AS DATEtime) AS [Submission Date],
		[apuk_score] AS [Return Score],
		[apuk_returntypeName] AS [Return Type],
		[RR_Order] AS [Return Order by Type]

	FROM FINAL
