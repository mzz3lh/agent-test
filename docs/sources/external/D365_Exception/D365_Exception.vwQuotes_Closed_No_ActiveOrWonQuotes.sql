CREATE   VIEW [D365_Exception].[vwQuotes_Closed_No_ActiveOrWonQuotes]
AS
WITH cteQuotes AS
(
	SELECT 
		q.apuk_campaignyear ,
		q.customerid, 
		SUM(CASE WHEN q.StateCode_Description = 'Closed' THEN 1 ELSE 0 END) AS Closed_Count,
		SUM(CASE WHEN q.StateCode_Description IN ('Active', 'Won') THEN 1 ELSE 0 END) AS Active_Won_Count

	FROM synapse_ce.vwQuote q
	WHERE q.apuk_campaignyear IS NOT NULL
	GROUP BY
		q.apuk_campaignyear ,
		q.customerid
)
,cteEnrolments AS
(
	SELECT 
		apuk_ricsrecordid, 
		MIN(rics_enrolmentdate) AS Earliest_Enrolmentdate, 
		MAX(rics_enrolmentdate) AS Latest_Enrolmentdate
	FROM synapse_ce.vwRicsApc
	GROUP BY apuk_ricsrecordid
)

SELECT 
	REPLACE(qte.[quotenumber], 'rcs', '') AS [QuoteNumber],
	qte.[name],
	ISNULL(cnt.[Rics_contactno], acc.[AccountNumber]) AS AccountNum,
	cnt.[Rics_LapsedCode],
	cnt.[Rics_LapsedCode_Description],
	cnt.[Rics_LapsedDate],
	ownid.[FullName] AS [Owner],
	qte.[createdon] AS [Quote_CreatedOn],
	qte.[statuscode],
	qte.[StatusCode_Description],
	qte.[statecode],
	qte.[StateCode_Description],
	qte.[apuk_campaignyear],
	ISNULL(cnt.[FullName], acc.[name]) AS [CustomerIdName],
	cntbillto.[fullname] AS [BillTo_ContactName],
	qte.[apuk_paymentmethod],
	qte.[apuk_paymentmethod_description],
	qte.[msdyn_isocurrencycode] AS [Currency],
	qte.[totalamount],
	qte.[totalamount_base],
	qte.[totalamountlessfreight],
	qte.[totalamountlessfreight_base],
	qte.[totaltax],
	qte.[totaltax_base],
	qte.[apuk_lionheartdonation],
	qte.[apuk_lionheartdonation_base],
	enr.[Earliest_Enrolmentdate],
	enr.[Latest_Enrolmentdate],
	lg.[apuk_name] AS [LocalGroup],
	lg.[apuk_regionid_name] AS [Region],
	lg.[apuk_worldregionid_name] AS [World_Region]
FROM cteQuotes q
	LEFT JOIN synapse_ce.vwQuote qte
		ON q.[customerid] = qte.[customerid]
		AND q.apuk_campaignyear = qte.apuk_campaignyear
	LEFT JOIN synapse_ce.tblContact_BI cnt
		ON q.customerid = cnt.ContactId
	LEFT JOIN synapse_ce.vwlocalgroup lg
		ON cnt.[rics_localgroupid] = lg.[apuk_localgroupid]
	LEFT JOIN synapse_ce.Account acc
		ON q.customerid = acc.AccountId
	LEFT JOIN [synapse_ce].[tblContact_BI] cntbillto
		ON qte.[apuk_billto] = cntbillto.[ContactId]
	LEFT JOIN synapse_ce.SystemUser ownid
		ON qte.[ownerid] = ownid.[SystemUserId]
	LEFT JOIN cteEnrolments enr
		ON cnt.[apuk_ricsrecordid] = enr.[apuk_ricsrecordid]
WHERE 
	Active_Won_Count = 0 
	AND Closed_Count > 0
	AND qte.[StateCode_Description] = 'Closed'
--1151
