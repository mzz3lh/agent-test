CREATE   VIEW [D365_Exception].[vwQuotes_FutureCampaignYears]
AS
SELECT 
	REPLACE(q.[quotenumber], 'rcs', '') AS [QuoteNumber],
	q.[name],
	ownid.[FullName] AS [Owner],
	q.[createdon] AS [Quote_CreatedOn],
	q.[statuscode],
	q.[StatusCode_Description],
	q.[statecode],
	q.[StateCode_Description],
	q.[apuk_campaignyear],
	cnt.[FullName] AS [CustomerIdName],
	cntbillto.[fullname] AS [BillTo_ContactName],
	q.[apuk_paymentmethod],
	q.[apuk_paymentmethod_description],
	q.[msdyn_isocurrencycode] AS [Currency],
	q.[totalamount],
	q.[totalamount_base],
	q.[totalamountlessfreight],
	q.[totalamountlessfreight_base],
	q.[totaltax],
	q.[totaltax_base],
	q.[apuk_lionheartdonation],
	q.[apuk_lionheartdonation_base]
FROM [synapse_ce].[vwQuote] q
	LEFT JOIN [synapse_ce].[tblContact_BI] cnt
		ON q.[customerid] = cnt.[ContactId]
	LEFT JOIN [synapse_ce].[tblContact_BI] cntbillto
		ON q.[apuk_billto] = cntbillto.[ContactId]
	LEFT JOIN synapse_ce.SystemUser ownid
		ON q.[ownerid] = ownid.[SystemUserId]
WHERE apuk_campaignyear > IIF(DATEPART(MONTH, getdate()) >= 11, DATEPART(YEAR, getdate())+1, DATEPART(YEAR, getdate()))
