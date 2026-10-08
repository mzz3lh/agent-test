CREATE      VIEW [FAM].[vwCredential]
AS

	--Not Expert Witness
	SELECT --DISTINCT 
		CRR.apuk_contact AS ContactID, 
		CR.apuk_name AS [Credential],
		CR.ID AS CredentialID,
		ISNULL(st.[Level1], '') AS [Level1],
		ISNULL(st.[Level2], '') AS [Level2],
		ISNULL(st.[Level3], '') AS [Level3]
	--INTO dbo.[Credential]
	FROM [synapse_ce].[apuk_credential] CR
		LEFT JOIN  [synapse_ce].[apuk_credentialrecord] CRR 
			ON CR.ID= CRR.apuk_credential
		LEFT JOIN static.tblFAMFilterHierarchy st
			ON cr.[ID] = st.[ID]
			AND st.[Datasource_Name] = 'Credential'

		INNER JOIN FAM.vwMember M 
			ON M.ContactID = CRR.apuk_contact
	WHERE --apuk_credential NOT IN (SELECT ID FROM [synapse_ce].[apuk_credential] WHERE apuk_name LIKE '%Expert Witness%' AND statecode = 0 )
		--AND 
		(CRR.apuk_endDate IS NULL OR CRR.apuk_enddate >= GETDATE())
		AND CRR.statecode = 0
		AND CRR.apuk_contact IS NOT NULL
		AND cr.apuk_name <> 'ECO Assessor Certification'
	GROUP BY
		CRR.apuk_contact, 
		CR.apuk_name,
		CR.ID,
		ISNULL(st.[Level1], ''),
		ISNULL(st.[Level2], ''),
		ISNULL(st.[Level3], '')
