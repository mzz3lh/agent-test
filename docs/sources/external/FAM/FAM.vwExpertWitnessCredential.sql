/****** Object:  View [dbo].[vwExpertWitnessCredential]    Script Date: 26/08/2022 10:50:32 ******/

CREATE   VIEW [FAM].[vwExpertWitnessCredential]
AS

	--Expert Witness
	SELECT 
		CRR.apuk_contact AS ContactID, 
		CR.apuk_name AS [Credential], 
		CR.ID AS CredentialID,
		MAX(IIF(CR.modifiedon > ISNULL(CRR.modifiedon, '1900-01-01'), CR.modifiedon, ISNULL(CRR.modifiedon, '1900-01-01'))) AS modifiedon
	FROM [synapse_ce].[apuk_credential] CR
		LEFT JOIN  [synapse_ce].[apuk_credentialrecord] CRR 
			ON CR.ID= CRR.apuk_credential
	WHERE apuk_credential  IN (SELECT ID FROM [synapse_ce].[apuk_credential] WHERE apuk_name LIKE '%Expert Witness%' AND statecode = 0 )
		AND CRR.apuk_endDate IS NULL
		AND CRR.statecode = 0
		AND CRR.apuk_contact IS NOT NULL
	GROUP BY
		CRR.apuk_contact, 
		CR.apuk_name, 
		CR.ID
