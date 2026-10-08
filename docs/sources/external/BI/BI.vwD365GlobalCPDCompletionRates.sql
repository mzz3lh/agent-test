CREATE VIEW [BI].[vwD365GlobalCPDCompletionRates]

AS


WITH cteCompletedZero AS
(
	SELECT [Count Complete], cpdrecordingstatus, cpdyear.Rics_CPDYear FROM(VALUES
		(0,'Targeted'),
		(0,'Self Declared')
	) tab ([Count Complete], cpdrecordingstatus)
		CROSS JOIN 
	(SELECT Rics_CPDYear 
	FROM CE.vwCPDAnnualSummary--vwRics_cpdannualsummary 
	WHERE Rics_CPDYear >= YEAR(GETDATE())-3 AND rics_cpdyear <= YEAR(GETDATE())+1 
	GROUP BY Rics_CPDYear) cpdyear
),
cteActiveContacts AS
(
	SELECT 
		ContactId 
	FROM CE.vwContact 
	WHERE 
		StateCode = 0 
		AND Rics_LapsedCode IS NULL	
),
cteMyTable AS
(
	SELECT 
		COUNT(*) AS [Count Complete],
		cpdas.[Rics_CPDYear],
		cpdas.[ricsv1_CPDRecordingStatus_Description] AS cpdrecordingstatus
	FROM CE.vwCPDAnnualSummary AS cpdas  --dbo.vwRics_cpdannualsummary AS cpdas
		INNER JOIN cteActiveContacts AS c 
			ON cpdas.rics_contactid = c.contactid
	WHERE cpdas.[Rics_CPDYear] >= YEAR(GETDATE())-3
		AND ricsv1_cpdrecordingstatus in (200000002,200000003)  --Self Declared, Targeted WAS (3,4)
		AND Rics_cpdcomplete = 1 

	GROUP BY 
		Rics_cpdcomplete,
		cpdas.[ricsv1_CPDRecordingStatus_Description],
		Rics_CPDYear
)

-- Query that pulls all together
SELECT
	NotComplete.cpdrecordingstatus,
	NotComplete.[Count Not Complete] + Complete.[Count Complete] AS Count, 
	NotComplete.[Count Not Complete],
	Complete.[Count Complete],
	--CAST(CAST(Complete.[Count Complete] AS decimal) / CAST(NotComplete.[Count Not Complete] + Complete.[Count Complete] AS Decimal)*100 AS decimal(5,2)) AS [Percent Complete],
	--CAST(CAST(NotComplete.[Count Not Complete] AS decimal)/CAST(NotComplete.[Count Not Complete] + Complete.[Count Complete] AS Decimal)*100 AS decimal(5,2)) AS [Percent Not Complete]
	CAST(((Complete.[Count Complete]*1.0)  / ((NotComplete.[Count Not Complete] + Complete.[Count Complete]) *1.0)*100) AS DECIMAL(5,2)) AS [Percent Complete],
	CAST(((NotComplete.[Count Not Complete]*1.0) /((NotComplete.[Count Not Complete] + Complete.[Count Complete])*1.0) *100) AS DECIMAL(5,2)) AS [Percent Not Complete]
	
	,NotComplete.Rics_CPDYear
FROM
(
	SELECT 
		COUNT(*) AS [Count Not Complete],
		cpdas.[Rics_CPDYear],
		cpdas.[ricsv1_CPDRecordingStatus_Description] AS cpdrecordingstatus
	FROM CE.vwCPDAnnualsummary AS cpdas
		INNER JOIN cteActiveContacts AS c 
			ON cpdas.rics_contactid = c.contactid
	WHERE cpdas.[Rics_CPDYear] >= YEAR(GETDATE())-3
		AND ricsv1_cpdrecordingstatus in (200000002,200000003)  --Self Declared, Targeted WAS (3,4)
		AND Rics_cpdcomplete = 0 

	GROUP BY 
		Rics_cpdcomplete,
		cpdas.[ricsv1_CPDRecordingStatus_Description],
		cpdas.Rics_CPDYear
)NotComplete

	Cross Apply
		(
		-- Query to union above tempory tables to allow for no values
		SELECT i.* 
		FROM
		(
			SELECT 
					[Count Complete],
					[Rics_CPDYear],
					cpdrecordingstatus 
			FROM cteMyTable
			UNION
			SELECT 
				[Count Complete],
				[Rics_CPDYear],
				[cpdrecordingstatus]  
			FROM cteCompletedZero
			WHERE cpdrecordingstatus  NOT IN (SELECT cpdrecordingstatus FROM cteMyTable GROUP BY cpdrecordingstatus)
		) i
	WHERE i.cpdrecordingstatus  = NotComplete.cpdrecordingstatus
		AND i.Rics_CPDYear = NotComplete.Rics_CPDYear
)Complete
