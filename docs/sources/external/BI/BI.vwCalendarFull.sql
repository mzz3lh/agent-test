CREATE VIEW [BI].[vwCalendarFull] AS

SELECT	
	[DateKey],
	[Calendar_Date] AS [Date],
	DATEPART(DAY, [Calendar_Date]) AS [Day],
	[MonthNo] AS [Month Number],
	[MonthName_Short] AS [Month Name Short],
	DATENAME(MONTH, [Calendar_Date]) AS [Month Name Long],
	[MonthName_Short] + '-' + RIGHT([YearNo],2) AS [Month/Year],
	[YearNo] AS [Year],
	([YearNo]/10) * 10 AS 'Decade',
	[FY_Quarter] AS [RICS Quarter],
	[FY_QuarterNo] AS [RICS Quarter No],
	CAST(DATEADD(wk, DATEDIFF(wk, 0, [Calendar_Date]), 0) AS DATE) 'Week Comm.',
	CASE
		WHEN [FY_MonthNo] < 6 THEN 'FY ' + RIGHT(CAST([YearNo] AS VARCHAR(4)),2) + '-' + RIGHT(CAST(DATEADD(YEAR, 1, [Calendar_Date]) AS VARCHAR(4)),2)
		ELSE 'FY ' + RIGHT(CAST(DATEADD(YEAR, -1, [Calendar_Date]) AS VARCHAR(4)),2) + '-' + RIGHT(CAST([YearNo] AS VARCHAR(4)),2)
	END AS [FY],
	CASE
		WHEN [FY_MonthNo] < 6 THEN YEAR([Calendar_Date])+1 ELSE YEAR([Calendar_Date])
		END AS FinYear,
	CASE
		WHEN Calendar_Date < '2021-08-01' THEN
			CASE WHEN MonthNo >= 8 THEN YearNo + 1 ELSE YearNo END
		WHEN Calendar_Date BETWEEN '2021-08-01' AND '2022-12-31' THEN 2022
		WHEN Calendar_Date >= '2023-01-01' THEN YearNo 
		END AS 'Fiscal Year',
	[FY_MonthNo] AS [Month Sort Order],
	CASE
		WHEN DATEPART(DAY, [Calendar_Date]) BETWEEN 1 AND 7 THEN MonthName_Short + ' Week 1'
		WHEN DATEPART(DAY, [Calendar_Date]) BETWEEN 8 AND 14 THEN MonthName_Short + ' Week 2'
		WHEN DATEPART(DAY, [Calendar_Date]) BETWEEN 15 AND 21 THEN MonthName_Short + ' Week 3'
		WHEN DATEPART(DAY, [Calendar_Date]) BETWEEN 22 AND 28 THEN MonthName_Short + ' Week 4'
		ELSE MonthName_Short + ' Week 5'
	END AS [Week],
	'Week ' + CAST(DATEPART(WEEK, [Calendar_Date]) AS VARCHAR(2)) AS [Week No Corresponds Year],
	CASE
		WHEN [MonthNo] >= 10 THEN [YearNo]+1 
		ELSE [YearNo]
	END AS [SubsCampaignYear],
	DATEADD(DAY, 1, EOMONTH([Calendar_Date],-1)) AS [First Day of the Month],
	BankHoliday,
	Calendar_Week,
	CASE
		WHEN [MonthNo] >= 10 THEN [YearNo]+1
		ELSE [YearNo]
	END [CampaignYear],
	CASE
		WHEN [MonthNo] >= 10 THEN 'Subs' + CAST([YearNo]+1 AS NVARCHAR)
		ELSE 'Subs' + CAST([YearNo] AS NVARCHAR)
	END [SubsCampaign],
	CASE 
	WHEN [MonthNo] >= 10 then [MonthNo] -9 ELSE [MonthNo] + 3
	END AS [Subs Campaign Month Sort],
	FORMAT([Calendar_Date], 'dd') + '-' + FORMAT([Calendar_Date], 'MMM') AS 'Date (Yearless)',
--	CONCAT(
--		FORMAT(CASE WHEN [MonthNo] >= 10 then [MonthNo] -9 ELSE [MonthNo] + 3 END, '00')
--		,FORMAT([Calendar_Date], 'dd')
--		) AS 'Date (Yearless) Sort',
	(CASE WHEN [MonthNo] >= 10 then [MonthNo] -9 ELSE [MonthNo] + 3 END) * 100 
	+ DATEPART(DAY, [Calendar_Date])
	AS 'Date (Yearless) Integer',
	(CASE WHEN MONTH(GETDATE()) >= 10 then MONTH(GETDATE()) -9 ELSE MONTH(GETDATE()) + 3 END) * 100 
	+ DAY(GETDATE())
	AS 'Today (Yearless) Integer'
FROM [dbo].[tbl_Dim_Calendar]
WHERE [DateKey] <> 19000101
