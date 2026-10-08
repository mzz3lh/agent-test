CREATE VIEW Subs.vwSubsLast_Year_Renewals_Lapsed AS

WITH CTE AS (
	SELECT
	 [Contact No.]
	,[Campaign Year]
	FROM [Subs].[vwSubsMemberStatuses] MS
	WHERE [Renewal Date] IS NOT NULL
	AND [Lapsed Date (In Campaign)] IS NOT NULL
	)

	SELECT 
	 MS.[Campaign Year]
	,MS.[Campaign Year] + 1 AS 'Campaign Year (Join)'
	,COUNT(*) AS 'Contact Count'
	FROM [Subs].[tblSubsMemberStatuses] MS
	INNER JOIN CTE
		ON CTE.[Contact No.] = MS.[Contact No.]
		AND CTE.[Campaign Year] = MS.[Campaign Year]
	AND NOT EXISTS (
		SELECT
		[Contact No.]
		FROM [Subs].[tblSubsMemberStatuses] MSS
		WHERE MSS.[Contact No.] = MS.[Contact No.]
		AND MSS.[Campaign Year] = MS.[Campaign Year] + 1
		)
	GROUP BY 
	 MS.[Campaign Year]
	,MS.[Campaign Year] + 1
