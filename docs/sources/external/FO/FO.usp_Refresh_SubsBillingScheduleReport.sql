CREATE   PROCEDURE    [FO].[usp_Refresh_SubsBillingScheduleReport]
AS
BEGIN
	DROP TABLE IF EXISTS #custtrans	

	SELECT ACCOUNTNUM, INVOICE, MCRPAYMORDERID
	INTO #custtrans
	FROM synapse_fo.CUSTTRANS
	WHERE 
		(INVOICE like 'INV-%' OR INVOICE like 'CRE-%')
		AND MCRPAYMORDERID IS NOT NULL
	GROUP BY ACCOUNTNUM,INVOICE, MCRPAYMORDERID

	DROP TABLE IF EXISTS #recogaccount

	SELECT RECID, DISPLAYVALUE, MAINACCOUNTVALUE
	INTO #recogaccount
	FROM [synapse_fo].[dimensionattributevaluecombination]



	-- Truncate target table
	TRUNCATE TABLE [FO].[tblSubsBillingScheduleReport]

	-- Insert new data into the target

	INSERT INTO [FO].[tblSubsBillingScheduleReport]
	(
		[recid],
		[recognition reference],
		[creation source],
		[transaction type],
		[processed],
		[voucher],
		[sales order],
--		[account number],
		[schedule status],
		[schedule type],
		[distribution type],
		[line number],
		[subbilldeferralstubbed],
		[customer account],
		[invoice],
		[invoice date],
		[amount in transaction currency],
		[revenue schedule],
		[Deferral Original Start Date],
		[Deferral Original End Date],
		[Deferral Start Date],
		[Deferral End Date],
		[total recognisable amount],
		[Recognised],
		[remaining amount],
		[quantity to release],
		[journal number],
		[ledger voucher],
		[Recognition Date],
		[Recognised Amount],
		[AMOUNTCURCREDIT],
		[AMOUNTCURDEBIT],
		[ledger account],
		[recognition ledger account],
		[recognition account],
		[description],
		[currency],
		[costcenter],
		[campaignyear],
		[country],
		[productcode],
		[productgroup],
		[mainaccount],
		[project],
		[item name]
	)


	SELECT 

		rc.[recid], 
		st.[subbilldeferralschedulenumber] as [recognition reference],
		crsrc.[Description] as [creation source],
		trtype.[Description] as [transaction type],
		rc.[subbilldeferralrecognized] as [processed],
		CAST(ljt.[voucher] AS NVARCHAR(255)) as [voucher],
		ISNULL(st.[salesid], ct.[MCRPAYMORDERID]) as [sales order],
		schstatus.[Description] as [schedule status],
		schtype.[Description] as [schedule type],
		disttype.[Description] as [distribution type],
		rc.[line] as [line number],
		rc.[subbilldeferralstubbed],
		ISNULL(st.[CustInvoiceAccount], ct.[ACCOUNTNUM]) as [customer account],
		ISNULL(st.[InvoiceId], ct.[INVOICE]) as [invoice],
		st.[transdate] as [invoice date],
		IIF(st.SubBillDeferralRecognitionType = 1, rc.[amount]*-1, rc.[amount]) as [amount in transaction currency],
		--rc.[amount] as [amount in transaction currency],
		st.[description] as [revenue schedule],
		st.[SubBillDeferralOriginalStartDate] as [Deferral Original Start Date],
		st.[SubBillDeferralOriginalEndDate] as [Deferral Original End Date],
		rc.[SubBillDeferralStartDate] AS [Deferral Start Date],
		rc.[SubBillDeferralEndDate] as [Deferral End Date],
		--rc.[amount] as [total recognisable amount],
		IIF(st.SubBillDeferralRecognitionType = 1, rc.[amount]*-1, rc.[amount]) as [total recognisable amount],
		IIF(ljt.[transdate] IS NULL, 'No', 'Yes') AS [Recognised],

		ljt.[remainamount] as [remaining amount],
		rc.[subbilldeferralqty] as [quantity to release],
		ljt.[journalnum] [journal number],
		ljt.[voucher] as [ledger voucher],
		ljt.[TRANSDATE] AS [Recognition Date],
		IIF(ljt.[AmountCurCredit] <> 0, ljt.[AmountCurCredit], ljt.[AmountCurDebit]*-1) AS [Recognised Amount],
	
		ljt.AMOUNTCURCREDIT, ljt.AMOUNTCURDEBIT,

		davc.[displayvalue] as [ledger account],
		recogacct.[displayvalue] as [recognition ledger account],
		recogacct.[MAINACCOUNTVALUE] AS [recognition account],
		ljt.[txt] as [description],
		ljt.[currencycode] as [currency],
		davc.[costcentervalue] as [costcenter],
		davc.[campaignyearvalue] as [campaignyear],
		davc.[countryvalue] as [country],
		davc.[productcodevalue] as [productcode],
		davc.[productgroupvalue] as [productgroup],
		davc.[mainaccountvalue] as [mainaccount],
		davc.[PROJECTVALUE] as [project],
		prd.[Product_Name] AS [item name]
