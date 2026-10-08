CREATE   VIEW [FO].[vwSubsQuotes]
AS

	WITH cte AS
	(
		SELECT ProductID
		FROM Static.tblProductMatrix
		WHERE Item_Type = 'Subscription'
			AND IsActive = 'Yes'
		GROUP BY ProductID
	),
	ctePrevYear AS
	(
		SELECT rics_contactno, SubsCampaign
		FROM FO.vwSubsAdjusted
		--WHERE SubsCampaign = 'Subs0000'
		GROUP BY rics_contactno, SubsCampaign
	)

	SELECT 
		q.[quoteid],
		qd.[quotedetailid],
		msdyn_quotenumber,
		'Subs' + CAST(q.[apuk_campaignyear] AS NVARCHAR(4)) AS SubsCampaign,
		cnt.[rics_contactno],
		cnt.[Rics_contactno] AS [axaccountno],
		q.[name] AS [QuoteName],
		qd.[productid],
		qd.[productname],
		qd.[ProductNumber],
		qd.[baseamount] AS [SubsDueCur],
		--qd.[baseamount_base] AS [SubsDueMST],
		CASE WHEN q.[msdyn_isocurrencycode] = 'GBP' THEN qd.[baseamount] ELSE qd.[baseamount] / exr.[ExchangeRate]*1.0 END AS [SubsDueMST],
		qd.[tax] AS [Tax_Cur],
		--qd.[tax_base] AS [Tax_MST],
		CASE WHEN q.[msdyn_isocurrencycode] = 'GBP' THEN qd.[tax] ELSE qd.[tax] / exr.[ExchangeRate]*1.0 END AS [Tax_MST],
		q.[msdyn_isocurrencycode] AS [Currency],
		cnt.[rics_localgroupid],
		cnt.[Rics_MemberGrade],
		NULL AS [CostCentre],
		cnt.[rics_countryid] AS [apuk_countryid],
		--q.[apuk_ricsrecordid], 
		conc.[apuk_concessionid],
		conc.[apuk_concessiontypeid_Name],
		conc.[apuk_subscriptionyear],
		q.[apuk_paymentmethod],
		cnt.[Rics_PaymentCycle],
		conc.[apuk_dualmembership] AS [DualMembership],
		q.[createdon] AS [Quote_CreatedOn],
		q.[modifiedon] AS [Quote_ModifiedOn],
		q.[StateCode_Description],
		q.[StatusCode_Description],
		conc.apuk_name,
		conc.[apuk_discount],
		CASE 
			WHEN 
				cnt.Rics_ConcessionCode_Descritpion IN ('Life Member','Past President','Retired (Freelist)','Staff Member')
				OR 
				conc.[apuk_concessiontypeid_Name] IN ('Life Member','Past President','Retired (Freelist)','Staff Member')
			THEN 'M02'
			WHEN cp.[rics_Contactno] IS NULL THEN 'M01' 
			ELSE 'M02' 
		END AS [Movement],
		q.[apuk_lionheartdonation] AS [apuk_lionheartdonation_CUR],
		q.[apuk_lionheartdonation_base] AS [apuk_lionheartdonation_MST]
	 FROM CE.vwQuote q
		INNER JOIN CE.vwQuoteDetail qd
			ON q.[quoteid] = qd.[quoteid]
		INNER JOIN [CE].[vwContact] cnt
			ON q.[CustomerId] = cnt.[ContactId]
		INNER JOIN cte c1
			ON REPLACE(qd.[productnumber], 'rcs', '') = c1.[ProductID]
		LEFT JOIN [CE].[vwConcession] conc
			ON q.[apuk_ricsrecordid] = conc.[apuk_ricsrecordid]
				AND qd.[productid] = conc.[ProductId]
				AND conc.[StateCode] = 0 --'Active'
				AND q.[apuk_campaignyear] = conc.[apuk_subscriptionyear]
		LEFT JOIN ctePrevYear cp
			ON cnt.[Rics_contactno] = cp.[rics_contactno]
			AND cp.[SubsCampaign] = 'Subs' + CAST(q.[apuk_campaignyear]-1 AS NVARCHAR(4))
		LEFT JOIN Static.tblTestContacts tst
			ON cnt.[Rics_contactno] = tst.[apuk_contactnumber]
		LEFT JOIN [FO].[vwExchangeRates] exr
			ON q.[msdyn_isocurrencycode] = exr.[ToCurrency]
			AND q.[createdon] BETWEEN exr.[FromDate] AND exr.[ToDate]
			AND exr.[RateTypeName] = 'Default'
	WHERE q.apuk_campaignyear IS NOT NULL-- = 2022
		AND q.[StateCode_Description] NOT IN ('Closed', 'Draft', 'Credited')
		AND qd.[productid] <> '00000000-0000-0000-0000-000000000000'
		AND tst.[apuk_contactnumber] IS NULL
