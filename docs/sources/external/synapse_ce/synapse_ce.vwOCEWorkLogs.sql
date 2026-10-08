CREATE   VIEW [synapse_ce].[vwOCEWorkLogs]
AS
SELECT *
FROM
(
	SELECT 
		cd.[ActivityId] AS ID,
		cd.[regardingobjectid] AS [ContactId],
		cd.[apuk_competencyid] AS [CompetencyId],
		cd.[actualstart] AS [StartDate],
		cd.[apuk_days] AS [Days],
		cd.[subject] AS [Title],
		cd.[apuk_competencylevel] AS [Level],
		cd.[description] AS [Notes],
		ROW_NUMBER() OVER(PARTITION BY regardingobjectid, apuk_competencyid, actualstart, apuk_Days, apuk_competencylevel, subject, description ORDER BY regardingobjectid, apuk_competencyid, actualstart, apuk_Days, apuk_competencylevel, subject, description) AS RowNo
	FROM  synapse_ce.apuk_candidatediaryentry cd
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cd.[regardingobjectid]
		)
) tab
WHERE tab.RowNo = 1
