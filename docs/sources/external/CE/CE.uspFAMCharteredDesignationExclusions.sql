CREATE PROCEDURE [CE].[uspFAMCharteredDesignationExclusions]
	AS
	BEGIN
	
	TRUNCATE TABLE CE.tblFAMCharteredDesignationExclusions;

	
	WITH cteFAMvwCD
AS
(

	SELECT --DISTINCT
	CONCAT(C.ContactID,CD.ID) AS CDKey,
		C.Contactid AS ContactID, --00000000-0000-0000-0000-000000000000   --00000000-0000-0000-0000-000000000000
		CD.apuk_name AS CharteredDesignation, 
		CD.ID AS CharteredDesignationId,
		MAX(MCD.modifiedon) AS modifiedon

	FROM [synapse_ce].[Contact] C
		 LEFT JOIN [synapse_ce].[apuk_ricsrecord] RR 
			ON C.contactid = RR.apuk_ContactID
		 LEFT JOIN [synapse_ce].[apuk_memberchartereddesignation] MCD 
			ON RR.apuk_ricsrecordid = MCD.apuk_ricsrecordid
		 LEFT JOIN [synapse_ce].[apuk_chartereddesignation] CD 
			ON MCD.apuk_chartereddesignationid = CD.apuk_chartereddesignationid
		 INNER JOIN FAM.vwMember M 
			ON C.contactid = M.ContactID
	WHERE MCD.apuk_enddate IS NULL
		  AND MCD.statecode = 0
		  AND CD.id IS NOT NULL
		  AND c.apuk_directdebit <> 1

		  AND C.apuk_membergrade NOT LIKE '%Qualified%' --Only allow Qualified member designations as agreed in meeting 02/08/2024.
	GROUP BY
			C.Contactid, --00000000-0000-0000-0000-000000000000   --00000000-0000-0000-0000-000000000000
		CD.apuk_name , 
		CD.ID 
		),

		--SELECT * FROM cteFAMvwCD
	CTE AS (
	SELECT
	[ENR ID]
	,ROW_NUMBER() OVER (PARTITION BY [Contact ID] ORDER BY [Created Date] DESC) AS ROWNUM
	FROM CE.vwEnrolments ENR
	WHERE 1=1
	AND ENR.[Status]= 'Vetting In-progress'
	AND ENR.[Route]= 'Chartered Direct Entry'  --MRICS Only? - check this
	AND ENR.[Election Date] IS NULL
	AND ENR.[End Date] IS NULL
	)

--INSERT CE.tblFAMCharteredDesignationExclusions

SELECT CD.CDKey,ENR.Status, ENR.Route, ENR.[Election Date],ENR.[End Date],ENR.[Contact No],  
CD.ContactId, CD.CharteredDesignationID, 
CR.[apuk_credentialrecordid]
--INTO CE.tblFAMCharteredDesignationExclusions
FROM cteFAMvwCD CD
LEFT JOIN CE.vwEnrolments ENR
	ON CD.ContactID = ENR.[Contact ID]
LEFT JOIN [synapse_ce].[vwCredentialRecord]CR
ON CD.CharteredDesignationId = CR.apuk_credential
AND CD.ContactID = CR.apuk_contact
WHERE EXISTS (
		SELECT 
		[ENR ID]
		FROM CTE
		WHERE CTE.[ENR ID] = ENR.[ENR ID]
		AND CTE.ROWNUM = 1
		)

END
