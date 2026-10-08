/****************************************************************************
vwCommercialAndNonCommercialAgedDebt

*********************************************************************************/
CREATE      VIEW [FinBI].[vwD365CommercialAndNonCommercialAgedDebt]
AS

WITH cteData
AS
(
	SELECT AD.ACCOUNTNUM AS [AX Account No],
		ContactNo AS [CRM Contact No],
		--RICCUSTINTERFACEREF   -Replaced this with ContactNo above , most not correct using RICCUSTINTERFACEREF
		RDDDBucket, --here as a check
		BalanceGBP,--here as a check
		BalanceCUR,
		Currency,
		CRMParentAccount AS [CRM Parent Accoiunt],
		CRMParentAccountFirmNo AS [CRM PA Firm No],
		CRMParentAccountOfficeNo AS [CRM PA Office No],
		CASE CUSTGROUP 
			WHEN 10 THEN 'Member'
			WHEN 20 THEN 'Non-Member'
			WHEN 30 THEN 'Firm'
			WHEN 40 THEN 'InterCompany'
		END AS [Customer Group],
		ContactNo AS [Source AccountID],  --What??
		SubsYear AS [External Invoice Ref],
		CUST_NAME AS [Customer Name],
		INVOICE,
		VOUCHER,
		DUEDATE AS [Due Date],
		InvType AS [Invoice Type],
		--LineAmountCUR,
		--LineAmountMST,
		CostCentre,
		NULL AS [Cost Centre Description], --D.[Description] AS [Cost Centre Description],
		NULL AS [Subs Year], --SubsYear As [Subs Year],
		AD.CREATEDDATETIME AS [Created Date Time], --CREATEDDATETIME AS [Created Date Time],
		AD.CREATEDBY AS [Created By], --CREATEDBY AS [Created By],
		CASE RDDDBucket
			WHEN 'Current' THEN BalanceGBP
			ELSE 0.00
		END AS [Current],
		CASE RDDDBucket
			WHEN '0to30' THEN BalanceGBP
			ELSE 0.00
		END AS [0to30],
		CASE RDDDBucket
			WHEN '31to60' THEN BalanceGBP
			ELSE 0.00
		END AS [31to60],
		CASE RDDDBucket
			WHEN '61to90' THEN BalanceGBP
			ELSE 0.00
		END AS [61to90],
		CASE RDDDBucket
			WHEN '91to120' THEN BalanceGBP
			ELSE 0.00
		END AS [91to120],
		CASE RDDDBucket
			WHEN '121to180' THEN BalanceGBP
			ELSE 0.00
		END AS [121to180],
		CASE RDDDBucket
			WHEN '181to365' THEN BalanceGBP
			ELSE 0.00
		END AS [181to365],
		CASE RDDDBucket
			WHEN '365Plus' THEN BalanceGBP
			ELSE 0.00
		END AS [365Plus],
		0.00 AS Unallocated,
		AD.DATAAREAID,
		[RefreshDateTime],
		TotalDebtStatus,
		AccountId,
		[ONHOLDSTATUS],
		[ONHOLDSTATUS_Description],
		CRMPaymentCycle,
		DUEDATE,
		TRANSDATE,
		DATEDIFF(d, CAST(DUEDATE AS DATE), CAST(GETDATE() AS DATE)) AS 'Debt Age',
		[Cost Centre],
		[Main Account],
		[Cost Code Voucher],
		SETTLEAMOUNTMST,
		SETTLEAMOUNTCUR
	FROM FO.tblFOAgedDebt	AD
	--Raj Maddala, 2022-01-26, Removed the join tables because it is causing big performance issues and the PBI refresh failing with timeout.
	-- Join table fields are added to the table and updated corresponding refresh stored procedure
--		LEFT JOIN (SELECT [ACCOUNTNUM], [NAME], [CUSTGROUP], [ONHOLDSTATUS], [ONHOLDSTATUS_Description] FROM FO.vwCUSTTABLE) ct
--			ON ct.ACCOUNTNUM = AD.ACCOUNTNUM
--		LEFT JOIN (SELECT [AccountId], [AccountNumber] FROM CE.vwAccount) acc
--			ON ct.AccountNum = acc.AccountNumber
	WHERE AD.ACCOUNTNUM NOT LIKE 'ISL%'
)
--Raj, 2022-01-24, DISTINCT * removing actual invoice lines. So, DISTINCT is removed
SELECT * ,[Current] + [0to30] +[31to60] +[61to90]+[91to120]+[121to180]+[181to365]+[365Plus] AS Total
FROM cteData
WHERE 1=1
AND TotalDebtStatus <> 'Zero Balance' --Added in to only get those invoices with a non zero balance
