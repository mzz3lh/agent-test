CREATE       VIEW [FO].[vwSubsPayments]
 AS 

	SELECT
		sp.[SubsPaymentsId],
		sp.[AccountNum],
		sp.[rics_contactno],
		sp.[SubsCampaign],
		sp.[SettlementDate],
		sp.[sPaymMode],
		sp.[SettlementPayGroup],
		sp.[trainee_qualified_code],
		sp.[LocalGroup],
		--sp.[CostCentre],
		'1110' AS [CostCentre],
		sp.[Movement],
		sp.[Diff],
		sp.[Actual_PaymentsCUR],
		sp.[Actual_PaymentsMST],
		sp.[Payments],
		sp.[AdjustedPayments],
		--sp.[AdjustedPayments_Cur], --New field used for this below AAB 16-05-22
		sp.AdjustedPaymentsCUR AS AdjustedPayments_Cur,
		sp.[Subs_SettleAmountCUR],
		sp.[Subs_SettleAmountMST],
		sp.[NonSubs_SettleAmountCUR],
		sp.[NonSubs_SettleAmountMST],
		sp.[NumOfTransactions],
		sp.[rics_concessioncode],
		sp.[rics_paymentcycle],
		'1110' + '_' + ctry.[Country_Code] AS [CostCentreKey],
		sp.[Source]
	FROM [FO].[tblSubsPayments] sp   /* RM, 2022-05-10, Changed to new logic*/
		--LEFT JOIN [CE].[vwContact] cnt
		--	ON sp.[rics_contactno] = cnt.[Rics_contactno]
		--LEFT JOIN [CE].[vwAccount] acc
		--	ON sp.[rics_contactno] = acc.[AccountNumber]
		LEFT JOIN [BI].[vwCountry_Mapping] ctry
			--ON ISNULL(cnt.[rics_countryidName], acc.[rics_countryidName]) = ctry.[Country_Name]
			ON ISNULL(sp.[rics_countryidName], 'Unknown') = ctry.[Country_Name]
			--ON sp.[rics_countryidName] = ctry.[Country_Name]
	--WHERE sp.[rics_countryidName] IS NOT NULL
