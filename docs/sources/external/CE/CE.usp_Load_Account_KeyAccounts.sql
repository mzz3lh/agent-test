CREATE   PROCEDURE [CE].[usp_Load_Account_KeyAccounts]
AS
BEGIN


	;WITH cteSchemes AS
	(
		SELECT apuk_licensedfirmid
		FROM
			synapse_ce.vwRegulatedScheme
		WHERE [StatusCode] IN ('000000000','000000000')
			AND [StateCode] = '0'
			AND [apuk_regulatedschemetypeidName] = 'Regulated by RICS'
			AND [apuk_schemeenddate] IS NULL
		GROUP BY apuk_licensedfirmid
	)
	,cteConnection AS
	(
		SELECT
			[record1id], 
			usr.fullname AS [Key Account Manager]
		FROM synapse_ce.connection conn
			INNER JOIN synapse_ce.systemuser usr
				ON conn.[name] = usr.[fullname]
		WHERE conn.[record1id_entitytype] = 'account'
			AND conn.[record2id_entitytype] = 'systemuser'
			AND conn.[record2roleidName] = 'Regulated Firms Specialist'
			AND conn.[StatusCode] = 1
		GROUP BY 	
			conn.[record1id], 
			usr.fullname
	)

	SELECT 
		acc.[AccountId],
		IIF(regsch.apuk_licensedfirmid IS NOT NULL AND conn.record1id IS NOT NULL, 1, 0) AS [KeyAccount],
		conn.[Key Account Manager]
	INTO #tempkeyaccounts
	FROM [synapse_ce].[Account] acc
		/* Raj Maddala, 2024-03-14, Added the logic for deriving KeyAccount */
		LEFT JOIN cteSchemes regsch
			ON acc.[accountid] = regsch.[apuk_licensedfirmid]
		LEFT JOIN cteConnection conn
			ON acc.[accountid] = conn.[record1id]



	--Update existing
	UPDATE tgt SET 
		tgt.[KeyAccount] = src.[KeyAccount],
		tgt.[KeyAccountManager] = src.[Key Account Manager]
	FROM [CE].[tblAccount_KeyAccounts] tgt
		INNER JOIN #tempkeyaccounts src
			ON tgt.[AccountId] = src.[AccountId]

	
	--Insert new
	INSERT INTO [CE].[tblAccount_KeyAccounts]
	(
		[AccountId]
		,[KeyAccount]
		,[KeyAccountManager]
	)
	SELECT 
		src.[AccountId]
		,src.[KeyAccount]
		,src.[Key Account Manager]
	FROM #tempkeyaccounts src
		LEFT JOIN [CE].[tblAccount_KeyAccounts] tgt
			ON src.[AccountId] = tgt.[AccountId]
	WHERE tgt.[AccountId] IS NULL

END
