CREATE   VIEW [FO].[vwSubsRenewals]
AS
	WITH ctePrevYear AS
	(
		SELECT rics_contactno, SubsCampaign
		FROM FO.tblSubsAdjusted
		--WHERE SubsCampaign = 'Subs0000'
		GROUP BY rics_contactno, SubsCampaign
	)

SELECT 
	sr.[SubsCampaign],
	sr.[rics_contactno],
	sr.[rics_contactno] AS accountnum,
	sr.subsduemst,
	sr.subsduecur,
	sr.currency,
	lg.apuk_name AS localgroup,
	sr.rics_membergrade,
	sr.CostCentre,
	cnt.apuk_code AS CountryCode,
	sr.[apuk_concessionid],
	conc.apuk_name AS Concession,
	sr.rics_paymentmethod,
	sr.rics_paymentcycle,
	sr.dualmembership,
	sr.membercount,
	sr.TransDate,
	sr.[Concession_Amount_CUR],
	sr.[Concession_Amount_MST],
	sr.[Source],
	CASE 
		WHEN cp.[rics_contactno] IS NULL AND conc.[apuk_name] IN ('Life Member', 'Past President', 'Retired (Freelist)', 'Staff Member')  THEN 'M02' 
		WHEN cp.[rics_contactno] IS NULL THEN 'M01' 
		ELSE 'M02'
	END AS [Movement],
	sr.[Won_Amount_CUR],
	sr.[Won_Amount_MST],
	sr.[Quote_Won_Count],
	sr.[Quote_StateCode],
	sr.[Quote_StatusCode],
	--sr.[QuoteId],
	sr.[SalesOrder_Subs_Amount_Cur],
	sr.[SalesOrder_NonSubs_Amount_Cur],
	sr.[SalesOrder_Subs_Amount_Mst],
	sr.[SalesOrder_NonSubs_Amount_Mst]
FROM [FO].[tblSubsRenewals] sr
	LEFT JOIN [CE].[vwLocalGroup] lg
		ON sr.[apuk_localgroupid] = lg.[apuk_localgroupid]
	LEFT JOIN [CE].[vwCountry] cnt
		ON sr.[apuk_countryid] = cnt.[apuk_countryid]
	LEFT JOIN [CE].[vwConcession] conc
		ON sr.[apuk_concessionid] = conc.[apuk_concessionid]
	LEFT JOIN [Static].[tblTestContacts] tst
		ON sr.[rics_contactno] = tst.[apuk_contactnumber]
	LEFT JOIN ctePrevYear cp
		ON sr.[Rics_contactno] = cp.[rics_contactno]
			AND cp.[SubsCampaign] = 'Subs' + CAST(SUBSTRING(sr.[SubsCampaign], 5, 4)-1 AS NVARCHAR(4))

WHERE tst.[apuk_contactnumber] IS NULL
