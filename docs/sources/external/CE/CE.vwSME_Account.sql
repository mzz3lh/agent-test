CREATE VIEW [CE].[vwSME_Account] AS

	SELECT
	 ACC.AccountId AS 'Account ID'
	,ACC.AccountNumber AS 'Account Number'
	,ACC.name AS 'Account Name'
	,ACC.Rics_LocalGroupId
	,CASE
		WHEN Firm_Size IS NULL THEN 'N/A'
		WHEN Rics_LegalStatus IN (200000000, 200000001) THEN '1' --Sole Practitioner, Sole Trader
		ELSE Firm_Size
	END AS 'Firm Size'
	FROM CE.vwAccount ACC
	LEFT JOIN CE.vwSME_Firm_Size FS
		ON ACC.AccountId = FS.apuk_regulatedfirmid
	WHERE EXISTS (
		SELECT
		RGS.[Account ID]
		FROM CE.vwSME_Regulated_Schemes RGS
		WHERE RGS.[Account ID] = ACC.AccountId
		)
