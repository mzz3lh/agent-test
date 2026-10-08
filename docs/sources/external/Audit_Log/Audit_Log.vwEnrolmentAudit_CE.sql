CREATE    VIEW [Audit_Log].[vwEnrolmentAudit_CE]
AS
SELECT 
	ad.[apuk_enrolmentid],
	ad.[AuditDate],
	ad.[Modifiedon],
	stStateCodePrev.[LocalizedLabel] AS [Statecode_Previous],
	stStateCodeCurr.[LocalizedLabel] AS [Statecode_New],
	stStatusCodePrev.[LocalizedLabel] AS [Statuscode_Previous],
	stStatusCodeCurr.[LocalizedLabel] As [Sttauscode_New],
	ad.[apuk_applicationtypeidname_Previous] AS [ApplicationType_Previous],
	ad.[apuk_applicationtypeidname_Current] AS [ApplicationType_New]
FROM Audit_Log.tblEnrolmentAudit_CE ad
	LEFT JOIN synapse_ce.StateMetadata stStateCodePrev
		ON ad.[StateCode_Previous] = stStateCodePrev.[State]
			AND stStateCodePrev.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.StateMetadata stStateCodeCurr
		ON ad.[StateCode_Current] = stStateCodeCurr.[State]
			AND stStateCodeCurr.[EntityName] = 'apuk_enrolment'

	LEFT JOIN synapse_ce.StatusMetadata stStatusCodePrev
		ON ad.[StatusCode_Previous] = stStatusCodePrev.[Status]
			AND stStatusCodePrev.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCodeCurr
		ON ad.[StatusCode_Current] = stStatusCodeCurr.[Status]
			AND stStatusCodeCurr.[EntityName] = 'apuk_enrolment'
