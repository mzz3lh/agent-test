CREATE VIEW [DQ].[vwDQ_ResultsHistory_Latest] AS 

	WITH CTE AS (
		SELECT
		MAX(res.RunDate) AS MaxDate
		FROM DQ.ValidationResultsSummary res
		)

	SELECT
	 res.RunDate AS 'Run Date'
	,res.RuleId
	,res.Pass
	,res.Fail
	,res.Pass + Fail AS Total
	FROM DQ.ValidationResultsSummary res
	WHERE EXISTS (
		SELECT
		MaxDate
		FROM CTE
		WHERE MaxDate = res.RunDate
		)
