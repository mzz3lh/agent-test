CREATE   PROCEDURE [Work].[usp_Insert_Applications_CE] 
AS
BEGIN
--	/* query to hard code and manipulate application records to pull the latest one. used for new enrolments reports in board.  */

	IF OBJECT_ID('tempdb..#cteApplications') IS NOT NULL
	BEGIN
		DROP TABLE #cteApplications
	END


	TRUNCATE TABLE [CE].[tblApplications]

	/* Initial Staging Load */
		SELECT  
			   a.[rics_apcid]
			  ,a.[created_on]
			  ,a.[CreatedByName]
			  ,a.[rics_applicationenddate]
			  ,a.[rics_applicationtypeidname]
			  ,a.[rics_contactidname]
			  ,a.[rics_contactno]
			  ,a.[rics_contactid]
			  ,a.[rics_electiondate]
			  ,a.[Rics_ExpectedFinalDate]  --Added 06/12/2018 DBA/PS by request
			  ,NULL AS [rics_electionfee_base]
			  ,a.[rics_enrolmentdate] 
			  ,a.[rics_enrolmentfee_base] 
			  ,lg.[rics_reportinglocalgroup] AS [EnrolmentLocalGroup]
			  ,a.[rics_pathwayidname]
			  ,a.[rics_routeidname] 
			  ,a.[statecode]
			  ,a.[StateCode_Description]
			  ,a.[statuscode]
			  ,a.[StatusCode_Description]
			  ,a.[rics_contactidYomiName] AS [Applicant]
			  ,a.[rics_counselloridName] AS [Counsellor]
			  ,RANK() OVER(PARTITION BY a.[rics_contactno] ORDER BY a.rics_enrolmentdate DESC) AS [enrolment_rn]
			  ,a.[rics_enrolmentlocalgroupid]
       		  ,a.[rics_applicationtypeid]
			  ,a.[rics_routeid]
			  ,a.[rics_pathwayid]
			  ,a.[Rics_ApplicationRecieved]
			  ,r.[ricsv2_enrolmenttypeId]
			  ,r.[ricsv2_EnrolmentTypeIdName]
		INTO #cteApplications
		FROM [CE].[vwRicsAPC] AS a
			LEFT JOIN [CE].[vwRics_Route] AS r 
				ON a.rics_routeid = r.rics_routeid
					AND a.rics_applicationtypeid = r.rics_applicationtypeid
			--LEFT JOIN [dbo].[tblRicsEnrolmentType] AS e
			--	ON r.ricsv2_EnrolmentTypeId = E.ricsv2_enrolmenttypeId
			LEFT JOIN [AX].[vwlocalGroups] lg 
				ON a.rics_enrolmentlocalgroupidname = lg.rics_name
		WHERE a.rics_contactno IS NOT NULL 
		  --AND a.statecode <> 0 -- Removed 13/02/22 AAB


	
	/* Transformations */
	INSERT INTO [CE].[tblApplications]
	(
		[RunDate],
		[rics_apcid],
		[Created_on],
		[rics_applicationenddate],
		[rics_applicationtypeidname],
		[rics_contactidname],
		[rics_contactno],
		[rics_contactid],
		[rics_electiondate],
		[rics_electionfee_base],
		[rics_enrolmentdate],
		[Rics_ExpectedFinalDate],
		[rics_enrolmentfee_base],
		[rics_enrolmentlocalgroupid],
		[EnrolmentLocalGroup],
		[CurrentLocalgroup],
		[rics_pathwayidname],
		[rics_routeidname],
		[statecode],
		[StateCode_Description],
		[statuscode],
		[StatusCode_Description],
		[EnrolmentType],
		[EnrolmentTypeCRM],
		[rics_lapseddate],
		[rics_membergrade],
		[ContactStatus],
		[Contact_StatusCode_Description],
		[rics_disability],
		[rics_ethnicity],
		[gendercode],
		[AdjustedAge],
		[AgeProfile],
		[applicant],
		[Counsellor],
		[enrolment_rn]
	)
	SELECT 
		GETDATE() AS [RunDate]
		,a.[rics_apcid]
		,a.[Created_on]
		,a.[rics_applicationenddate]
		,a.[rics_applicationtypeidname]
		,a.[rics_contactidname]
		,a.[rics_contactno]
		,a.[rics_contactid]
		,a.[rics_electiondate]
		,a.[rics_electionfee_base]
		,a.[rics_enrolmentdate]
		,a.[Rics_ExpectedFinalDate] 
		,a.[rics_enrolmentfee_base] 
		,a.rics_enrolmentlocalgroupid		
		,ISNULL(a.[EnrolmentLocalGroup], c.[rics_localgroupidName]) AS [EnrolmentLocalGroup]
		,c.[rics_localgroupidName] AS [CurrentLocalgroup]
		,a.[rics_pathwayidname]
		,a.[rics_routeidname]
		,a.[statecode]
		,a.[StateCode_Description]
		,a.[statuscode]
		,a.[StatusCode_Description]
		,dbo.fn_EnrolmentType(rics_applicationtypeidname,rics_routeidname) AS [EnrolmentType]
		,a.[ricsv2_EnrolmentTypeIdName] as [EnrolmentTypeCRM]
		,c.[rics_lapseddate]
		,c.[rics_membergrade]
		,c.[statuscode] AS [ContactStatus]
		,c.[StatusCode_Description] AS [Contact_StatusCode_Description]
		,c.[rics_disability]
		,c.[rics_ethnicity]
		,c.[gendercode]
		,NULL AS [AdjustedAge]
		,NULL AS [AgeProfile]
		,a.[applicant]
		,a.[Counsellor]
		,a.[enrolment_rn]	
	FROM #cteApplications a
		LEFT JOIN [CE].[vwContact] c
			ON a.[rics_contactno] = c.rics_contactno
  	WHERE 1 = 1


END
