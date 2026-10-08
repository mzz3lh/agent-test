CREATE   VIEW [FO].[vwSubAgedDebt] AS 

WITH
CTEAPP AS (
	SELECT
	rics_contactno
	,MIN(rics_enrolmentdate) AS FirstEnrolmentDate
	FROM [CE].[vwApplications]
	GROUP BY rics_contactno
	),

ADCTE AS (
	SELECT
		 [AX Account No] AS 'rics_contactno_ad'
		,[Currency]
		,AG.[INVOICE]
		,AG.[VOUCHER]
		,[Invoice Type]
		,[TotalDebtStatus]
		,PAYMMODE AS 'Payment Method'
		,[CRMPaymentCycle] AS 'Payment Cycle'
		,AG.[DUEDATE] AS 'Due Date'
		,AG.[TRANSDATE] AS 'Invoice Date'
		,[BalanceGBP]
		,[BalanceCUR]
		,AG.[SETTLEAMOUNTMST]
		,AG.[SETTLEAMOUNTCUR]
		--,CT.CustTrans_AmountCur AS 'Total Invoice Amount CUR'
		--,CT.CustTrans_AmountMst AS 'Total Invoice Amount MST'
		,[Debt Age Group]
		,[Debt Age Group Sort]
		,[Customer Group]
		,[Debt Age]
	FROM [FinBI].[vwD365CommercialAndNonCommercialAgedDebt_v2] AG
	--LEFT JOIN FO.tblCustTrans CT ON AG.INVOICE = CT.INVOICE
	WHERE 1=1
		--AND [AX Account No] = 0000000
		AND [Customer Group] IN ('Member','Non-Member')
		AND [Invoice Type] = 'SUB'
		AND BalanceCUR <> 0
	),

CTINVTOT AS (
	SELECT
		INVOICE
		,SUM(AMOUNTCUR) AS AMOUNTCUR
		,SUM(AMOUNTMST) AS AMOUNTMST
	FROM [synapse_fo].[CUSTTRANS_RICS]
	GROUP BY INVOICE
	)

SELECT
	 CON.Rics_contactno
	,CON.FirstName
	,CON.LastName
	,CON.Telephone1
	,CON.EMailAddress1
	,CON.Rics_PaymentCycle_Description AS 'Expected Payment Cycle'
	,CON.Rics_PaymentMethod_Description AS 'Expected Payment Method'
	,CON.Rics_LapsedDate
	,CON.Rics_Donotchase_Description
	,CON.MemberGrade_Description
	,CON.apuk_designation_description
	,CON.rics_localgroupid
	,CON.StateCode_Description
	,CAST(CON.Rics_ElectionDate AS DATE) AS 'Election Date'
	,CASE WHEN MONTH(CON.Rics_ElectionDate) IN (10, 11, 12) THEN YEAR(CON.Rics_ElectionDate)+1 ELSE YEAR(CON.Rics_ElectionDate) END AS ElectionYear
	,CAST(APP.FirstEnrolmentDate AS DATE) AS 'First Enrolment Date'
	,CASE WHEN MONTH(APP.FirstEnrolmentDate) IN (10, 11, 12) THEN YEAR(APP.FirstEnrolmentDate)+1 ELSE YEAR(APP.FirstEnrolmentDate) END AS EnrolmentYear
	,AD.*
	,CTI.AMOUNTCUR AS InvoiceTotalCUR
	,CTI.AMOUNTMST AS InvoiceTotalMST

FROM synapse_ce.tblContact_BI CON
	LEFT JOIN CTEAPP AS APP 
		ON CON.Rics_contactno = APP.rics_contactno
	INNER JOIN ADCTE AS AD 
		ON CON.Rics_contactno = AD.rics_contactno_ad
	LEFT JOIN  CTINVTOT AS CTI 
		ON CTI.INVOICE = AD.INVOICE

WHERE 1=1
	AND CON.Rics_LapsedDate IS NULL
	AND CON.Rics_Donotchase_Description IS NULL
	AND (CON.Rics_ElectionDate IS NULL OR CASE WHEN MONTH(CON.Rics_ElectionDate) IN (10, 11, 12) THEN YEAR(CON.Rics_ElectionDate)+1 ELSE YEAR(CON.Rics_ElectionDate) END < CASE WHEN MONTH(GETDATE()) IN (10, 11, 12) THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END)
	AND (APP.FirstEnrolmentDate IS NULL OR CASE WHEN MONTH(APP.FirstEnrolmentDate) IN (10, 11, 12) THEN YEAR(APP.FirstEnrolmentDate)+1 ELSE YEAR(APP.FirstEnrolmentDate) END <  CASE WHEN MONTH(GETDATE()) IN (10, 11, 12) THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END)
--These two filter out anyone who was enrolled or elected in current Campaign Year
