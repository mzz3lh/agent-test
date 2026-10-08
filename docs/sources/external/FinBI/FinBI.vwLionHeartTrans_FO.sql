CREATE    VIEW [FinBI].[vwLionHeartTrans_FO]
AS

	WITH cteCampaignYears AS
	(
		SELECT CASE WHEN MONTH(GETDATE()) > 10 THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END AS CampaignYear
		UNION
		SELECT CASE WHEN MONTH(GETDATE()) > 10 THEN YEAR(GETDATE()) ELSE YEAR(GETDATE())-1 END AS CampaignYear
	),
	cteQuotes AS
	(
		SELECT q.[apuk_campaignyear], SUBSTRING(so.[OrderNumber], 4, 50) AS OrderNumber, q.StateCode_Description
		FROM [CE].[vwQuote] q
			INNER JOIN [CE].[vwSalesOrder] so
				ON q.[quoteid] = so.[quoteid]
		WHERE q.[apuk_campaignyear] IS NOT NULL
	)
	SELECT 
			ct.[DataAreaID]
		   ,ct.[ORDERNUM]
		  ,ct.[AccountNum]
		  ,ct.[TransDate] InvDate
		  ,ct.[Voucher]
		  ,ct.[Invoice]
		  ,ct.[AmountCur]
		  ,ct.[SettleAmountCur]
		  ,ct.[AmountMST]
		  ,ct.[SettleAmountMST]
		  ,ct.[CurrencyCode]
		  ,ct.[DueDate]
		  ,ct.[Closed] SettleDate
		  ,'1110' CostCentre
		  ,NULL AS [Dimension3_]
		  ,ct.[PaymMode]
		,ct.RicInvoiceType
		,CASE 
			WHEN q.[apuk_campaignyear] IS NOT NULL THEN 'Subs' + CAST(q.[apuk_campaignyear] AS nvarchar(4)) 
			WHEN q.[apuk_campaignyear] IS NULL AND ct.[ORDERNUM] LIKE 'Subs' THEN ct.[ORDERNUM]
			ELSE
				CASE
					WHEN DATEPART(MONTH, ct.[TRANSDATE]) >= 11 THEN 'Subs' + CAST(DATEPART(YEAR, ct.[TransDate])+1 AS nvarchar(4))
					ELSE 'Subs' + CAST(DATEPART(YEAR, ct.[TransDate]) AS nvarchar(4))
				END
		END AS Campaign
		,YEAR(RIGHT(
			CASE 
				WHEN q.[apuk_campaignyear] IS NOT NULL THEN 'Subs' + CAST(q.[apuk_campaignyear] AS nvarchar(4)) 
				WHEN q.[apuk_campaignyear] IS NULL AND ct.[ORDERNUM] LIKE 'Subs' THEN ct.[ORDERNUM]
				ELSE
					CASE
						WHEN DATEPART(MONTH, ct.[TRANSDATE]) >= 11 THEN 'Subs' + CAST(DATEPART(YEAR, ct.[TransDate])+1 AS nvarchar(4))
						ELSE 'Subs' + CAST(DATEPART(YEAR, ct.[TransDate]) AS nvarchar(4))
					END
			END, 4)
			)AS CampaignYear

--			 ,YEAR(RIGHT(RicExternalInvoiceRef,4)) CampaignYear
			 ,FORMAT(ct.[Closed], 'dd-MMM') reportPeriod
			 ,CASE 
				WHEN YEAR(ct.[TRANSDATE]) = CASE WHEN MONTH(GETDATE()) > 10 THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END THEN 'Y'
				WHEN YEAR(ct.[TRANSDATE]) = CASE WHEN MONTH(GETDATE()) > 10 then YEAR(GETDATE()) ELSE YEAR(GETDATE())-1 END AND [Closed] < DATEADD(YEAR,-1,GETDATE()) THEN 'Y'
				ELSE 'N' 
			END vsPrevYear
	  FROM [synapse_fo].[CUSTTRANS_RICS] ct
		LEFT JOIN cteQuotes q
			ON ct.[ORDERNUM] = q.[OrderNumber]
	  WHERE RicInvoiceType = 'LHL'

		AND ct.SETTLEAMOUNTCUR >0
		--AND LASTSETTLEVOUCHER NOT LIKE 'REV%'
		--AND LASTSETTLEVOUCHER NOT LIKE 'MWF%'
		AND ct.LASTSETTLEVOUCHER NOT LIKE 'CRE%'
		--AND LASTSETTLEVOUCHER NOT LIKE '%GV'
		--and RicExternalInvoiceRef in ('subs0000','subs0000')
		AND YEAR(ct.[TRANSDATE]) IN (SELECT CampaignYear FROM cteCampaignYears)
