CREATE     VIEW [RegsBI].[vwCaseInvestigationStatus_Audit_CE]
AS
SELECT 
	[CaseInvestigationStatus_Audit_Id]
	,[apuk_caseinvestigationid]
	,[Snapshot_Date]
	,[modifiedon]
	,[apuk_status_previous]
	,apukstatus_previous.[localizedlabel] AS [apuk_status_previous_descriptiopn]
	,[apuk_status_current]
	,apukstatus_current.[localizedlabel] AS [apuk_status_current_descriptiopn]
FROM Snapshots.tblcaseinvestigationstatus_audit t1
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus_previous
		ON t1.[apuk_status_previous]  = apukstatus_previous.[Option]
		AND apukstatus_previous.[OptionSetName] = 'apuk_status'
		AND apukstatus_previous.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus_current
		ON t1.[apuk_status_current]  = apukstatus_current.[Option]
		AND apukstatus_current.[OptionSetName] = 'apuk_status'
		AND apukstatus_current.[EntityName] = 'apuk_caseinvestigation'
