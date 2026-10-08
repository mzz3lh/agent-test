CREATE     VIEW [FAM].[vwCharteredDesignations]
AS

WITH cteCD
AS
(

	SELECT
	CONCAT(C.ContactID,CD.ID) AS CDKey,
		C.Contactid AS ContactID,
		CD.apuk_name AS CharteredDesignation, 
		CD.ID AS CharteredDesignationId,
		ISNULL(st.[Level1], '') AS [Level1],
		ISNULL(st.[Level2], '') AS [Level2],
		ISNULL(st.[Level3], '') AS [Level3],

		MAX(MCD.modifiedon) AS modifiedon

	FROM [synapse_ce].[Contact] C
		 LEFT JOIN [synapse_ce].[apuk_ricsrecord] RR 
			ON C.contactid = RR.apuk_ContactID
		 LEFT JOIN [synapse_ce].[apuk_memberchartereddesignation] MCD 
			ON RR.apuk_ricsrecordid = MCD.apuk_ricsrecordid
		 LEFT JOIN [synapse_ce].[apuk_chartereddesignation] CD 
			ON MCD.apuk_chartereddesignationid = CD.apuk_chartereddesignationid
		LEFT JOIN [static].tblFAMFilterHierarchy st
			ON cd.[ID] = st.[ID]
			AND st.[Datasource_Name] = 'Chartered Designations'

		 INNER JOIN FAM.vwMember M 
			ON C.contactid = M.ContactID
	WHERE MCD.apuk_enddate IS NULL
		  AND MCD.statecode = 0
		  AND CD.id IS NOT NULL
		  AND c.apuk_directdebit <> 1
		  AND RR.apuk_membergrade IN (200000001,200000002) -- --Amended logic following meeting 02/08/2024 - Only show CD's if member is qualified
	GROUP BY
			C.Contactid,
		CD.apuk_name , 
		CD.ID,
		ISNULL(st.[Level1], ''),
		ISNULL(st.[Level2], ''),
		ISNULL(st.[Level3], '')
	
)

SELECT ContactId,CharteredDesignation,CharteredDesignationId,modifiedon, [Level1], [Level2], [Level3] FROM cteCD

--CDKey NOT IN (SELECT CDKey FROM CE.tblFAMCharteredDesignationExclusions) --previous logic
