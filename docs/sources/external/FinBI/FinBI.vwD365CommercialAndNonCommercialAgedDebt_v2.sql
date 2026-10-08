/****************************************************************************
vwCommercialAndNonCommercialAgedDebt_v2

*********************************************************************************/
CREATE   VIEW [FinBI].[vwD365CommercialAndNonCommercialAgedDebt_v2]
AS

WITH ADJBAL AS (
	SELECT 
		  ACCOUNTNUM
		 ,VOUCHER
		 ,InvType
		 ,InvType_Rank
		 ,TotalDebtStatus
		 ,SUM(LineAmountMST) AS LineAmountMST
		 ,CASE WHEN MAX(SETTLEAMOUNTMST_Adj) = 0 THEN MIN(SETTLEAMOUNTMST_Adj) ELSE MAX(SETTLEAMOUNTMST_Adj) END AS SETTLEAMOUNTMST
		 ,SUM(LineAmountCUR) AS LineAmountCUR
		 ,CASE WHEN MAX(SETTLEAMOUNTCUR) = 0 THEN MIN(SETTLEAMOUNTCUR) ELSE MAX(SETTLEAMOUNTCUR) END AS SETTLEAMOUNTCUR
	 FROM [FO].[tblFOAgedDebt]
	 --WHERE ACCOUNT
	 GROUP BY ACCOUNTNUM, VOUCHER, InvType, InvType_Rank, [TRANSDATE], TotalDebtStatus
 ),
ADJBALII AS (
	  SELECT 
		  ACCOUNTNUM
		 ,VOUCHER
		 ,InvType
		 ,InvType_Rank
		 ,TotalDebtStatus
		 ,LineAmountMST
		 ,SETTLEAMOUNTMST
		 ,LineAmountCUR
		 ,SETTLEAMOUNTCUR
		 --,SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank) AS BHAAL
		 --,SETTLEAMOUNTMST - SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank) AS ALTERR
		 --,SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank) - SETTLEAMOUNTMST AS ALTERRY
		,CASE
			WHEN SETTLEAMOUNTMST = 0 THEN LineAmountMST
			WHEN LineAmountMST > 0 THEN
				CASE 
					WHEN (SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTMST) >= LineAmountMST THEN LineAmountMST
					WHEN (SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTMST) <= 0 THEN 0
					ELSE SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTMST
				END
			WHEN LineAmountMST < 0 THEN
				CASE 
					WHEN (SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTMST) <= LineAmountMST THEN LineAmountMST
					WHEN (SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTMST) >= 0 THEN 0
					ELSE SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTMST
				END
			ELSE SUM(LineAmountMST) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTMST
			END AS NewBalanceGBP
		,CASE
			WHEN SETTLEAMOUNTCUR = 0 THEN LineAmountCUR
			WHEN LineAmountCUR > 0 THEN
				CASE 
					WHEN (SUM(LineAmountCUR) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTCUR) >= LineAmountCUR THEN LineAmountCUR
					WHEN (SUM(LineAmountCUR) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTCUR) <= 0 THEN 0
					ELSE SUM(LineAmountCUR) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTCUR
				END
			WHEN LineAmountCUR < 0 THEN
				CASE 
					WHEN (SUM(LineAmountCUR) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTCUR) <= LineAmountCUR THEN LineAmountCUR
					WHEN (SUM(LineAmountCUR) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTCUR) >= 0 THEN 0
					ELSE SUM(LineAmountCUR) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTCUR
				END
			ELSE SUM(LineAmountCUR) OVER( PARTITION BY ACCOUNTNUM, VOUCHER ORDER BY InvType_Rank, InvType) - SETTLEAMOUNTCUR
			END AS NewBalanceCUR
	 FROM ADJBAL
	 WHERE TotalDebtStatus <> 'Zero Balance' --Updated by Raj on 2025-03-27 due to that Aged debt report should be able to sliced by transdate instead as of now.
 ),

