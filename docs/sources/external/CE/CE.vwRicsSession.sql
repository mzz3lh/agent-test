CREATE   VIEW [CE].[vwRicsSession]
AS 
SELECT 
	ses.[Rics_sessionId],
	ses.[Rics_name],
	ses.[CreatedBy],
	ses.[CreatedByName],
	ses.[Created_On],
	ses.[ModifiedBy],
	ses.[ModifiedByName],
	ses.[Modified_On],
	ses.[rics_panelid],
	ses.[rics_panelidName],
	ses.[rics_candidateid],
	ses.[rics_candidateidName],
	ses.[OwnerId],
	ses.[OwnerIdName],
	ses.[OwningBusinessUnit],
	ses.[OwningTeam],
	ses.[OwningUser],
	
	ses.[contactid],
	ses.[rics_assessmentmethod],
	ses.[rics_chairmanresult],
	
	ses.[Rics_AssessmentType],
	ses.[Rics_AssessmentType_Description],
	ses.[Rics_Date],
	ses.[Rics_ReferredOther],
	ses.[Rics_Result],
	ses.[Rics_Result_Description],
	ses.[statecode],
	ses.[StateCode_Description],
	ses.[statuscode],
	ses.[StatusCode_Description],
	ses.[Rics_DateResultIssued],
	ses.[Rics_ResultApproved],
	ses.[Rics_ResultApprovedon],
	ses.[Rics_ResultInputDate],
	ses.[Rics_Referedreason],
	ses.[Rics_Referedreason_Description],
	ses.[rics_resultinputbyid],
	ses.[ricsv2_resultissuedbyid],
	ses.[rics_approvedbyid],
	ses.[apuk_firstlocationchoiceid],
	loc1.[apuk_name] AS [apuk_firstlocationchoiceidName],
	ses.[apuk_secondlocationchoiceid],
	loc2.[apuk_name] AS [apuk_secondlocationchoiceidName],
	ses.[apuk_thirdlocationchoiceid],
	loc3.[apuk_name] AS [apuk_thirdlocationchoiceidName],
	ses.[Apuk_internationalexperience]
FROM [synapse_ce].[vwRicsSession] ses
	LEFT JOIN [synapse_ce].[apuk_assessmentevent] loc1
		ON ses.[apuk_firstlocationchoiceid] = loc1.[apuk_assessmenteventid]
	LEFT JOIN [synapse_ce].[apuk_assessmentevent] loc2
		ON ses.[apuk_secondlocationchoiceid] = loc2.[apuk_assessmenteventid]
	LEFT JOIN [synapse_ce].[apuk_assessmentevent] loc3
		ON ses.[apuk_thirdlocationchoiceid] = loc3.[apuk_assessmenteventid]
