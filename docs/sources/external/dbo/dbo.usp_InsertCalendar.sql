CREATE PROCEDURE [dbo].[usp_InsertCalendar]
AS
BEGIN
DECLARE @StartDate AS DATE = '1990-01-01',
		@EndDate AS DATE = '2014-12-31'
		

	WHILE (@StartDate <= @EndDate)
	BEGIN
		INSERT INTO [dbo].[tbl_Dim_Calendar]
		(
			[DateKey],			
			[Calendar_Date],
			[MonthNo],	
			[MonthName_Short],
			[YearNo],
			[FY],			
			[Calendar_Quarter],
			[Calendar_Quarter_No],
			[FY_MonthNo],
			[FY_Quarter],		
			[FY_QuarterNo],
			[Calendar_WeekNo],
			[Calendar_Week],
			[BankHoliday]	
		)
		VALUES
		(
			CONVERT(VARCHAR(10),@StartDate,112),
			CAST(@StartDate AS DATE),
			MONTH(@StartDate),
			CONVERT(VARCHAR(3), @StartDate,0),
			DATEPART(Year, @StartDate),
			CASE
				WHEN MONTH(@StartDate) > 7 THEN	CAST(DATEPART(YEAR, @StartDate) AS VARCHAR(4)) + '-' + RIGHT(DATEPART(YEAR, DATEADD(YEAR, 1, @StartDate)),2)
				ELSE CAST(DATEPART(YEAR, DATEADD(YEAR, -1, @StartDate)) AS VARCHAR(4)) + '-' + RIGHT(DATEPART(YEAR, @StartDate),2)
			END,
			CASE
				WHEN MONTH(@StartDate) BETWEEN 4 AND 6 THEN 'Q1'
				WHEN MONTH(@StartDate) BETWEEN 7 AND 9 THEN 'Q2'
				WHEN MONTH(@StartDate) BETWEEN 10 AND 12 THEN 'Q3'
				WHEN MONTH(@StartDate) BETWEEN 1 AND 3 THEN 'Q4'
			END,
			CASE
				WHEN MONTH(@StartDate) BETWEEN 4 AND 6 THEN 1
				WHEN MONTH(@StartDate) BETWEEN 7 AND 9 THEN 2
				WHEN MONTH(@StartDate) BETWEEN 10 AND 12 THEN 3
				WHEN MONTH(@StartDate) BETWEEN 1 AND 3 THEN 4
			END,

			CASE
				WHEN MONTH(@StartDate) > 7 THEN MONTH(@StartDate)-7
				ELSE 12-(7-MONTH(@StartDate))
			END,
			CASE
				WHEN MONTH(@StartDate) BETWEEN 8 AND 10 THEN 'Q1'
				WHEN MONTH(@StartDate) BETWEEN 11 AND 12 OR MONTH(@StartDate)=1 THEN 'Q2'
				WHEN MONTH(@StartDate) BETWEEN 2 AND 4 THEN 'Q3'
				WHEN MONTH(@StartDate) BETWEEN 5 AND 7 THEN 'Q4'
			END,
			CASE
				WHEN MONTH(@StartDate) BETWEEN 8 AND 10 THEN 1
				WHEN MONTH(@StartDate) BETWEEN 11 AND 12 OR MONTH(@StartDate)=1 THEN 2
				WHEN MONTH(@StartDate) BETWEEN 2 AND 4 THEN 3
				WHEN MONTH(@StartDate) BETWEEN 5 AND 7 THEN 4
			END,

			DATEPART(WEEKDAY, @StartDate),
			DATENAME(WEEKDAY, @StartDate),
			CASE 
				WHEN DATEPART(WEEKDAY, @StartDate) = 1 OR DATEPART(WEEKDAY, @StartDate)=7 THEN 1
				ELSE 0
			END
		)
		
		SET @StartDate = DATEADD(day,1,@StartDate)

	END
END
