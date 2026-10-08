CREATE   VIEW [CE].[vwGlobalCPDMonthlyCompletionTracker]
AS
--Get year user specifies
With  SELECT1
As
(
select
		snap.Total_Count,
		snap.[Count_Complete],
		snap.[Count_Not_Complete],
		snap.DateOfSnapshot,
		snap.cpdrecordingstatus,
		snap.rics_cpdyear,
		lg.rics_reportingsubworldregion,
		snap.rics_groupid
--INTO #SELECT
FROM [Snapshots].[tblCPDWeekleyComplianceStatsSnapshot_CE] as snap
		inner join CE.vwRicsGroup as lg on snap.rics_groupid = lg.rics_groupid
		----where 
		----rics_cpdyear = @CpdYear AND
		----[Country] in (@Country) AND
		----[rics_reportingsubworldregion] IN (@Region) AND
		----snap.DateOfSnapshot >= @SnapStartDate AND
		----snap.DateOfSnapshot <= @SnapEndDate AND
		----snap.cpdrecordingstatus IN (@CpdRecordingStatus)
		--select top 1 * from [10.50.10.189].[RICS_MSCRM].dbo.rics_group
		--select * from #select

--Get previous year for comparison
),
SELECT2
As
(
select
		snap.Total_Count,
		snap.[Count_Complete],
		snap.[Count_Not_Complete],
		snap.DateOfSnapshot,
		snap.cpdrecordingstatus,
		snap.rics_cpdyear,
		lg.rics_reportingsubworldregion,
		snap.rics_groupid
--INTO #SELECT2 
FROM [Snapshots].[tblCPDWeekleyComplianceStatsSnapshot_CE] as snap
		inner join CE.vwRicsGroup as lg on snap.rics_groupid = lg.rics_groupid
		----where 
		----rics_cpdyear = @CpdYear -1 AND
		----[Country] in (@Country) AND
		----[rics_reportingsubworldregion] IN (@Region) AND
		----snap.DateOfSnapshot >= DateAdd(yyyy,-1,@SnapStartDate) AND
		----snap.DateOfSnapshot <= DateAdd(yyyy,-1,@SnapEndDate) AND
		----snap.cpdrecordingstatus IN (@CpdRecordingStatus)
		--select top 1 * from [10.50.10.189].[RICS_MSCRM].dbo.rics_group
		--select * from #select

-- Create Table to be used to get change for current Year
),
DIFF
As
(

SELECT
		i.*, 
		ROW_NUMBER()OVER(partition by cpdrecordingstatus order by DateOfSnapShot) as rn
--INTO #DIFF
FROM
		(
		SELECT 
				SUM([Total_Count]) AS [Member Count],
				SUM([Count_Complete]) AS [Completed CPD],
				SUM([Count_Not_Complete]) AS [Not Complete CPD],
				CAST(CAST(SUM([Count_Complete]) as Decimal)/CAST(SUM([Total_Count]) as Decimal)*100 as Decimal(5,2))as [Pre Percent Complete],
				Row_Number()over(partition by cpdrecordingstatus,Month(DateOfSnapshot),Year(DateOfSnapShot) order by DateOfSnapshot desc) as ord,
				DateOfSnapShot,
				cpdrecordingstatus,
				rics_groupid,
				rics_cpdyear
		FROM SELECT1
				Group by
					DateOfSnapShot,
					cpdrecordingstatus,
					rics_cpdyear,
					rics_groupid
		)i 
		where ord = 1
),

-- Create Table to be used to get change for previos Year
DIFF2
As
(
SELECT 
		i.*, 
		ROW_NUMBER()OVER(partition by cpdrecordingstatus order by DateOfSnapShot) as rn
--INTO #DIFF2
FROM
		(
		SELECT 
				SUM([Total_Count]) AS [Member Count],
				SUM([Count_Complete]) AS [Completed CPD],
				SUM([Count_Not_Complete]) AS [Not Complete CPD],
				CAST(CAST(SUM([Count_Complete]) as Decimal)/CAST(SUM([Total_Count]) as Decimal)*100 as Decimal(5,2))as [Pre Percent Complete],
				Row_Number()over(partition by cpdrecordingstatus,Month(DateOfSnapshot),Year(DateOfSnapShot) order by DateOfSnapshot desc) as ord,
				DateOfSnapShot,
				cpdrecordingstatus,
				rics_groupid,
				rics_cpdyear
		FROM SELECT2
				Group by 
					DateOfSnapShot,
					cpdrecordingstatus,
					rics_cpdyear,
					rics_groupid
		)i 
		where ord = 1
)
-- Build Comparison
Select 
		SPECYEAR.cpdrecordingstatus,
		SPECYEAR.[Member Count],
		SPECYEAR.[Completed CPD],
		SPECYEAR.[Not Complete CPD],
		SPECYEAR.DateOfSnapshot,
		SPECYEAR.Change,
		SPECYEAR.[Percent Complete],
		isnull(SPECYEAR.[Percent Complete] - SPECYEAR.[Pre Percent Complete],0) as PercentChange,
		COMPYEAR.PercentChange AS ComparisonPercentChange,
		COMPYEAR.[Percent Complete] AS ComparisionPercentComplete,
		COMPYEAR.[Member Count] AS ComparisionMemberCount,
		SPECYEAR.rics_groupid,
		SPECYEAR.rics_cpdyear
FROM
		(
		SELECT 
				cur.cpdrecordingstatus,
				cur.[Member Count],
				cur.[Completed CPD],
				cur.[Not Complete CPD],
				pre.[Pre Percent Complete],
				CAST(CAST(cur.[Completed CPD] as Decimal)/CAST(cur.[Member Count] as Decimal)*100 as Decimal(5,2))as [Percent Complete],
				cur.DateOfSnapshot, 
				isnull(cur.[Completed CPD] - pre.[Completed CPD],0) as Change,
				cur.rics_groupid,
				cur.rics_cpdyear
		FROM DIFF AS cur 
				LEFT JOIN DIFF AS pre on cur.rn = pre.rn + 1 and cur.cpdrecordingstatus = pre.cpdrecordingstatus
		)SPECYEAR

OUTER APPLY
(
Select
		i.*,
		isnull([Percent Complete] - [Pre Percent Complete],0) as PercentChange
FROM
		(
		SELECT 
				cur.cpdrecordingstatus,
				cur.[Member Count],
				cur.[Completed CPD],
				cur.[Not Complete CPD],
				pre.[Pre Percent Complete],
				CAST(CAST(cur.[Completed CPD] as Decimal)/CAST(cur.[Member Count] as Decimal)*100 as Decimal(5,2))as [Percent Complete],
				cur.DateOfSnapshot, 
				isnull(cur.[Completed CPD] - pre.[Completed CPD],0) as Change 
		FROM DIFF2 AS cur 
				LEFT JOIN DIFF2 AS pre on cur.rn = pre.rn + 1 and cur.cpdrecordingstatus = pre.cpdrecordingstatus
				WHERE 
					datepart(ww,cur.DateOfSnapshot) = datepart(ww,SPECYEAR.DateOfSnapShot)
		)i

)COMPYEAR



/*
drop table #Diff
drop table #Diff2
drop table #SELECT1
drop table #SELECT2
*/
