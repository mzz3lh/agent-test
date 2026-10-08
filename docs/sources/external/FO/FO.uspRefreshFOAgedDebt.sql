--ALTER TABLE FO.tblFOAgedDebt ADD BalanceGBP_Asoff [numeric](34, 6)

CREATE     PROCEDURE [FO].[uspRefreshFOAgedDebt]
AS

BEGIN

	/*
		Raj Maddala
		2023-05-25
		Included CustTable fields and Account fields in the main table
	*/

	TRUNCATE TABLE FO.tblFOAgedDebt

	INSERT INTO FO.tblFOAgedDebt
	(
		ContactNo,
		 ACCOUNTNUM,
		 CRMParentAccount,
		 CRMParentAccountFirmNo,
		 CRMParentAccountOfficeNo,
		 NAME,
		 RICCUSTINTERFACEREF,
		 CPCompany,
		 Salutation,
		 WorldRegion,
		 ReportingWorldRegion,
		 ReportingSubWorldRegion,
		 LocalGroup,
		 ReportingLocalGroup,
		 Country,
		 PreferredEMail,
		 DoNotChase,
		 MailName,
		 MobilePhone,
		 LapsedCode,
		 MemberGrade,
		 ConcessionType,
		 Region,
		 ReportingRegion,
		 PreventLapse,
		 AXPaymentSchedule,
		 CRMPaymentCycle,
		 TRANSDATE,
		 DUEDATE,
		 INVOICE,
		 VOUCHER,
		 CURRENCY,
		 CTAMOUNTCUR,
		 SETTLEAMOUNTCUR,
		 LineAmountCUR,
		 CTAMOUNTMST,
		 SETTLEAMOUNTMST,
		 SETTLEAMOUNTMST_Adj,
		 LineAmountMST,
		 EXCHADJUSTMENT,
		 BalanceCUR,
		 BalanceGBP,
		 RDDDBucket,
		 RDTDBucket,
		 RMDDBucket,
		 RMTDBucket,
		 InvType,
		 PAYMMODE,
		 TXT,
		 HITINTSYSTEMID,
		 DaysSinceInvoiced,
		 RefreshDateTime,
		 CostCentre,
		 RevenueStream,
		 ProductCode,
		 SubsYear,
		 PendingRemoval,
		 PendingRemovalDate,
		 Renewals,
		 Fulfilled,
		 LYCPDComplete,
		 LYCompletedFormalHours,
		 CPDComplete,
		 CompletedFormalHours,
		 [Payment Method],
		 RICRECALREFERENCE,
		 DATAAREAID,
		 CREATEDDATETIME,
		 CREATEDBY,
		 Rics_HardcopySubs,
		 Pathway,
		 [Address Line1],
		 [Address Line2],
		 [Address Line3],
		 [City],
		 [County],
		 [Postal Code],
		 [Closed],
		 [Voucher_Rank],
		[CUST_NAME], 
		[CUSTGROUP], 
		[ONHOLDSTATUS], 
		[ONHOLDSTATUS_Description],
		[AccountId], 
		[AccountNumber],
		[Cost Centre],
		[Main Account],
		[Cost Code Voucher],
		InvType_Rank,
		[TRANSTYPE],
		[BalanceGBP_Asoff]
	)

	  SELECT 
						   CN.Rics_ContactNo AS ContactNo,
						   CT.ACCOUNTNUM,
						   CN.AccountIDName AS CRMParentAccount,
						   A.apuk_firmnumber AS CRMParentAccountFirmNo,
						   A.apuk_officenumber AS CRMParentAccountOfficeNo,
						   C.NAME,
						   NULL AS RICCUSTINTERFACEREF,  --Not in FinOps
						   NULL AS CPCompany,  --CN.rics_corporateSchemeNameIdName AS CPCompany,
						   CN.Salutation AS Salutation,
						   RG.Rics_WorldRegion AS WorldRegion,
						   NULL AS ReportingWorldRegion,  --RG.Ricsv2_ReportingWorldRegionIdName AS ReportingWorldRegion,
						   RG.Rics_ReportingSubWorldRegion AS ReportingSubWorldRegion,
						  CN.rics_LocalGroupIDName AS LocalGroup,
						   RG.Rics_ReportingLocalGroup AS ReportingLocalGroup,
						   CN.rics_Corespadd_country AS Country,
						   ISNULL(CN.EMailAddress1, '') AS PreferredEMail,
						   CN.Rics_Donotchase_Description AS DoNotChase, --SM5.Value AS DoNotChase,
						   CN.rics_MailName AS MailName,
						   CN.MobilePhone,
						   CN.Rics_LapsedCode_Description AS LapsedCode, --SM.Value AS LapsedCode,
						   CN.MemberGrade_Description AS MemberGrade, --SM2.Value AS MemberGrade,
						   CN.Rics_ConcessionCode_Descritpion AS ConcessionType, --SM3.Value AS ConcessionType,  --now has multiple concession types see RAJ
						   CN.Rics_Region AS Region,
						   NULL AS ReportingRegion,  --RG.Rics_ReportingRegionIDName AS ReportingRegion,
						   CASE CN.rics_PreventLapse
							   WHEN 0
							   THEN 'No'
							   WHEN 1
							   THEN 'Yes'
							   ELSE 'No'
						   END AS PreventLapse,
						   '' AS AXPaymentSchedule,
						   COALESCE(CN.Rics_PaymentCycle_Description, 'Not Specified') AS CRMPaymentCycle,
						   CT.TRANSDATE,
						   DUEDATE,
						   ISNULL(INVOICE,'') AS INVOICE,
						   CT.VOUCHER,
						   CT.CURRENCYCODE AS Currency,
						   CT.CustTrans_AmountCur,--CT.AMOUNTCUR,
						   SETTLEAMOUNTCUR,
						   CT.AMOUNTCUR,
						   CT.CustTrans_AmountMst,--CT.AMOUNTMST,
						   SETTLEAMOUNTMST,
						   SETTLEAMOUNTMST_Adj,
						   CT.AMOUNTMST,
						   ct.EXCHADJUSTMENT,
						   0.00 AS BalanceCUR,--CT.AMOUNTCUR - SETTLEAMOUNTCUR AS BalanceCUR,
						   0.00 AS BalanceGBP, --CT.AMOUNTMST - (SETTLEAMOUNTMST - EXCHADJUSTMENT) AS BalanceGBP,
						   '' AS RDDDBucket,
						   '' AS RDTDBucket,
						   '' AS RMDDBucket,
						   '' AS RMTDBucket,
						   CASE RICINVOICETYPE_with_Tax
							   WHEN ''
							   THEN 'Not Specified'
							   ELSE RICINVOICETYPE_with_Tax
						   END AS 'InvType',
						   CASE 
							   WHEN CT.PAYMMODE IS NULL OR CT.PAYMMODE = '' THEN 'Not Specified'
							   ELSE CT.PAYMMODE
						   END AS PAYMMODE,
						   ISNULL(CT.TXT, ''),
						   NULL AS HITINTSYSTEMID,  --not in FO
						   DATEDIFF(DAY, CT.TRANSDATE, GETDATE()) AS DaysSinceInvoiced,
						   GETDATE() AS RefreshDateTime,
						   NULL AS CostCentre,  --DIMENSION AS CostCentre, NOT IN FO
						   NULL AS RevenueStream,  --CT.DIMENSION2_ AS RevenueStream, NOT IN FO
						   CT.ProductCode AS ProductCode,  --CT.Dimension3_ AS ProductCode, NOT In FO
						   NULL AS SubsYear,  --CT.[RICEXTERNALINVOICEREF] AS SubsYear, Not In FO
						   ISNULL(CN.Rics_PendingRemoval, '') AS PendingRemoval,
						   ISNULL(CN.Rics_PendingRemovalDate, '') AS PendingRemovalDate,
						   ISNULL(CN.rics_renewals, 0) AS Renewals,
						   '' AS Fulfilled,
						   NULL AS LYCPDComplete,
						   0.00 AS LYCompletedFormalHours,
						   NULL AS CPDComplete,
						   0.00 AS CompletedFormalHours,
						   CN.Rics_PaymentMethod_Description AS [Payment Method], --SM4.value AS [Payment Method],
						   NULL AS RICRECALREFERENCE,  --Not IN FO
						   CT.DATAAREAID,
						   CT.CreatedDateTimeCust AS CREATEDDATETIME,  --not in FO
						   CT.CreatedByCust AS CREATEDBY, --not in FO
						   CN.Rics_HardcopySubs,  --Added 12/08/2019 Request Mandy Bradley.
						   RP.apuk_name AS Pathway,   --Added 29/04/2021 Request Marcey Baumber SD 000000
						   CN.address1_Line1 AS [Address Line1],
						   CN.Address1_Line2 AS [Address Line2],
						   CN.Address1_Line3 AS [Address Line3],
						   CN.Address1_City AS [City],
						   CN.Address1_County AS [County],
						   CN.Address1_PostalCode AS [Postal Code],
						   ct.[CLOSED],
						   0 AS Voucher_Rank,
							c.[Name] AS [CUST_NAME], 
							c.[CustGroup], 
							C.[ONHOLDSTATUS], 
							C.[ONHOLDSTATUS_Description],
							acc.[AccountId], 
							acc.[AccountNumber],
							CT.[CostCenter] AS 'Cost Centre',
							CT.[MainAccount] AS 'Main Account',
							CT.[ACCOUNTDISPLAYVALUE] AS 'Cost Code Voucher',
							CASE 
								WHEN RICINVOICETYPE_with_Tax = 'LHL' THEN 1
								WHEN RICINVOICETYPE_with_Tax = 'SUR' THEN 2
								WHEN RICINVOICETYPE_with_Tax = 'SUB' THEN 4
								ELSE 3 END AS InvType_Rank,
							CT.TRANSTYPE
							,SUM(CT.[AMOUNTMST]) OVER(PARTITION BY CT.ACCOUNTNUM ORDER BY CT.TRANSDATE) AS [BalanceGBP_Asoff]

	FROM [synapse_fo].[CUSTTRANS_RICS] CT
						 LEFT JOIN FO.vwCUSTTABLE C ON CT.ACCOUNTNUM = c.ACCOUNTNUM
																   AND CT.DATAAREAID = C.DATAAREAID
						 LEFT JOIN synapse_ce.tblContact_BI CN ON CN.Rics_contactno  = CT.ACCOUNTNUM  --index on PBI04 idxAccountnum / index on PBI03 idxContactno
						 LEFT JOIN synapse_ce.Account A ON A.AccountID = CN.AccountID --index on PBI03 idxAccountId
						 LEFT JOIN synapse_ce.vwRicsGroup RG ON RG.rics_groupid = CN.Rics_LocalGroupID
						LEFT JOIN synapse_ce.apuk_pathway RP ON CN.rics_pathwaytomembershipid = RP.Id
						--LEFT JOIN synapse_ce.vwRics_Pathway RP ON CN.rics_pathwaytomembershipid = RP.rics_PathwayID
						LEFT JOIN synapse_ce.Account acc
							ON C.AccountNum = acc.AccountNumber
					--WHERE CT.AMOUNTCUR - SETTLEAMOUNTCUR <> 0 --AAB removed 24/03/22 as it removing settled lines from unsettled Vouchers with multiple lines
					--AND Invoice =  'INV-00000000'
	

	--Update Voucher_Rank. This is required to update the balance at voucher level but not at all lines
	UPDATE tgt SET tgt.Voucher_Rank = src.Voucher_Rank FROM FO.tblFOAgedDebt tgt
	INNER JOIN
	(
	SELECT AgedDebtId, ROW_NUMBER() OVER(PARTITION BY Voucher ORDER BY Voucher) AS Voucher_Rank
	FROM FO.tblFOAgedDebt
	) src
		ON tgt.AgedDebtId = src.AgedDebtId






	--UPDATE the balances
	SELECT ACCOUNTNUM,INVOICE,CURRENCY,VOUCHER,
					--(SUM(CTAmountCur) - SETTLEAMOUNTCUR)
					(SUM(CTAmountCur - SETTLEAMOUNTCUR))/COUNT(*) AS BalanceCUR  --Raj, 2021-09-29, Issue fixed when there are number of lines and no settleamount
			 INTO #BalanceCUR
			 FROM FO.tblFOAgedDebt
			 GROUP BY ACCOUNTNUM, INVOICE,SETTLEAMOUNTCUR,CURRENCY,VOUCHER


	--Raj, 2021-10-27, Update balance to LineAmout when SettleAmount is 0 and not closed
	UPDATE FO.tblFOAgedDebt
	SET BalanceCUR = LineAmountCUR, BalanceGBP = LineAmountMST+EXCHADJUSTMENT
	WHERE SETTLEAMOUNTCUR = 0
		AND DATEPART(YYYY, Closed) = 1900


	UPDATE FO.tblFOAgedDebt
	SET BalanceCUR = #BalanceCUR.BalanceCUR
	FROM #BalanceCUR 
	WHERE #BalanceCUR.VOUCHER = FO.tblFOAgedDebt.VOUCHER
		AND FO.tblFOAgedDebt.Voucher_Rank = 1
		AND ISNULL(FO.tblFOAgedDebt.BalanceCUR, 0) = 0 

	SELECT ACCOUNTNUM,INVOICE,CURRENCY,VOUCHER,
					--(SUM(CTAMOUNTMST) - SETTLEAMOUNTMST)
					(SUM(CTAMOUNTMST - (SETTLEAMOUNTMST-EXCHADJUSTMENT)))/COUNT(*) AS BalanceGBP --Raj, 2021-09-29, Issue fixed when there are number of lines and no settleamount
			 INTO #BalanceGBP
			 FROM FO.tblFOAgedDebt
			 GROUP BY ACCOUNTNUM, INVOICE,SETTLEAMOUNTMST,CURRENCY,VOUCHER


	UPDATE FO.tblFOAgedDebt
	SET BalanceGBP = #BalanceGBP.BalanceGBP
	FROM #BalanceGBP 
	WHERE #BalanceGBP.VOUCHER = FO.tblFOAgedDebt.VOUCHER
		AND FO.tblFOAgedDebt.Voucher_Rank = 1
		AND ISNULL(FO.tblFOAgedDebt.BalanceGBP, 0) = 0 --Raj, 2021-10-27, Only Update balance where it was not updated in the first run



	/*****************************************************************************
	--CHECK		
			--SELECT * FROM #BalanceCUR WHERE INVOICE = 'INV-00000000'
			 --SELECT * FROM #BalanceGBP WHERE INVOICE = 'INV-00000000'

			 --DROP TABLE #BalanceCUR
			 --DROP TABLE #BalanceGBP
	*******************************************************************************/

	--UPDATE the buckets

	--Current variable
			 DECLARE @today DATETIME;
			 SET @Today = CAST(GETDATE() AS DATE);

	--Current by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = 'Current'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE >= @Today;

	--Current by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = 'Current'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE >= @Today;

	--0to30 Variable
			 DECLARE @30 DATETIME;
			 SET @30 = CAST(GETDATE() - 30 AS DATE);

	--0 to 30 by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = '0to30'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE BETWEEN @30 AND @Today;

	--0 to 30 by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = '0to30'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE BETWEEN @30 AND @Today;

	--31to60 Variables
			 DECLARE @31 DATETIME;
			 SET @31 = CAST(GETDATE() - 31 AS DATE);
			 DECLARE @60 DATETIME;
			 SET @60 = CAST(GETDATE() - 60 AS DATE);

	--31 to 60 by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = '31to60'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE BETWEEN @60 AND @31;

	--31 to 60 by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = '31to60'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE BETWEEN @60 AND @31;


	--61to90 Variables
			 DECLARE @61 DATETIME;
			 SET @61 = CAST(GETDATE() - 61 AS DATE);
			 DECLARE @90 DATETIME;
			 SET @90 = CAST(GETDATE() - 90 AS DATE);

	--61 to 90 by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = '61to90'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE BETWEEN @90 AND @61;

	--61 to 90 by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = '61to90'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE BETWEEN @90 AND @61;


	--91to120 Variables
			 DECLARE @91 DATETIME;
			 SET @91 = CAST(GETDATE() - 91 AS DATE);
			 DECLARE @120 DATETIME;
			 SET @120 = CAST(GETDATE() - 120 AS DATE);

	--91 to 120 by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = '91to120'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE BETWEEN @120 AND @91;

	--91 to 120 by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = '91to120'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE BETWEEN @120 AND @91;

	--121to180 Variables
			 DECLARE @121 DATETIME;
			 SET @121 = CAST(GETDATE() - 121 AS DATE);
			 DECLARE @180 DATETIME;
			 SET @180 = CAST(GETDATE() - 180 AS DATE);

	--121 to 180 by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = '121to180'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE BETWEEN @180 AND @121;

	--121 to 180 by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = '121to180'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE BETWEEN @180 AND @121;


	--181to365 Variables
			 DECLARE @181 DATETIME;
			 SET @181 = CAST(GETDATE() - 181 AS DATE);
			 DECLARE @365 DATETIME;
			 SET @365 = CAST(GETDATE() - 365 AS DATE);

	--181 to 365 by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = '181to365'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE BETWEEN @365 AND @181;

	--181 to 365 by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = '181to365'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE BETWEEN @365 AND @181;


	--365+ by DUEDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDDDBucket = '365Plus'
			 FROM FO.tblFOAgedDebt
			 WHERE DUEDATE < @365;

	--365+ by TRANSDATE
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RDTDBucket = '365Plus'
			 FROM FO.tblFOAgedDebt
			 WHERE TRANSDATE < @365;


	--UPDATE the RMDDBucket and RMTDBucket
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RMDDBucket = DATENAME(month, DUEDATE) + CAST(DATEPART(yy, DUEDATE) AS VARCHAR(4))
			 FROM FO.tblFOAgedDebt;
			 UPDATE FO.tblFOAgedDebt
			   SET
				   RMTDBucket = DATENAME(month, TRANSDATE) + CAST(DATEPART(yy, TRANSDATE) AS VARCHAR(4))
			 FROM FO.tblFOAgedDebt;

	--Get rid of NULLS for reporting
			 UPDATE FO.tblFOAgedDebt
			   SET
				   DoNotChase = ''
			 WHERE DoNotChase IS NULL;

	/********************************TODO - NEEDS CUSTPAYMSCHED*************************************
	--Get the AXPaymentSchedule
			 SELECT AXS.Invoice,
					CPS.Name
			 INTO #PaySched
			 FROM FO.tblFOAgedDebt AXS
				  LEFT JOIN AX.vwCUSTINVOICEJOUR CIJ ON AXS.[Invoice] = CIJ.INVOICEID
				  LEFT JOIN AX.vwCUSTPAYMSCHED CPS ON CPS.EXTRECID = CIJ.RECID;
		--WHERE AXS.[Method of Payment] LIKE 'DD%'

	--UPDATE the staging table
			 UPDATE FO.tblFOAgedDebt
			   SET
				   AXPaymentSchedule = #.Name
			 FROM #PaySched #
			 WHERE #.Invoice = FO.tblFOAgedDebt.Invoice;
	***************************************************************************************************/

	/******************************TODO - GET SUBSFULFILLMENT FLAG*****************************

	--Update the Fulfilled field with the contactNo if they have fulfilled
			 UPDATE FO.tblFOAgedDebt
			   SET
				   Fulfilled = SF.ContactNo
			 FROM DBADB.dbo.SubsFulfilment SF
				  INNER JOIN FO.tblFOAgedDebt ST ON ST.ContactNo = SF.ContactNo
			 WHERE ST.ContactNo = SF.ContactNo;
	*****************************************************************************************************/


	--Update the CPD fields
	--Current Year
			 UPDATE FO.tblFOAgedDebt
			   SET
				   CPDComplete = CPD.[Rics_cpdcomplete], --[CPD Complete],
				   CompletedFormalHours = ISNULL(CPD.Rics_completedformalhrs, 0)
			 FROM CE.vwCPDAnnualSummary CPD
				  LEFT JOIN CE.vwContact CN ON CPD.rics_contactid = CN.ContactId
				  LEFT JOIN FO.tblFOAgedDebt ST ON CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
			 WHERE CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
				   AND CPD.Rics_CPDYear = DATEPART(yyyy, GETDATE());  --To Do - Verify that this needs to be the year prior to the current one. If so use DATEPART(yyyy,GETDATE())-1



	--Previous Year  --ADDED DBA/PS 04/01/2018
			 UPDATE FO.tblFOAgedDebt
			   SET
				   LYCPDComplete = CPD.[Rics_cpdcomplete],
				   LYCompletedFormalHours =  ISNULL(CPD.[Rics_completedformalhrs], 0)
			 FROM CE.vwCPDAnnualSummary CPD
				  LEFT JOIN CE.vwContact CN ON CPD.rics_contactid = CN.ContactId
				  LEFT JOIN FO.tblFOAgedDebt ST ON CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
			 WHERE CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
				   AND CPD.Rics_CPDYear = DATEPART(yyyy, GETDATE()) - 1;  
		


	-- Update the TotalDebtStatus field  --Added DBA/PS 06/08/2018 - this will show if the member is in debt,credit or has a zero TOTAL balance

	/*
		Modified by Raj
		Modified on: 2021-10-01
		Description: TotalDebtStatus need to be updated at Account level but not at voucher level
			#Status table grouped at Account, Invoice and Voucher level
			It is possible that one voucher for the account can be cleared and other voucher is part paid or none paid.
			So, Account can see balance 0 at cleared vouchers but balance at part paid vouchers.
			Original update statements are written to update at account level. So, balance in any voucher for an account is 0, all vouchers for the account are updating with Zero Balance but it is not correct

			New solution is to update the balance at account level but not voucher level
	*/


			 SELECT ACCOUNTNUM,INVOICE,VOUCHER, CTAMOUNTCUR
					,SUM(BalanceCUR) AS Balance
			 INTO #Status
			 FROM FO.tblFOAgedDebt
			-- WHERE ------------------Arthur removed 16/09/22 as it preventing some statuses from being updated, namely GJs
				--(
				--	SELECT SUM(BalanceCUR)
				--	FROM FO.tblFOAgedDebt
				--) > 0
			 GROUP BY ACCOUNTNUM, INVOICE, VOUCHER, CTAMOUNTCUR



			 UPDATE FO.tblFOAgedDebt
			   SET
				   TotalDebtStatus = 'In Debt'
			 FROM #Status
			 WHERE Balance > 0
				   AND FO.tblFOAgedDebt.ACCOUNTNUM = #Status.ACCOUNTNUM
				   AND FO.tblFOAgedDebt.Voucher = #Status.Voucher
				   AND FO.tblFOAgedDebt.CTAMOUNTCUR = #Status.CTAMOUNTCUR


			 UPDATE FO.tblFOAgedDebt
			   SET
				   TotalDebtStatus = 'In Credit'
			 FROM #Status
			 WHERE Balance < 0
				   AND FO.tblFOAgedDebt.ACCOUNTNUM = #Status.ACCOUNTNUM
				   AND FO.tblFOAgedDebt.Voucher = #Status.Voucher
				   AND FO.tblFOAgedDebt.CTAMOUNTCUR = #Status.CTAMOUNTCUR


			 UPDATE FO.tblFOAgedDebt
			   SET
				   TotalDebtStatus = 'Zero Balance'
			 FROM #Status
			 WHERE Balance = 0
				   AND FO.tblFOAgedDebt.ACCOUNTNUM = #Status.ACCOUNTNUM
				   AND FO.tblFOAgedDebt.Voucher = #Status.Voucher
				   AND FO.tblFOAgedDebt.CTAMOUNTCUR = #Status.CTAMOUNTCUR
	
		DROP TABLE #Status
		DROP TABLE #BalanceCUR
		DROP TABLE #BalanceGBP
		
END