cteData AS
(
	SELECT 
		AD.ACCOUNTNUM AS [AX Account No],
		ContactNo AS [CRM Contact No],
		RDDDBucket,
		Currency,
		CUSTGROUP,
		SubsYear AS [External Invoice Ref],
		CUST_NAME AS [Customer Name],
		INVOICE,
		AD.VOUCHER,
		DUEDATE AS [Due Date],
		AD.InvType AS [Invoice Type],
		CostCentre,
		MIN(AD.CREATEDDATETIME) AS [Created Date Time],
		AD.CREATEDBY AS [Created By],
		AD.TotalDebtStatus,
		CRMPaymentCycle,
		PAYMMODE,
		DUEDATE,
		TRANSDATE,
		ADJBALII.NewBalanceGBP AS BalanceGBP,
		ADJBALII.NewBalanceCUR AS BalanceCUR,
		ADJBALII.SETTLEAMOUNTMST,
		ADJBALII.SETTLEAMOUNTCUR,
		ONHOLDSTATUS,
		ONHOLDSTATUS_Description,
		AD.CTAMOUNTCUR AS Invoice_Amount_CUR,
		AD.CTAMOUNTMST AS Invoice_Amount_MST
		,CASE WHEN (INVOICE IS NULL OR INVOICE = '') AND NewBalanceCUR = 0 AND AD.TotalDebtStatus <> 'Zero Balance' THEN 'Y' ELSE 'N' END AS 'GJ Exclusion' 

	FROM FO.tblFOAgedDebt AD
		LEFT JOIN ADJBALII AS ADJBALII 
			ON ADJBALII.ACCOUNTNUM = AD.ACCOUNTNUM 
				AND ADJBALII.VOUCHER = AD.VOUCHER 
				AND ADJBALII.InvType = AD.InvType

	WHERE AD.ACCOUNTNUM NOT LIKE 'ISL%'
		AND AD.TotalDebtStatus <> 'Zero Balance' --Updated by Raj on 2025-03-27 due to that Aged debt report should be able to sliced by transdate instead as of now.

	GROUP BY 
		AD.ACCOUNTNUM, 
		ContactNo, 
		RDDDBucket, 
		Currency, 
		CUSTGROUP, 
		SubsYear,
		CUST_NAME, 
		INVOICE, 
		AD.VOUCHER, 
		DUEDATE, 
		AD.InvType, 
		CostCentre,
		AD.CREATEDBY, 
		AD.TotalDebtStatus, 
		CRMPaymentCycle, 
		PAYMMODE, 
		DUEDATE, 
		TRANSDATE, 
		ADJBALII.
		NewBalanceGBP, 
		ADJBALII.
		NewBalanceCUR, 
		ADJBALII.
		SETTLEAMOUNTMST, 
		ADJBALII.SETTLEAMOUNTCUR,
		ONHOLDSTATUS, 
		ONHOLDSTATUS_Description, 
		AD.CTAMOUNTCUR, 
		AD.CTAMOUNTMST
)

SELECT 
	*, 	
	CASE RDDDBucket WHEN 'Current'	THEN BalanceGBP ELSE 0.00 END AS [Current],
	CASE RDDDBucket WHEN '0to30'	THEN BalanceGBP ELSE 0.00 END AS [0-30],
	CASE RDDDBucket WHEN '31to60'	THEN BalanceGBP ELSE 0.00 END AS [31-60],
	CASE RDDDBucket WHEN '61to90'	THEN BalanceGBP ELSE 0.00 END AS [61-90],
	CASE RDDDBucket WHEN '91to120'	THEN BalanceGBP ELSE 0.00 END AS [91-120],
	CASE RDDDBucket WHEN '121to180' THEN BalanceGBP ELSE 0.00 END AS [121-180],
	CASE RDDDBucket WHEN '181to365' THEN BalanceGBP ELSE 0.00 END AS [181-365],
	CASE RDDDBucket WHEN '365Plus'	THEN BalanceGBP ELSE 0.00 END AS [365+],
	CASE RDDDBucket 
		WHEN 'Current'	THEN 'Current'
		WHEN '0to30'	THEN '0-30'
		WHEN '31to60'	THEN '31-60'
		WHEN '61to90'	THEN '61-90'
		WHEN '91to120'	THEN '91-120'
		WHEN '121to180' THEN '121-180'
		WHEN '181to365' THEN '181-365'
		WHEN '365Plus'	THEN '365+'
	ELSE 'N/A' END AS 'Debt Age Group',
	CASE RDDDBucket 
		WHEN 'Current'	THEN 1
		WHEN '0to30'	THEN 2
		WHEN '31to60'	THEN 3
		WHEN '61to90'	THEN 4
		WHEN '91to120'	THEN 5
		WHEN '121to180' THEN 6
		WHEN '181to365' THEN 7
		WHEN '365Plus'	THEN 8
	ELSE 10 END AS 'Debt Age Group Sort',
	CASE CUSTGROUP 
		WHEN 10 THEN 'Member'
		WHEN 20 THEN 'Non-Member'
		WHEN 30 THEN 'Firm'
		WHEN 40 THEN 'InterCompany'
	END AS [Customer Group],
	DATEDIFF(d, CAST(DUEDATE AS DATE), CAST(GETDATE() AS DATE)) AS 'Debt Age',
	CASE
		WHEN cteData.INVOICE IS NULL THEN 'Y' ELSE 'N' END AS 'Unallocated',
	ABS(BalanceGBP) AS 'Balance GBP (Abs)',
	CASE WHEN BalanceCUR = 0 THEN 'Y' ELSE 'N' END AS 'Invoice Type Settled'
FROM cteData
WHERE [GJ Exclusion] <> 'Y'
	--AND [TRANSDATE] >= DATETIMEFROMPARTS(YEAR(getdate())-2, 1, 1, 0, 0, 0,0) -- Updated by Raj on 2025-03-27 to just get last 2 years
