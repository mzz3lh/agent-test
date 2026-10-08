CREATE VIEW CE.vwSME_Firm_Size_LU AS

WITH SA AS (
	SELECT 
	 SA.ricsv1_Answer AS 'Firm Size'
	FROM [synapse_ce].[vwricsv1_surveyanswer] SA
	WHERE SA.ricsv1_Question = '00000000-0000-0000-0000-000000000000' --Firm Size
	GROUP BY SA.ricsv1_Answer

	UNION

	SELECT * 
	FROM (
        VALUES
        ('1'),
		('N/A')
		) AS SA ([Firm Size])
	)

	SELECT 
	 SA.[Firm Size]
	,CASE 
		WHEN SA.[Firm Size] = '1' THEN 'Y'
		WHEN SA.[Firm Size] = '0-9' THEN 'Y'
		WHEN SA.[Firm Size] = '10-49' THEN 'Y'
		WHEN SA.[Firm Size] = '50-249' THEN 'Y'
		ELSE 'N' END AS 'Is SME'
	,CASE
		WHEN SA.[Firm Size] = '1' THEN 'Sole Trader'
		WHEN SA.[Firm Size] = '0-9' THEN 'Micro'
		WHEN SA.[Firm Size] = '10-49' THEN 'Small'
		WHEN SA.[Firm Size] = '50-249' THEN 'Medium'
		ELSE 'N/A' END AS 'SME Type'
	,CASE 
		WHEN SA.[Firm Size] = '1' THEN 1
		WHEN SA.[Firm Size] = '0-9' THEN 2
		WHEN SA.[Firm Size] = '10-49' THEN 3
		WHEN SA.[Firm Size] = '50-249' THEN 4
		WHEN SA.[Firm Size] = '250-499' THEN 5
		WHEN SA.[Firm Size] = '500-749' THEN 6
		WHEN SA.[Firm Size] = '750-999' THEN 7
		WHEN SA.[Firm Size] = '1000-1499' THEN 8
		WHEN SA.[Firm Size] = '1500-1999' THEN 9
		WHEN SA.[Firm Size] = '2000+' THEN 10
		WHEN SA.[Firm Size] = 'N/A' THEN 11
		ELSE 11 END AS 'Firm Size Sort'
	FROM SA SA