/*
		,CASE
			WHEN MAC.ACCOUNTCATEGORY = 'AAAA' AND (davc.[productcodevalue] IS NULL OR davc.[productcodevalue] NOT IN ('RAFEE_ACAND', 'RAFEE_APCC','RAFEE_ASSOC','RAFEE_FRICS','RAFEE_MRICS','RAFEE_PMU2')) THEN 10001 --Subscription Income
			WHEN MAC.ACCOUNTCATEGORY = 'AAAB' THEN 10002 --Elections & Enrolments
			WHEN MAC.ACCOUNTCATEGORY = 'AAAC' AND davc.[costcentervalue] NOT IN (6010, 6020) THEN 10003 --Commercial Income
			WHEN MAC.ACCOUNTCATEGORY = 'AAAR' THEN 10004 --Regulation Income
			WHEN MAC.ACCOUNTCATEGORY = 'AAAA' AND davc.[productcodevalue] IN ('RAFEE_ACAND', 'RAFEE_APCC','RAFEE_ASSOC','RAFEE_FRICS','RAFEE_MRICS','RAFEE_PMU2') then 10005 --Readmission Fees
			WHEN MAC.ACCOUNTCATEGORY = 'AAAS' AND ma.MAINACCOUNTID = 000000 THEN 10001 --Surcharges is removed and moved to Subscriptions (2025-01-08 16:30)
			WHEN MAC.ACCOUNTCATEGORY = 'AAAC' AND davc.[costcentervalue] IN (6010, 6020) THEN 10007 --SBE Income
			WHEN MAC.ACCOUNTCATEGORY = 'CA' AND (davc.[costcentervalue] NOT BETWEEN 4000 AND 4370) AND (davc.[costcentervalue] NOT BETWEEN 4410 AND 4430) AND (davc.[costcentervalue] NOT BETWEEN 4510 AND 4520) THEN 10101 --Commercial (CoS)
			WHEN MAC.ACCOUNTCATEGORY = 'CA' AND davc.[costcentervalue] BETWEEN 4410 AND 4430 THEN 10102 --Elections & Enrolments (CoS)
			WHEN MAC.ACCOUNTCATEGORY = 'CA' AND ((davc.[costcentervalue] BETWEEN 4000 AND 4370) OR (davc.[costcentervalue] BETWEEN 4510 AND 4520)) THEN 10103 --Standards & Regulation
			WHEN MAC.ACCOUNTCATEGORY = 'CC' THEN 10104 --Credit Cards
			WHEN MAC.ACCOUNTCATEGORY = 'CBD' THEN 10105 --Bad Debt Provision
			WHEN MAC.ACCOUNTCATEGORY = 'DPC' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10201 --Payroll Cost
			WHEN MAC.ACCOUNTCATEGORY = 'DTC' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10202 --Temps/Contractors
			WHEN MAC.ACCOUNTCATEGORY = 'DOTB' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10203 --Staff Travel & Team Building
			WHEN MAC.ACCOUNTCATEGORY = 'DOEI' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10204 --Staff Development/Wellbeing
			WHEN (MAC.ACCOUNTCATEGORY = 'DXFE' AND davc.[PROJECTVALUE] IS NULL) OR (MAC.ACCOUNTCATEGORY = 'DXFE' AND davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%') THEN 10205 --Bonus Provision 
			WHEN MAC.ACCOUNTCATEGORY = 'DORE' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) AND ma.MAINACCOUNTID <> 000000 THEN 10206 --Recruitment Costs
			WHEN MAC.ACCOUNTCATEGORY = 'DORE' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) AND ma.MAINACCOUNTID = 000000 THEN 10404 --Governance Consultancy
			WHEN MAC.ACCOUNTCATEGORY = 'DOEP' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10301 --IT Costs
			WHEN MAC.ACCOUNTCATEGORY = 'DOER' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10302 --Office & Property Costs
			WHEN MAC.ACCOUNTCATEGORY = 'DOEO' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE]	   LIKE 'FAP%')) THEN 10303 --Insurance
			WHEN MAC.ACCOUNTCATEGORY = 'DOED' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10304 --Professional / Consultancy Fees
			WHEN MAC.ACCOUNTCATEGORY = 'DOEM' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10305 --Marketing
			WHEN MAC.ACCOUNTCATEGORY = 'DOEL' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10306 --Corporate Subscriptions
			WHEN MAC.ACCOUNTCATEGORY = 'DOEQ' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10307 --Legal Fees
			WHEN MAC.ACCOUNTCATEGORY = 'DOET' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10308 --Audit, Tax & Financial Compliance
			WHEN MAC.ACCOUNTCATEGORY = 'DOEG' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10309 --Research
			WHEN MAC.ACCOUNTCATEGORY = 'DOEH' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10310 --Sponsorship
			WHEN MAC.ACCOUNTCATEGORY = 'DOEK' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10311 --Catering
			WHEN MAC.ACCOUNTCATEGORY = 'DOEC' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10312 --Other Costs
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND ma.MAINACCOUNTID  <> 000000 AND ma.MAINACCOUNTID  <> 000000 AND (davc.[PROJECTVALUE] IS NULL OR davc.[PROJECTVALUE] LIKE 'PRJ%' OR davc.[PROJECTVALUE] LIKE 'FAP%' OR (ma.MAINACCOUNTID = 000000 AND davc.[PROJECTVALUE] <> 'PRJ050')) AND davc.[PROJECTVALUE] NOT IN ('PRJ006','PRJ130','PRJ110', 'PRJ146', 'PRJ147', 'PRJ143', 'PRJ144', 'PRJ149', 'PRJ133', 'PRJ152', 'PRJ154', 'PRJ155', 'PRJ156', 'PRJ157', 'PRJ158', 'PRJ0000', 'PRJ160', 'PRJ161', 'PRJ089', 'PRJ163', 'PRJ165', 'PRJ173', 'PRJ174', 'PRJ175', 'PRJ176', 'PRJ177', 'PRJ178', 'PRJ179', 'PRJ180', 'PRJ181', 'PRJ182', 'PRJ183', 'PRJ167', 'PRJ191', 'PRJ192', 'PRJ193', 'PRJ194', 'PRJ195', 'PRJ170', 'PRJ023', 'PRJ196', 'PRJ197', 'PRJ198', 'PRJ199', 'PRJ200', 'PRJ201') THEN 10501 --davc.[PROJECTVALUE]s
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND ma.MAINACCOUNTID  <> 000000 AND ma.MAINACCOUNTID  <> 000000 AND davc.[PROJECTVALUE] IN ('PRJ163', 'PRJ165', 'PRJ173', 'PRJ174', 'PRJ175', 'PRJ176', 'PRJ177', 'PRJ178', 'PRJ179', 'PRJ180', 'PRJ181', 'PRJ182', 'PRJ183', 'PRJ167', 'PRJ191', 'PRJ192', 'PRJ193', 'PRJ194', 'PRJ195', 'PRJ023', 'PRJ170', 'PRJ196', 'PRJ197', 'PRJ198', 'PRJ199', 'PRJ200', 'PRJ201') THEN 10717 --Strategic Investments , Other davc.[PROJECTVALUE]s
			WHEN (MAC.ACCOUNTCATEGORY = 'DWRB' OR (MAC.ACCOUNTCATEGORY = 'DOMC' AND (davc.[costcentervalue] BETWEEN 1000 AND 1150 OR davc.[costcentervalue] BETWEEN 1310 AND 1380 OR davc.[costcentervalue] BETWEEN 1600 AND 1720))) THEN 10313 --WRB Engagement
			WHEN MAC.ACCOUNTCATEGORY = 'DXFC' AND (davc.[PROJECTVALUE] IS NULL OR davc.[PROJECTVALUE] NOT IN ('PRJ006','PRJ050','PRJ144','PRJ151')) THEN 10314 --Depreciation & Amortisation
			WHEN MAC.ACCOUNTCATEGORY = 'DXFC' AND davc.[PROJECTVALUE] IN ('PRJ006','PRJ050','PRJ144','PRJ151') THEN 10702 --Strategic Depreciation 
			WHEN MAC.ACCOUNTCATEGORY = 'DOEN' THEN 10315 --IFMA Service Fee
			WHEN MAC.ACCOUNTCATEGORY = 'DOMC' AND NOT (davc.[costcentervalue] BETWEEN 1000 AND 1150 OR davc.[costcentervalue] BETWEEN 1310 AND 1380 OR davc.[costcentervalue] BETWEEN 1600 AND 1720) 
			  AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10401 --Member Costs

			WHEN MAC.ACCOUNTCATEGORY = 'DOEA' AND ma.MAINACCOUNTID = 000000 THEN 10316 --Events, Raj Maddala, 2025-01-08 16:30 new category
			WHEN MAC.ACCOUNTCATEGORY = 'DOEA' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%') AND ma.MAINACCOUNTID <> 000000) THEN 10402 --External Conferences, Raj Maddala, 2025-01-08 16:30 excluded MAINACCOUNTID = 000000
			WHEN ma.MAINACCOUNTID = 000000 AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10403 --Non-Exec Fees
			WHEN MAC.ACCOUNTCATEGORY = 'DXFD' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10601 --Bank Charges
			WHEN MAC.ACCOUNTCATEGORY = 'DXFI' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10602 --Interest
			WHEN MAC.ACCOUNTCATEGORY = 'DXFL' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10603 --Taxation
			WHEN MAC.ACCOUNTCATEGORY = 'DXFX' THEN 10604 --FX Translation
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] IN ('PRJ006', 'PRJ144') THEN 10701 --D365 davc.[PROJECTVALUE]
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ143' THEN 10703 --Data Enablement
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ133' THEN 10704 --Business Process Management
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ149' THEN 10705 --Commercialisation
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ152' THEN 10707 --Market & Strategy
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ154' THEN 10708 --Customer Service Experience
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ156' THEN 10709 --Organisational Design
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ155' THEN 10710 --Pipeline Growth
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ157' THEN 10711 --Member Experience
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ158' THEN 10712 --Dynamic Working
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ159' THEN 10713 --Sustainability
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ160' THEN 10714 --Governance
			WHEN ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] = 'PRJ161' THEN 10715 --Transformation Delivery
			WHEN ((ma.MAINACCOUNTID = 000000 AND (davc.[PROJECTVALUE] IS NULL OR davc.[PROJECTVALUE] NOT LIKE 'PRJ%'))
				OR (ma.MAINACCOUNTID BETWEEN 000000 AND 000000 AND davc.[PROJECTVALUE] IN ('PRJ130', 'PRJ110', 'PRJ146', 'PRJ147', 'PRJ089')))THEN 10716 --Post Review Costs
			WHEN MAC.ACCOUNTCATEGORY = 'DXFK' AND (davc.[PROJECTVALUE] IS NULL OR (davc.[PROJECTVALUE] NOT LIKE 'PRJ%' AND davc.[PROJECTVALUE] NOT LIKE 'FAP%')) THEN 10706 --Other
			WHEN MAC.ACCOUNTCATEGORY = 'DXFN' THEN 10802 --Net Investments
			WHEN MAC.ACCOUNTCATEGORY = 'DXFH' THEN 10803 --(Profit)/Loss on disposal of Investments --ADRIAN IGNORE OTHER DXFH MAIN ACCOUNTS (000000, 000000, 000000) FROM NET INVESTMENTS
			WHEN MAC.ACCOUNTCATEGORY = 'DOIC' THEN 10804 -- Intercompany Recharges--NEWLINE
			WHEN MAC.ACCOUNTCATEGORY = 'FAFA' THEN 20001 --Intangible Assets --NEWLINE
			WHEN MAC.ACCOUNTCATEGORY IN ('FAFPCO', 'FAFP') AND ma.MAINACCOUNTID <> 000000 THEN 20002 --Property, Plant & Equipment
			WHEN ma.MAINACCOUNTID = 000000 THEN 20003 --ROU Assets
			WHEN MAC.ACCOUNTCATEGORY = 'FAFS' THEN 20004 --Investments in Subsides & Assocs --NEWLINE
			WHEN ma.MAINACCOUNTID = 000000 THEN 20005 --Deferred Tax Asset
			WHEN MAC.ACCOUNTCATEGORY = 'LBPAOC' THEN 20006 --Pension Asset
			WHEN MAC.ACCOUNTCATEGORY = 'HCIN' THEN 20101 --Inventories
			WHEN MAC.ACCOUNTCATEGORY = 'FAFR' THEN 20102 --Available for Sale Investments
			WHEN MAC.ACCOUNTCATEGORY IN ('HCJRDB', 'HCJRAR', 'HCJRDPP') THEN 20103 --Trade & Other Recievables
			WHEN MAC.ACCOUNTCATEGORY = 'HCJX' THEN 20104 --Cash & Cash Equivalents
			WHEN MAC.ACCOUNTCATEGORY IN ('LBCT', 'LBCTVA') THEN 20201 --Current Tax Liabilities
			WHEN MAC.ACCOUNTCATEGORY IN ('LBAPAA', 'LBAPRL', 'LBPADF', 'LBPAAP', 'LBAPAP') AND ma.MAINACCOUNTID <> 000000 THEN 20202 --Trade & Other Payables
			WHEN ma.MAINACCOUNTID = 000000 THEN 20203 --ROU Liabilty
			WHEN MAC.ACCOUNTCATEGORY = 'JBDT' THEN 20301 --Deferred Tax
			WHEN MAC.ACCOUNTCATEGORY = 'JBPV' THEN 20302 --Provisions
			WHEN MAC.ACCOUNTCATEGORY = 'RVRSV' AND ma.MAINACCOUNTID <> 000000 THEN 20401 --Revaluation Reserves
			WHEN MAC.ACCOUNTCATEGORY = 'RVIN' THEN 20402 --Investment Reserves
			WHEN MAC.ACCOUNTCATEGORY = 'RVOT' THEN 20403 --Other Reserves
			WHEN ma.MAINACCOUNTID IN (000000, 000000)  THEN 20406-- Revenue Reserves
			WHEN MAC.ACCOUNTCATEGORY = 'AAAO' AND davc.[productcodevalue] NOT IN ('TDSGRANT','GEOSAASSESSMENT','GEOSAPROJINCEPTION','GEOSAWPONE','GEOSAWPTHREE','GEOSAWPTWO','GEOSAWPFOUR','GEOSAWPFIVE') THEN 10008 --GGS Restaurant Income
			WHEN MAC.ACCOUNTCATEGORY = 'AAAO' AND davc.[productcodevalue] IN ('TDSGRANT','GEOSAASSESSMENT','GEOSAPROJINCEPTION','GEOSAWPONE','GEOSAWPTHREE','GEOSAWPTWO','GEOSAWPFOUR','GEOSAWPFIVE') THEN 10009 --Tenancy Deposit Scheme
		END AS [TB_Category_Code]
*/
	FROM [synapse_fo].[subbilldeferralscheduletable] st	
			LEFT JOIN [synapse_fo].[subbilldeferralscheduleline] rc
				ON st.[subbilldeferralschedulenumber] = rc.[subbilldeferralschedulenumber]
			LEFT JOIN [synapse_fo].[dimensionattributevaluecombination] davc
				ON st.subbilldeferralaccount = davc.recid

			LEFT JOIN #recogaccount recogacct
				ON st.[SubBillDeferralRecognitionAccount] = recogacct.[RECID]

			LEFT JOIN synapse_fo.ledgerjournaltrans ljt
				ON rc.recognitionledgerjournaltrans = ljt.recid
			LEFT JOIN [fo].[vwproduct] prd
				ON davc.[productcode] = prd.[recid]

			LEFT JOIN [synapse_fo].[vwSubBillDeferralScheduleCreationSource] crsrc
				ON st.[SubBillDeferralScheduleCreationSource] = crsrc.[SubBillDeferralScheduleCreationSource]
			LEFT JOIN [synapse_fo].[vwSubBillDeferralTransactionType] trtype
				ON st.[SubBillDeferralTransactionType] = trtype.[SubBillDeferralTransactionType]

			LEFT JOIN [synapse_fo].[vwSubBillDeferralScheduleStatus] schstatus
				ON st.[SubBillDeferralScheduleStatus] = schstatus.[SubBillDeferralScheduleStatus]
			LEFT JOIN [synapse_fo].[vwSubBillDeferralDistributionType] disttype
				ON st.[SubBillDeferralDistributionType] = disttype.[SubBillDeferralDistributionType]
			LEFT JOIN [synapse_fo].[vwSubBillDeferralScheduleType] schtype
				ON st.[SubBillDeferralScheduleType] = schtype.[SubBillDeferralScheduleType]

			LEFT JOIN #custtrans ct
				ON IIF(st.SubBillDeferralScheduleNumber LIKE 'INV%' OR st.SubBillDeferralScheduleNumber LIKE 'CRE%', SUBSTRING(st.SubBillDeferralScheduleNumber, 1, CHARINDEX('-', st.SubBillDeferralScheduleNumber, 5)-1), st.invoiceid) = ct.[INVOICE]

END
