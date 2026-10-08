CREATE       VIEW [FO].[vwCustomer] AS

	SELECT 
	 CT.ACCOUNTNUM AS 'Cust Account No'
	,CT.NAME AS 'Customer'
	,CT.PARTYTYPE AS 'Cust Type'
	,COALESCE(ACC.rics_namedaccount, ACCII.rics_namedaccount) AS 'Commercial Account ID'
	,COMM.apuk_name AS 'Commercial Account'
	,COMM.apuk_regionalaccountownerid AS 'Account Owner ID'
	--,COMM.apuk_regionalaccountowneridyominame AS 'Account Owner'
	,CASE 
		WHEN COMMACC.[Account Owner ID] IS NOT NULL THEN 'Y'
		WHEN COALESCE(ACC.rics_namedaccount, ACCII.rics_namedaccount) IS NOT NULL THEN 'N'
		ELSE 'Non-Commercial Account' 
	END AS 'B2B Flag',
	ISNULL(COMM.apuk_name, CT.NAME) AS 'Commercial Account Transformed'

	,ISNULL(lg.[apuk_regionid_name], lgacc.[apuk_regionid_name]) [Customer Region]
	,ISNULL(lg.[apuk_localgroupid], lgacc.[apuk_localgroupid]) AS [apuk_localgroupid]

	,CON.AccountId
	
	FROM FO.vwCustTable CT
	LEFT JOIN synapse_ce.tblContact_BI CON
		ON CON.Rics_contactno = CT.ACCOUNTNUM --Person Customers to Contact Table
	LEFT JOIN synapse_ce.vwAccount ACC
		ON CON.AccountId = ACC.AccountId --Contact Table to Account Table
	LEFT JOIN synapse_ce.vwAccount ACCII
		ON CT.ACCOUNTNUM = ACCII.AccountNumber --Account Customers to Account table
	LEFT JOIN synapse_ce.apuk_commercialaccount COMM
		ON COALESCE(ACC.rics_namedaccount, ACCII.rics_namedaccount) = COMM.apuk_commercialaccountid
	LEFT JOIN FO.vwCommercial_Account_Owner COMMACC
		ON COMMACC.[Account Owner ID] = COMM.apuk_regionalaccountownerid

	--2025-10-16, RM, Pulled contact's region name from local group as per Dave Allen's request to show on Commercial Income reporting
	LEFT JOIN CE.vwLocalGroup lg
		ON con.rics_localgroupid = lg.apuk_localgroupid
	LEFT JOIN CE.vwLocalGroup lgacc
		ON ACCII.Rics_LocalGroupId = lgacc.apuk_localgroupid
GROUP BY
	 CT.ACCOUNTNUM 
	,CT.NAME 
	,CT.PARTYTYPE 
	,COALESCE(ACC.rics_namedaccount, ACCII.rics_namedaccount) 
	,COMM.apuk_name 
	,COMM.apuk_regionalaccountownerid 
	--,COMM.apuk_regionalaccountowneridyominame AS 'Account Owner'
	,CASE 
		WHEN COMMACC.[Account Owner ID] IS NOT NULL THEN 'Y'
		WHEN COALESCE(ACC.rics_namedaccount, ACCII.rics_namedaccount) IS NOT NULL THEN 'N'
		ELSE 'Non-Commercial Account' 
	END ,
	ISNULL(COMM.apuk_name, CT.NAME)

	,ISNULL(lg.[apuk_regionid_name], lgacc.[apuk_regionid_name])
	,ISNULL(lg.[apuk_localgroupid], lgacc.[apuk_localgroupid])

	,CON.AccountId
