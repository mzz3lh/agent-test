CREATE   VIEW  [FO].[vwSubsAdjusted] 
 AS 

	 WITH cteConcession AS
	 (
		SELECT 
			[apuk_concessionid],
			[rics_contactno],
			'Subs' + CAST(apuk_subscriptionyear AS NVARCHAR) AS SubsCampaign,
			ROW_NUMBER() OVER(PARTITION BY rics_contactno, apuk_subscriptionyear ORDER BY modifiedon DESC) AS RowNo
		FROM [CE].[vwConcession] 
		WHERE apuk_dualmembership = 0		
	 ),
	 cteRenewals AS
	(
		SELECT 
			rics_contactno, 
			SubsCampaign,
			SUM(subsduemst) AS SubsDueMst
		FROM FO.vwSubsRenewals
		GROUP BY 
			rics_contactno
			,SubsCampaign
	), cteContacts AS
	(
		SELECT	
			[Rics_contactno],
			[rics_countryidName]
		FROM [CE].[vwContact]
	), cteAccount AS
	(
		SELECT	
			[AccountNumber],
			[rics_countryidName]
		FROM [CE].[vwAccount]
	)



		SELECT
			sa.[SubsAdjustedId],
			sa.[AccountNum],
			sa.[rics_contactno],
			sa.[Voucher],
			sa.[SubsCampaign],
			--sa.[CostCentre],
			'1110' AS [CostCentre],
			'1110' + '_' + ISNULL(ctry.[Country_Code], 'UNW') AS [CostCentreKey],
			sa.[OriginalAmount],
			--IIF((sa.[AdjustedAmount] - ISNULL(sa.[CreditNoteAmount_Mst], 0)) < 0, 0, (sa.[AdjustedAmount] - ISNULL(sa.[CreditNoteAmount_Mst], 0))) AS [AdjustedAmount],  --Deduct Creditnotes from the AdjustedAmount
			sa.[AdjustedAmount],
			--sa.[Paid] + ISNULL(sa.[CreditNoteAmount_Mst], 0) AS [Paid],
			sa.[Paid],
			--sa.[TotalPaid] + ISNULL(sa.[CreditNoteAmount_Mst], 0) AS [TotalPaid],
			sa.[TotalPaid],
			sa.[diff],
			sa.[BalanceGBP],
			sa.[Movement],
			sa.[LocalGroup],
			/*CASE 
				WHEN sa.[AX_ConcessionCode] = 1 THEN '00000000-0000-0000-0000-000000000000' --Assign a temp GUID
				WHEN sa.[AX_ConcessionCode] IS NULL AND sa.[Source] = 'AX' THEN NULL 
				WHEN sa.[AX_ConcessionCode] > 1 AND sa.[Source] = 'AX' AND sa.[rics_concessioncode] IS NULL AND conc.[apuk_concessionid] IS NULL THEN '00000000-0000-0000-0000-000000000000' --Assign new temp concession code
				WHEN sa.[AX_ConcessionCode] > 1 AND sa.[Source] = 'AX' AND sa.[rics_concessioncode] IS NULL AND conc.[apuk_concessionid] IS NOT NULL THEN conc.[apuk_concessionid]
				--ELSE conc.[apuk_concessionid] 
				ELSE sa.[rics_concessioncode]
			END AS [rics_concessioncode],*/ --RM/AAB removed 21/04/22, Original AX migrated accounts awarded correct GUID values, no longer needed
			sa.[rics_concessioncode] AS [rics_concessioncode],
			sa.[trainee_qualified_code],
			sa.[dncCategory],
			sa.[rics_lapsedcode],
			--conc.[apuk_concessionid],
			sa.[rics_concessioncode] AS [apuk_concessionid],   --Raj, 2022-01-19, get concession code from subsadjusted
			ctry.[Country_Code] AS CountryCode,
			sa.[Source],
			sa.[AX_ConcessionCode],
			sa.[AX_Delta_Amount],
			sa.[CreditNoteAmount_Cur],
			sa.[CreditNoteAmount_Mst]
		FROM [FO].[tblSubsAdjusted_Cleansed] sa
		LEFT JOIN cteRenewals ren
			ON sa.rics_contactno = ren.rics_contactno
				AND sa.SubsCampaign = ren.SubsCampaign
		LEFT JOIN cteContacts cnt
			ON sa.[rics_contactno] = cnt.[Rics_contactno]
		LEFT JOIN
		(
			SELECT [Rics_contactno]
				,[Rics_LapsedCode]
				,[Rics_LapsedCode_Description]
				,[rics_countryidName]
				,MAX([Rics_LapsedDate]) Rics_LapsedDate
				,COUNT(*) AS Total_Rows
			FROM [SubsRep_BI].[vwContact_FO]
			WHERE [Rics_LapsedCode] IS NOT NULL
			GROUP BY
				[Rics_contactno]
			   ,[Rics_LapsedCode]
			   ,[Rics_LapsedCode_Description]
			   ,[rics_countryidName]
			HAVING COUNT(*) = 1
		) LC
			ON SA.rics_contactno = LC.Rics_contactno
				AND SA.[rics_lapsedcode] = LC.Rics_LapsedCode
			LEFT JOIN cteAccount acc
				ON sa.[AccountNum] = acc.[AccountNumber]
			LEFT JOIN [BI].[vwCountry_Mapping] ctry
				ON ISNULL(ISNULL(lc.[rics_countryidName], cnt.[rics_countryidName]), acc.[rics_countryidName]) = ctry.[Country_Name]
			LEFT JOIN cteConcession conc
				ON sa.[rics_contactno] = conc.[Rics_contactno]
				AND sa.[SubsCampaign] = conc.[SubsCampaign]
				AND conc.[RowNo] = 1
