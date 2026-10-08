CREATE   VIEW [Subs].[vwSubsPayments_Extended] AS

	SELECT
		 Campaign_Year AS 'Campaign Year'
		,Trans_Date_Adj AS 'Trans Date Adj'
		,SUM(AdjustedPayments) AS 'Paid Amount GBP'
	FROM [AX].[tblSubsPayments_Static]
	WHERE Campaign_Year >= 2016
	GROUP BY Campaign_Year, Trans_Date_Adj

	UNION ALL

	SELECT
		 Campaign_Year
		,Trans_Date_Adj
		,SUM(Subs_Paid_GBP)
	FROM [Subs].[tblSubsPayments_Static_2021]
	GROUP BY Campaign_Year, Trans_Date_Adj

	UNION ALL

	SELECT
		 Campaign_Year
		,Trans_Date_Adj
		,SUM(Subs_Paid_GBP)
	FROM [Subs].[tblSubsPayments]
	WHERE Trans_Date_Adj <= GETDATE()
	GROUP BY Campaign_Year, Trans_Date_Adj
