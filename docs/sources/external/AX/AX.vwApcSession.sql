CREATE VIEW [AX].[vwApcSession]
AS

SELECT
	[rics_contactno],
	[rics_applicationtypeidname],
	[rics_routeidname],
	[rics_pathwayidname],
	[EnrolmentType],
	[EnrolmentLocalGroup],
	[ContactLocalGroup],
	[LookupLocalGroup],
	[createdby],
	[rics_assessmenttype],
	[assessment_type],
	[rics_panelidname],
	[sessiondate],
	[rics_result],
	[result],
	[rics_referedreason],
	[Rics_Referedreason_Description],
	[rics_enrolmentdate],
	[rics_electiondate],
	[rics_panelid],
	[ContactCount],
	[CurrentAge],
	[AgeProfile],
	[gendercode],
	[cycletime],
	[Previous Attempts],
	[rics_enrolmentfee_base]
FROM [Ext].[PBI02_AX_vwApcSession]
