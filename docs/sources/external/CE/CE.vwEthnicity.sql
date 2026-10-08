CREATE   VIEW [CE].[vwEthnicity]
AS
SELECT 
	 [Ethnicity_Code]
	,[Ethnicity_Description]
	--,SUBSTRING([Ethnicity_Description], ' - ', 1) AS Ting
	,CASE 
		WHEN Ethnicity_Code = 200000017 THEN 'Declined'
		WHEN Ethnicity_Code IN (200000015, 200000016) THEN 'Other' 
		ELSE SUBSTRING([Ethnicity_Description], 0, CHARINDEX(' - ', [Ethnicity_Description])) 
		END AS 'Ethnic Group'
	,CASE 
		WHEN Ethnicity_Code = 200000017 THEN 'Declined'
		WHEN Ethnicity_Code IN (200000015, 200000016) THEN Ethnicity_Description 
		ELSE SUBSTRING([Ethnicity_Description], CHARINDEX(' - ', [Ethnicity_Description])+3, 200) 
		END AS 'Ethnicity'

FROM [synapse_ce].[vwEthnicity]

UNION ALL

SELECT
	-1
	,'N/A'
	,'NULL'
	,'NULL'
