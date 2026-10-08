CREATE   VIEW [Subs].[vwSubsConcessions_Invoice_Grouped] AS 

	WITH 
	VARR AS (
		SELECT 
			CASE 
				WHEN DATEPART(MONTH, getdate()) >= 10 THEN DATEPART(YEAR, getdate())+1 
				ELSE DATEPART(YEAR, getdate()) 
			END AS 'CurrentCampaignYear'
	)

	,DEDUPE AS (
		SELECT
			 [Concession Code]
			,[Concession]
			,[Contact No]
			,[Campaign Year]
		FROM [Subs].[vwSubsConcessions_Invoice]
		--WHERE [Contact No] IN (0000000, 0000000, 0000000, 0000000)
		GROUP BY 
			 [Concession Code]
			,[Concession]
			,[Contact No]
			,[Campaign Year]
		)

	SELECT
		 [Concession Code]
		,[Concession]
		,[Contact No]
		,SUM(CASE WHEN [Campaign Year] = CurrentCampaignYear -4 THEN 1 ELSE 0 END) AS '4 Years Back'
		,SUM(CASE WHEN [Campaign Year] = CurrentCampaignYear -3 THEN 1 ELSE 0 END) AS '3 Years Back'
		,SUM(CASE WHEN [Campaign Year] = CurrentCampaignYear -2 THEN 1 ELSE 0 END) AS '2 Years Back'
		,SUM(CASE WHEN [Campaign Year] = CurrentCampaignYear -1 THEN 1 ELSE 0 END) AS 'Last Year'
		,SUM(CASE WHEN [Campaign Year] = CurrentCampaignYear THEN 1 ELSE 0 END) AS 'This Year'
		,SUM(CASE WHEN [Campaign Year] BETWEEN CurrentCampaignYear -4 AND CurrentCampaignYear THEN 1 ELSE 0 END) AS 'Years Count'
		,CASE WHEN SUM(CASE WHEN [Campaign Year] BETWEEN CurrentCampaignYear -4 AND CurrentCampaignYear THEN 1 ELSE 0 END) > 1 THEN 1 ELSE 0 END AS 'Multi Year Count'
			,CASE WHEN SUM(CASE WHEN [Campaign Year] BETWEEN CurrentCampaignYear -4 AND CurrentCampaignYear THEN 1 ELSE 0 END) > 1 THEN 'Y' ELSE 'N' END AS 'Multi Year Flag'
		,CONCAT (
			MAX(CASE WHEN [Campaign Year] = CurrentCampaignYear -4 THEN 'Y' ELSE 'N' END),
			MAX(CASE WHEN [Campaign Year] = CurrentCampaignYear -3 THEN 'Y' ELSE 'N' END),
			MAX(CASE WHEN [Campaign Year] = CurrentCampaignYear -2 THEN 'Y' ELSE 'N' END),
			MAX(CASE WHEN [Campaign Year] = CurrentCampaignYear -1 THEN 'Y' ELSE 'N' END),
			MAX(CASE WHEN [Campaign Year] = CurrentCampaignYear THEN 'Y' ELSE 'N' END)
			) AS 'Consecutive String'
	FROM DEDUPE
		LEFT JOIN VARR ON 1=1
	GROUP BY 
		 [Concession Code]
		,[Concession]
		,[Contact No]
