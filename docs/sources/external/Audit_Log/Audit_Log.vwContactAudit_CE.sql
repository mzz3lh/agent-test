CREATE   VIEW [Audit_Log].[vwContactAudit_CE]
AS
SELECT 
	ad.[ContactId],
	cnt.[apuk_contactnumber],
	ad.[AuditDate],
	ad.[Modifiedon],
	lgprev.[apuk_name] AS LocalGroup_Previous,
	lgcurr.[apuk_name] AS LocalGroup_Current,
	stStateCodePrev.[LocalizedLabel] AS [Statecode_Previous],
	stStateCodeCurr.[LocalizedLabel] AS [Statecode_Current],
	stStatusCodePrev.[LocalizedLabel] AS [Statuscode_Previous],
	stStatusCodeCurr.[LocalizedLabel] As [Sttauscode_Current],
	ad.[MemberGrade_Previous],
	ad.[MemberGrade_Current],
	ad.[Designation_Previous],
	ad.[Designation_Current],
	ad.[LapseCode_Previous],
	ad.[LapseCode_Current],
	ad.[LapsedDate_Previous],
	ad.[LapsedDate_Current],
	ad.[apuk_invalidpostaladdress_Previous],
	ad.[apuk_invalidpostaladdress_Current],
	ad.[apuk_donotchase_Previous],
	ad.[apuk_donotchase_Current],
	ad.[apuk_preventlapse_Previous],
	ad.[apuk_preventlapse_Current]
FROM Audit_Log.tblContactAudit_CE ad
	INNER JOIN synapse_ce.contact cnt
		ON ad.contactid = cnt.contactid
	LEFT JOIN synapse_ce.vwlocalgroup lgprev
		ON ad.LocalGroupId_Previous = lgprev.apuk_localgroupid
	LEFT JOIN synapse_ce.vwlocalgroup lgcurr
		ON ad.LocalGroupId_Current = lgcurr.apuk_localgroupid
	LEFT JOIN synapse_ce.StateMetadata stStateCodePrev
		ON ad.[StateCode_Previous] = stStateCodePrev.[State]
			AND stStateCodePrev.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.StateMetadata stStateCodeCurr
		ON ad.[StateCode_Current] = stStateCodeCurr.[State]
			AND stStateCodeCurr.[EntityName] = 'contact'

	LEFT JOIN synapse_ce.StatusMetadata stStatusCodePrev
		ON ad.[StatusCode_Previous] = stStatusCodePrev.[Status]
			AND stStatusCodePrev.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCodeCurr
		ON ad.[StatusCode_Current] = stStatusCodeCurr.[Status]
			AND stStatusCodeCurr.[EntityName] = 'contact'
