CREATE   VIEW [D365_Exception].[vwZeroQuotes_WorkingPartTime]
AS
	--Exception report to show professional fee quotes with no professional fee products and zero quotes with working part time concession
	WITH cteProfQuotes AS
	(
		SELECT quoteid
		FROM synapse_ce.Quote
		WHERE [name] LIKE 'Membership Renewal%'
	),
	cteProfFeeProducts AS
	(
		SELECT 
			qd.[quoteid],
			SUM(CASE WHEN qd.productname like '%Professional%Subscription%'  THEN 1 ELSE 0 END) AS [ProfFeeProductCount],
			SUM(CASE WHEN qd.productname like '%working%'  THEN 1 ELSE 0 END) AS [PartTimeProductCount]
		FROM synapse_ce.QuoteDetail qd
			INNER JOIN cteProfQuotes cte
				ON qd.quoteid = cte.quoteid
		GROUP BY 
			qd.[quoteid]
	)

	SELECT 
			REPLACE(q.[quotenumber], 'rcs', '') AS [QuoteNumber],
		q.[name],
		ownid.[FullName] AS [Owner],
		q.[createdon] AS [Quote_CreatedOn],
		q.[statuscode],
		q.[StatusCode_Description],
		q.[statecode],
		q.[StateCode_Description],
		cnt.[Rics_contactno] AS [apuk_contactnumber],
		cnt.[FullName] AS [CustomerIdName],
		cntbillto.[fullname] AS [BillTo_ContactName],
		q.[apuk_paymentmethod],
		q.[apuk_paymentmethod_description],
		q.[msdyn_isocurrencycode] AS [Currency],
		q.[totalamount] + ISNULL(q.[apuk_lionheartdonation], 0) AS [totalamount],
		q.[totalamount_base] + ISNULL(q.[apuk_lionheartdonation_base], 0) AS totalamount_base,
		q.[totalamountlessfreight],
		q.[totalamountlessfreight_base],
		q.[totaltax],
		q.[totaltax_base],
		q.[apuk_lionheartdonation],
		q.[apuk_lionheartdonation_base],
		cte.[ProfFeeProductCount],
		cte.[PartTimeProductCount],
		CASE
			WHEN (q.[totallineitemamount] = 0 AND cte.[PartTimeProductCount] > 0) THEN 'Zero Quote with Working Part Time Concession'
			WHEN cte.[ProfFeeProductCount] = 0 THEN 'No Professional Fee Product'
		END [Exception_Type]
	FROM synapse_ce.vwQuote q
		INNER JOIN cteProfFeeProducts cte
			ON q.[quoteid] = cte.[quoteid]
		LEFT JOIN [synapse_ce].[tblContact_BI] cnt
			ON q.[customerid] = cnt.[ContactId]
		LEFT JOIN [synapse_ce].[tblContact_BI] cntbillto
			ON q.[apuk_billto] = cntbillto.[ContactId]
		LEFT JOIN synapse_ce.SystemUser ownid
			ON q.[ownerid] = ownid.[SystemUserId]

	WHERE 
		(cte.[ProfFeeProductCount] = 0 OR (q.[totallineitemamount] = 0 AND cte.[PartTimeProductCount] > 0))
