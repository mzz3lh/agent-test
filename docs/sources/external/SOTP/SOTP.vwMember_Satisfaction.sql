CREATE VIEW [SOTP].[vwMember_Satisfaction] AS

WITH CTE AS (
	/*SELECT ResponseId ,[Year], Wave ,[Q13] FROM SOTP.tblSOTP_Answers_2021_W19
	UNION ALL
	SELECT ResponseId ,[Year], Wave ,[Q13KPI] FROM SOTP.tblSOTP_Answers_2021_W20
	UNION ALL
	SELECT ResponseId ,[Year], Wave ,[Q13] FROM SOTP.tblSOTP_Answers_2022_W21
	UNION ALL
	SELECT ResponseId ,[Year], Wave ,[Q13] FROM SOTP.tblSOTP_Answers_2022_W22
	UNION ALL*/
	SELECT ResponseId ,[Year], Wave ,[Q13], Panel_respondent_data_6 AS 'Location' FROM SOTP.tblSOTP_Answers_2023_W23
)

SELECT 
 ResponseId
,[Year]
,Wave
,[Q13]
,Location
,CASE 
	WHEN [Q13] = 'Extremely dissatisfied' THEN 0
	WHEN [Q13] = 'Very dissatisfied' THEN 0.2
	WHEN [Q13] = 'Dissatisfied' THEN 0.4
	WHEN [Q13] = 'Neither satisfied nor dissatisfied' THEN 0.5
	WHEN [Q13] = 'Satisfied' THEN 0.6
	WHEN [Q13] = 'Very satisfied' THEN 0.8
	WHEN [Q13] = 'Extremely satisfied' THEN 1
	END AS 'Member Satisfaction Score'
,CASE 
	WHEN [Q13] = 'Extremely dissatisfied' THEN 1
	WHEN [Q13] = 'Very dissatisfied' THEN 2
	WHEN [Q13] = 'Dissatisfied' THEN 3
	WHEN [Q13] = 'Neither satisfied nor dissatisfied' THEN 4
	WHEN [Q13] = 'Satisfied' THEN 5
	WHEN [Q13] = 'Very satisfied' THEN 6
	WHEN [Q13] = 'Extremely satisfied' THEN 7
	END AS 'Member Satisfaction Score Rank'
FROM CTE

--19 -Odd mix
--20 -Country
--21 -Nothing?
--22 -Nothing?
--23 - World Region
