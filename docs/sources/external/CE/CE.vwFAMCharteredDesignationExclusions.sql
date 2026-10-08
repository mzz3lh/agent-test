/* View to show those applicants who have a DE route (MRICS only?) 
	and have no election date populated (which they shouldn't anyway), so that their CD's can be excluded from the 
	FAM feed
	*/
	
	CREATE VIEW CE.vwFAMCharteredDesignationExclusions
	AS

	WITH CTE AS (
	SELECT
	[ENR ID]
	,ROW_NUMBER() OVER (PARTITION BY [Contact ID] ORDER BY [Created Date] DESC) AS ROWNUM
	FROM CE.vwEnrolments ENR
	WHERE 1=1
	--ENR.[Status]= 'Vetting In-progress'
	AND ENR.[Route]= 'Chartered Direct Entry'  --MRICS Only? - check this
	AND ENR.[Election Date] IS NULL
	AND ENR.[End Date] IS NULL
	)


SELECT CONCAT(ContactID,CharteredDesignationId) AS CDKey,ENR.Status, ENR.Route, ENR.[Election Date],ENR.[End Date],ENR.[Contact No],  CD.* ,CR.[apuk_credentialrecordid]
FROM FAM.vwCharteredDesignations CD
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









/*

SELECT CD.ContactID,COUNT(CD.ContactID),C.Rics_contactno
FROM [FAM].[vwCharteredDesignations]CD
INNER JOIN CE.vwContact C
ON C.ContactID = CD.ContactId
GROUP BY CD.ContactID, C.Rics_contactno
HAVING COUNT(CD.ContactID)>1


SELECT  * FROM [FAM].[vwCharteredDesignations]CD
WHERE  




ContactID = '00000000-0000-0000-0000-000000000000'  --0000000




NOT IN (SELECT HASHBYTES('SHA',CAST(ContactID AS VARCHAR(50))) + HASHBYTES('SHA',CAST(CharteredDesignationId AS VARCHAR(50))) 
FROM CE.vwFAMCharteredDesignationExclusions)
*/
