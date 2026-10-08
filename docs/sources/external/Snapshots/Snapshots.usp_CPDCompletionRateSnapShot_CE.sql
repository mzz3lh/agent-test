-- =============================================
-- Author:		Paul Mills
-- Create date: 21/12/2016
-- Description:	Snapshot data to build history to enable tracking the overall CPD completion rate by Week/Month etc
-- Detail: 
-- =============================================
CREATE   PROCEDURE [Snapshots].[usp_CPDCompletionRateSnapShot_CE]

AS
----Insert previos cpd years data into CPDWeekleyComplianceStatsSnapshot
BEGIN

	INSERT INTO [Snapshots].[tblCPDWeekleyComplianceStatsSnapshot_CE]
	(
		[cpdrecordingstatus],
		[Total_Count],
		[Count_Not_Complete],
		[Count_Complete],
		[Count_No_Completed_CPD],
		[Percent_Complete],
		[LocalGroup],
		[Country],
		[Region],
		[World Region],
		[rics_cpdyear],
		rics_groupid
	)

	--(1) rics_totalcompleted


	SELECT
		Main.cpdrecordingstatus,
		ISNULL(NotComplete.[Count_Not_Complete],0) + ISNULL(Complete.[Count_Complete],0) AS Count, 
		ISNULL(NotComplete.[Count_Not_Complete],0) AS [Count_Not_Complete],
		ISNULL(Complete.[Count_Complete],0) AS [Count_Complete],
		ISNULL([Count_No_Completed_CPD],0) as [Count_No_Completed_CPD],
		ISNULL(CAST(CAST(Complete.[Count_Complete] AS decimal) / CAST(NotComplete.[Count_Not_Complete] + Complete.[Count_Complete] AS Decimal)*100 AS Decimal(4,2)),0) AS [Percent_Complete],
		ISNULL(NotComplete.rics_reportinglocalgroup,Complete.rics_reportinglocalgroup) as LocalGroup,
		ISNULL(NotComplete.rics_countryidname,Complete.rics_countryidname) as [Country],
		ISNULL(NotComplete.rics_region,Complete.rics_region) as Region,
		ISNULL(NotComplete.rics_worldRegion,Complete.rics_worldRegion) as [World Region],
		Main.Rics_cpdyear,
		Main.rics_groupid

	FROM
	(
		SELECT 
			cpdas.ricsv1_CPDRecordingStatus_Description AS cpdrecordingstatus,
			lg.rics_groupid,
			Rics_CPDYear
		FROM CE.vwCPDAnnualSummary AS cpdas
			INNER JOIN CE.vwcontact AS c 
				ON cpdas.rics_contactid = c.contactid 
			INNER JOIN CE.vwRicsGroup AS lg 
				ON c.rics_localgroupid = lg.rics_groupid 
		--INNER JOIN dbo.StringMap AS sm1 
		--ON cpdas.ricsv1_cpdrecordingstatus = sm1.AttributeValue AND
		--sm1.AttributeName = 'ricsv1_cpdrecordingstatus' AND
		--sm1.ObjectTypeCode = 10117
		GROUP BY 
			cpdas.ricsv1_CPDRecordingStatus_Description,
			c.statecode,
			lg.statecode,
			Rics_CPDYear,
			ricsv1_cpdrecordingstatus,
			rics_groupid,
			c.Rics_LapsedCode
		HAVING
			c.statecode = 0 AND
			c.Rics_LapsedCode is null AND
			lg.statecode = 0 AND
			--cpdas.statecode = 0 AND
			Rics_CPDYear = (case when datepart(mm,getdate()) < 3 then Year(dateadd(yyyy,-1,getdate())) ELSE year(getdate()) end) AND
			ricsv1_cpdrecordingstatus in (200000003,200000002)
	) Main

	--select * from [SQL-PRD-FC02.RICS.INTERNAL].[RICS_MSCRM].dbo.stringmap where attributename = 'Rics_LapsedCode' and objecttypecode = 2

		OUTER APPLY
		(
		SELECT 
			COUNT(*) AS [Count_Not_Complete],
			cpdas.ricsv1_CPDRecordingStatus_Description AS cpdrecordingstatus,
			lg.rics_worldRegion,
			lg.rics_region,
			lg.rics_reportinglocalgroup,
			lg.rics_groupid,
			lg.rics_countryidname,
			SUM(CASE WHEN cpdas.rics_totalcompletedhrs = 0 THEN 1 ELSE 0 END) AS [Count_No_Completed_CPD]
		FROM CE.vwCPDAnnualSummary AS cpdas
			INNER JOIN CE.vwcontact as c
				ON cpdas.rics_contactid = c.contactid
			INNER JOIN CE.vwRicsGroup AS lg 
				ON c.rics_localgroupid = lg.rics_groupid 
		--INNER JOIN [SQL-PRD-FC02.RICS.INTERNAL].[RICS_MSCRM].dbo.StringMap AS sm1 
		--ON cpdas.ricsv1_cpdrecordingstatus = sm1.AttributeValue AND
		--sm1.AttributeName = 'ricsv1_cpdrecordingstatus' AND
		--sm1.ObjectTypeCode = 10117
		GROUP BY 
			Rics_cpdcomplete,
			cpdas.ricsv1_CPDRecordingStatus_Description,
			c.statecode,
			lg.statecode,
			Rics_CPDYear,
			ricsv1_cpdrecordingstatus,
			lg.rics_worldRegion,
			lg.rics_countryidname,
			lg.rics_region,
			lg.rics_reportinglocalgroup,
			lg.rics_groupid,
			Rics_LapsedCode
		HAVING
			c.statecode = 0 AND
			lg.statecode = 0 AND
			c.Rics_LapsedCode is null AND
			--cpdas.statecode = 0 AND
			Rics_CPDYear = (case when datepart(mm,getdate()) < 3 then Year(dateadd(yyyy,-1,getdate())) ELSE year(getdate()) end) AND
			ricsv1_cpdrecordingstatus in (200000003,200000002) AND
			Rics_cpdcomplete = 0 And
			cpdas.ricsv1_CPDRecordingStatus_Description = main.cpdrecordingstatus And
			lg.rics_groupid = main.rics_groupid
		) NotComplete

		OUTER APPLY
		(
		SELECT 
			COUNT(*) AS [Count_Complete],
			cpdas.ricsv1_CPDRecordingStatus_Description AS cpdrecordingstatus,
			lg.rics_worldRegion,
			lg.rics_region,
			lg.rics_reportinglocalgroup,
			lg.rics_groupid,
			lg.rics_countryidname
		FROM CE.vwCPDAnnualSummary AS cpdas
			INNER JOIN CE.vwcontact as c
				ON cpdas.rics_contactid = c.contactid
			INNER JOIN CE.vwRicsGroup AS lg 
				ON c.rics_localgroupid = lg.rics_groupid 
		--INNER JOIN [SQL-PRD-FC02.RICS.INTERNAL].[RICS_MSCRM].dbo.StringMap AS sm1 
		--ON cpdas.ricsv1_cpdrecordingstatus = sm1.AttributeValue AND
		--sm1.AttributeName = 'ricsv1_cpdrecordingstatus' AND
		--sm1.ObjectTypeCode = 10117
		GROUP BY 
			Rics_cpdcomplete,
			cpdas.ricsv1_CPDRecordingStatus_Description,
			c.statecode,
			lg.statecode,
			Rics_CPDYear,
			ricsv1_cpdrecordingstatus,
			lg.rics_worldRegion,
			lg.rics_countryidname,
			lg.rics_region,
			lg.rics_reportinglocalgroup,
			lg.rics_groupid,
			Rics_LapsedCode
		HAVING
			c.statecode = 0 AND
			lg.statecode = 0 AND
			c.Rics_LapsedCode is null AND
			--cpdas.statecode = 0 AND
			Rics_CPDYear = (case when datepart(mm,getdate()) < 3 then Year(dateadd(yyyy,-1,getdate())) ELSE year(getdate()) end) AND
			ricsv1_cpdrecordingstatus in (200000003,200000002) AND
			Rics_cpdcomplete = 1 AND
			cpdas.ricsv1_CPDRecordingStatus_Description = main.cpdrecordingstatus And
			lg.rics_groupid = main.rics_groupid
		)Complete

	--Insert previos cpd years data into CPDWeekleyComplianceStatsSnapshot

		INSERT INTO [Snapshots].[tblCPDWeekleyComplianceStatsSnapshot_CE] 
		(
			[cpdrecordingstatus],
			[Total_Count],
			[Count_Not_Complete],
			[Count_Complete],
			[Count_No_Completed_CPD],
			[Percent_Complete],
			[LocalGroup],
			[Country],
			[Region],
			[World Region],
			[rics_cpdyear],
			rics_groupid
		)

	--(2) rics_totalcompleted


		SELECT
			Main.cpdrecordingstatus,
			ISNULL(NotComplete.[Count_Not_Complete],0) + ISNULL(Complete.[Count_Complete],0) AS Count, 
			ISNULL(NotComplete.[Count_Not_Complete],0) AS [Count_Not_Complete],
			ISNULL(Complete.[Count_Complete],0) AS [Count_Complete],
			ISNULL([Count_No_Completed_CPD],0) as [Count_No_Completed_CPD],
			ISNULL(CAST(CAST(Complete.[Count_Complete] AS decimal) / CAST(NotComplete.[Count_Not_Complete] + Complete.[Count_Complete] AS Decimal)*100 AS Decimal(4,2)),0) AS [Percent_Complete],
			ISNULL(NotComplete.rics_reportinglocalgroup,Complete.rics_reportinglocalgroup) as LocalGroup,
			ISNULL(NotComplete.rics_countryidname,Complete.rics_countryidname) as [Country],
			ISNULL(NotComplete.rics_region,Complete.rics_region) as Region,
			ISNULL(NotComplete.rics_worldRegion,Complete.rics_worldRegion) as [World Region],
			Main.Rics_cpdyear,
			Main.rics_groupid
		FROM
		(
			SELECT 
				cpdas.ricsv1_CPDRecordingStatus_Description AS cpdrecordingstatus,
				lg.rics_groupid,
				Rics_CPDYear
			FROM CE.vwCPDAnnualSummary AS cpdas
				INNER JOIN CE.vwcontact AS c 
					ON cpdas.rics_contactid = c.contactid 
				INNER JOIN CE.vwRicsGroup AS lg 
					ON c.rics_localgroupid = lg.rics_groupid 
			--INNER JOIN [SQL-PRD-FC02.RICS.INTERNAL].[RICS_MSCRM].dbo.StringMap AS sm1 
			--ON cpdas.ricsv1_cpdrecordingstatus = sm1.AttributeValue AND
			--sm1.AttributeName = 'ricsv1_cpdrecordingstatus' AND
			--sm1.ObjectTypeCode = 10117
			GROUP BY 
				cpdas.ricsv1_CPDRecordingStatus_Description,
				c.statecode,
				lg.statecode,
				Rics_CPDYear,
				ricsv1_cpdrecordingstatus,
				rics_groupid,
				Rics_LapsedCode
			HAVING
				c.statecode = 0 AND
				lg.statecode = 0 AND
				c.Rics_LapsedCode is null AND
				--cpdas.statecode = 0 AND
				Rics_CPDYear = year(getdate()) AND
				ricsv1_cpdrecordingstatus in (200000003,200000002)
		) Main

		OUTER APPLY
		(
			SELECT 
				COUNT(*) AS [Count_Not_Complete],
				cpdas.ricsv1_CPDRecordingStatus_Description AS cpdrecordingstatus,
				lg.rics_worldRegion,
				lg.rics_region,
				lg.rics_reportinglocalgroup,
				lg.rics_groupid,
				lg.rics_countryidname,
				sum(case when cpdas.rics_totalcompletedhrs = 0 then 1 else 0 end)as [Count_No_Completed_CPD]
			FROM CE.vwCPDAnnualSummary AS cpdas
				INNER JOIN CE.vwcontact as c
					ON cpdas.rics_contactid = c.contactid
				INNER JOIN CE.vwRicsGroup AS lg 
					ON c.rics_localgroupid = lg.rics_groupid 
			--INNER JOIN [SQL-PRD-FC02.RICS.INTERNAL].[RICS_MSCRM].dbo.StringMap AS sm1 
			--ON cpdas.ricsv1_cpdrecordingstatus = sm1.AttributeValue AND
			--sm1.AttributeName = 'ricsv1_cpdrecordingstatus' AND
			--sm1.ObjectTypeCode = 10117
			GROUP BY 
				Rics_cpdcomplete,
				cpdas.ricsv1_CPDRecordingStatus_Description,
				c.statecode,
				lg.statecode,
				Rics_CPDYear,
				ricsv1_cpdrecordingstatus,
				lg.rics_worldRegion,
				lg.rics_countryidname,
				lg.rics_region,
				lg.rics_reportinglocalgroup,
				lg.rics_groupid,
				Rics_LapsedCode
			HAVING
				c.statecode = 0 AND
				lg.statecode = 0 AND
				c.Rics_LapsedCode is null AND
				--cpdas.statecode = 0 AND
				Rics_CPDYear = year(getdate()) AND
				ricsv1_cpdrecordingstatus in (200000003,200000002) AND
				Rics_cpdcomplete = 0 And
				cpdas.ricsv1_CPDRecordingStatus_Description = main.cpdrecordingstatus And
				lg.rics_groupid = main.rics_groupid
		)NotComplete


		OUTER APPLY
		(
			SELECT 
				COUNT(*) AS [Count_Complete],
				cpdas.ricsv1_CPDRecordingStatus_Description AS cpdrecordingstatus,
				lg.rics_worldRegion,
				lg.rics_region,
				lg.rics_reportinglocalgroup,
				lg.rics_groupid,
				lg.rics_countryidname
			FROM CE.vwCPDAnnualSummary AS cpdas
				INNER JOIN CE.vwcontact as c
					ON cpdas.rics_contactid = c.contactid
				INNER JOIN CE.vwRicsGroup AS lg 
					ON c.rics_localgroupid = lg.rics_groupid 
			--INNER JOIN [SQL-PRD-FC02.RICS.INTERNAL].[RICS_MSCRM].dbo.StringMap AS sm1 
			--ON cpdas.ricsv1_cpdrecordingstatus = sm1.AttributeValue AND
			--sm1.AttributeName = 'ricsv1_cpdrecordingstatus' AND
			--sm1.ObjectTypeCode = 10117
			GROUP BY 
				Rics_cpdcomplete,
				cpdas.ricsv1_CPDRecordingStatus_Description,
				c.statecode,
				lg.statecode,
				Rics_CPDYear,
				ricsv1_cpdrecordingstatus,
				lg.rics_worldRegion,
				lg.rics_countryidname,
				lg.rics_region,
				lg.rics_reportinglocalgroup,
				lg.rics_groupid,
				Rics_LapsedCode
			HAVING
				c.statecode = 0 AND
				lg.statecode = 0 AND
				c.Rics_LapsedCode is null AND
				--cpdas.statecode = 0 AND
				Rics_CPDYear = year(getdate()) AND
				ricsv1_cpdrecordingstatus in (200000003,200000002) AND
				Rics_cpdcomplete = 1 AND
				cpdas.ricsv1_CPDRecordingStatus_Description = main.cpdrecordingstatus And
				lg.rics_groupid = main.rics_groupid
		)Complete


END
