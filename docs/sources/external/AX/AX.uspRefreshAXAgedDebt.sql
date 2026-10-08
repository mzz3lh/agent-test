CREATE PROCEDURE [AX].[uspRefreshAXAgedDebt]
AS
     BEGIN

/*
Refresh the AX.AXAgedDebt Table 
*/

         SET NOCOUNT ON;
         TRUNCATE TABLE AX.tblAXAgedDebt;


         INSERT INTO AX.tblAXAgedDebt
(ContactNo,
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
 AMOUNTCUR,
 SETTLEAMOUNTCUR,
 AMOUNTMST,
 SETTLEAMOUNTMST,
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
 LYCompletedFormalHrs,
 CPDComplete,
 CompletedFormalHrs,
 [Payment Method],
 TotalDebtStatus,
 RICRECALREFERENCE,
 DATAAREAID,
 CREATEDDATETIME,
 CREATEDBY,
 Rics_HardcopySubs,
 Pathway
)
                SELECT DISTINCT
                       CN.Rics_ContactNo AS ContactNo,
                       CT.ACCOUNTNUM,
                       CN.AccountIDName AS CRMParentAccount,
                       A.Rics_FirmNumber AS CRMParentAccountFirmNo,
                       A.Rics_OfficeNumber AS CRMParentAccountOfficeNo,
                       C.NAME,
                       RICCUSTINTERFACEREF,
                       CN.rics_corporateSchemeNameIdName,
                       CN.Salutation AS Salutation,
                       RG.Rics_WorldRegion AS WorldRegion,
                       RG.Ricsv2_ReportingWorldRegionIdName AS ReportingWorldRegion,
                       RG.Rics_ReportingSubWorldRegion AS ReportingSubWorldRegion,
                       LTRIM(RTRIM(SUBSTRING(CN.rics_LocalGroupIDName, 14, LEN(LTRIM(RTRIM(CN.rics_LocalGroupIDName)))-13))) AS LocalGroup,
                       RG.Rics_ReportingLocalGroup AS ReportingLocalGroup,
                       CN.rics_Corespadd_country AS Country,
                       ISNULL(CN.EMailAddress1, '') AS PreferredEMail,
                       SM5.Value AS DoNotChase,
                       CN.rics_MailName AS MailName,
                       CN.MobilePhone,
                       SM.Value AS LapsedCode,
                       SM2.Value AS MemberGrade,
                       SM3.Value AS ConcessionType,
                       CN.Rics_Region AS Region,
                       RG.Rics_ReportingRegionIDName AS ReportingRegion,
                       CASE CN.rics_PreventLapse
                           WHEN 0
                           THEN 'No'
                           WHEN 1
                           THEN 'Yes'
                           ELSE 'No'
                       END AS PreventLapse,
                       '' AS AXPaymentSchedule,
                       CASE CN.Rics_PaymentCycle
                           WHEN 1
                           THEN 'Annual'
                           WHEN 2
                           THEN 'Quarterly'
                           WHEN 3
                           THEN 'Monthly (10 Payments)'
                           WHEN 4
                           THEN 'Monthly (3 Payments)'
                           WHEN 5
                           THEN 'New addition to pick list - See DBA to add'
                           ELSE 'Not Specified'
                       END AS CRMPaymentCycle,
                       CT.TRANSDATE,
                       DUEDATE,
                       INVOICE,
                       CT.VOUCHER,
                       CT.CURRENCYCODE,
                       CT.AMOUNTCUR,
                       SETTLEAMOUNTCUR,
                       CT.AMOUNTMST,
                       SETTLEAMOUNTMST,
                       CT.AMOUNTCUR - SETTLEAMOUNTCUR AS BalanceCUR,
                       CT.AMOUNTMST - (SETTLEAMOUNTMST - EXCHADJUSTMENT) AS BalanceGBP,
                      '' AS RDDDBucket,
					   '' AS RDTDBucket,
					  '' AS RMDDBucket,
					  '' AS RMTDBucket,
                       CASE RICINVOICETYPE
                           WHEN ''
                           THEN 'Not Specified'
                           ELSE RICINVOICETYPE
                       END AS 'InvType',
                       CASE CT.PAYMMODE
                           WHEN ''
                           THEN 'Not Specified'
                           ELSE CT.PAYMMODE
                       END AS PAYMMODE,
                       CT.TXT,
                       HITINTSYSTEMID,
                       DATEDIFF(DAY, CT.TRANSDATE, GETDATE()) AS DaysSinceInvoiced,
                       GETDATE() AS RefreshDateTime,
                       CT.DIMENSION AS CostCentre
                       ,  --changed from CTI.DIMENSION because of cost centre duplicates 02/02/2018 DBA/PS--changed from CT.DIMENSION 07/12/2017 DBA/PS 
                       CT.DIMENSION2_ AS RevenueStream,
                       CT.Dimension3_ AS ProductCode,
                       CT.[RICEXTERNALINVOICEREF] AS SubsYear,
                       ISNULL(CN.Rics_PendingRemoval, '') AS PendingRemoval,
                       ISNULL(CN.Rics_PendingRemovalDate, '') AS PendingRemovalDate,
                       ISNULL(CN.rics_renewals, 0) AS Renewals,
                       '' AS Fulfilled,
                       NULL AS LYCPDComplete,
                       0.00 AS LYCompletedFormalHrs,
                       NULL AS CPDComplete,
                       0.00 AS CompletedFormalHrs,
                       SM4.value AS [Payment Method],
					   '' AS TotalDebtStatus,
                       CT.RICRECALREFERENCE,
                       CT.DATAAREAID,
                       CT.CREATEDDATETIME,
                       CT.CREATEDBY,
                       CN.Rics_HardcopySubs,  --Added 12/08/2019 Request Mandy Bradley.
					   RP.Rics_Name AS Pathway   --Added 29/04/2021 Request Marcey Baumber SD 000000
					  -- INTO AX.tblAXAgedDebt
                FROM AX.vwCUSTTRANS CT
                     LEFT JOIN AX.vwCUSTTABLE C ON CT.ACCOUNTNUM = c.ACCOUNTNUM
                                                               AND CT.DATAAREAID = C.DATAAREAID
                     LEFT JOIN dbo.vwContact CN ON CN.rics_financereference COLLATE SQL_Latin1_General_CP1_CI_AS = CT.ACCOUNTNUM
                                                                           --AND CN.StateCode = 0
                     LEFT JOIN dbo.vwAccount A ON A.AccountID = CN.AccountID
                     LEFT JOIN dbo.vwRicsGroup RG ON RG.Rics_Name = CN.rics_LocalGroupIDName
                                                                              AND RG.Rics_GroupID = CN.Rics_LocalGroupID
                     LEFT JOIN .dbo.vwStringMap SM ON SM.AttributeValue = CN.Rics_LapsedCode
                                                                             AND SM.AttributeName = 'Rics_LapsedCode'
                                                                             AND SM.ObjectTypeCode = 2
                     LEFT JOIN dbo.vwStringMap SM2 ON SM2.AttributeValue = CN.Rics_MemberGrade
                                                                              AND SM2.AttributeName = 'Rics_MemberGrade'
                                                                              AND SM2.ObjectTypeCode = 2
                     LEFT JOIN dbo.vwStringMap SM3 ON SM3.AttributeValue = CN.Rics_ConcessionCode
                                                                              AND SM3.AttributeName = 'Rics_ConcessionCode'
                                                                              AND SM3.ObjectTypeCode = 2
                     LEFT JOIN dbo.vwStringMap AS SM4 ON CN.rics_paymentmethod = SM4.AttributeValue
                                                                                 AND SM4.AttributeName = 'rics_paymentmethod'
                                                                                 AND SM4.ObjectTypeCode = 2
                     LEFT JOIN dbo.vwStringMap AS SM5 ON CN.rics_DoNotChase = SM5.AttributeValue
                                                                                 AND SM5.AttributeName = 'rics_DoNotChase'
                                                                                 AND SM5.ObjectTypeCode = 2

LEFT JOIN dbo.vwRics_Pathway RP ON CN.rics_pathwaytomembershipid = RP.rics_PathwayID

                WHERE CT.AMOUNTCUR - SETTLEAMOUNTCUR <> 0;



--Update the Cost Centre Based on the value in the LEDGERTRANS Table for those who are 99999
         UPDATE AX.tblAXAgedDebt
           SET
               CostCentre = LT.DIMENSION
         FROM AX.vwLEDGERTRANS LT
              INNER JOIN AX.tblAXAgedDebt ST ON ST.VOUCHER = LT.VOUCHER
         WHERE ST.CostCentre = 99999;


--UPDATE the buckets

--Current variable
         DECLARE @today DATETIME;
         SET @Today = CAST(GETDATE() AS DATE);

--Current by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = 'Current'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE >= @Today;

--Current by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = 'Current'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE >= @Today;

--0to30 Variable
         DECLARE @30 DATETIME;
         SET @30 = CAST(GETDATE() - 30 AS DATE);

--0 to 30 by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = '0to30'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE BETWEEN @30 AND @Today;

--0 to 30 by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = '0to30'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE BETWEEN @30 AND @Today;

--31to60 Variables
         DECLARE @31 DATETIME;
         SET @31 = CAST(GETDATE() - 31 AS DATE);
         DECLARE @60 DATETIME;
         SET @60 = CAST(GETDATE() - 60 AS DATE);

--31 to 60 by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = '31to60'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE BETWEEN @60 AND @31;

--31 to 60 by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = '31to60'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE BETWEEN @60 AND @31;


--61to90 Variables
         DECLARE @61 DATETIME;
         SET @61 = CAST(GETDATE() - 61 AS DATE);
         DECLARE @90 DATETIME;
         SET @90 = CAST(GETDATE() - 90 AS DATE);

--61 to 90 by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = '61to90'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE BETWEEN @90 AND @61;

--61 to 90 by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = '61to90'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE BETWEEN @90 AND @61;


--91to120 Variables
         DECLARE @91 DATETIME;
         SET @91 = CAST(GETDATE() - 91 AS DATE);
         DECLARE @120 DATETIME;
         SET @120 = CAST(GETDATE() - 120 AS DATE);

--91 to 120 by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = '91to120'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE BETWEEN @120 AND @91;

--91 to 120 by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = '91to120'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE BETWEEN @120 AND @91;

--121to180 Variables
         DECLARE @121 DATETIME;
         SET @121 = CAST(GETDATE() - 121 AS DATE);
         DECLARE @180 DATETIME;
         SET @180 = CAST(GETDATE() - 180 AS DATE);

--121 to 180 by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = '121to180'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE BETWEEN @180 AND @121;

--121 to 180 by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = '121to180'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE BETWEEN @180 AND @121;


--181to365 Variables
         DECLARE @181 DATETIME;
         SET @181 = CAST(GETDATE() - 181 AS DATE);
         DECLARE @365 DATETIME;
         SET @365 = CAST(GETDATE() - 365 AS DATE);

--181 to 365 by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = '181to365'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE BETWEEN @365 AND @181;

--181 to 365 by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = '181to365'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE BETWEEN @365 AND @181;


--365+ by DUEDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDDDBucket = '365Plus'
         FROM AX.tblAXAgedDebt
         WHERE DUEDATE < @365;

--365+ by TRANSDATE
         UPDATE AX.tblAXAgedDebt
           SET
               RDTDBucket = '365Plus'
         FROM AX.tblAXAgedDebt
         WHERE TRANSDATE < @365;


--UPDATE the RMDDBucket and RMTDBucket
         UPDATE AX.tblAXAgedDebt
           SET
               RMDDBucket = DATENAME(month, DUEDATE) + CAST(DATEPART(yy, DUEDATE) AS VARCHAR(4))
         FROM AX.tblAXAgedDebt;
         UPDATE AX.tblAXAgedDebt
           SET
               RMTDBucket = DATENAME(month, TRANSDATE) + CAST(DATEPART(yy, TRANSDATE) AS VARCHAR(4))
         FROM AX.tblAXAgedDebt;

--Get rid of NULLS for reporting
         UPDATE AX.tblAXAgedDebt
           SET
               DoNotChase = ''
         WHERE DoNotChase IS NULL;

		 /********************************NEEDS CUSTPAYMSCHED*************************************
----Get the AXPaymentSchedule
--         SELECT AXS.Invoice,
--                CPS.Name
--         INTO #PaySched
--         FROM AX.tblAXAgedDebt AXS
--              LEFT JOIN RICS_AX_Live.dbo.CUSTINVOICEJOUR CIJ ON AXS.[Invoice] = CIJ.INVOICEID
--              LEFT JOIN RICS_AX_Live.dbo.CUSTPAYMSCHED CPS ON CPS.EXTRECID = CIJ.RECID;
--	--WHERE AXS.[Method of Payment] LIKE 'DD%'

----UPDATE the staging table
--         UPDATE AX.tblAXAgedDebt
--           SET
--               AXPaymentSchedule = #.Name
--         FROM #PaySched #
--         WHERE #.Invoice = AX.tblAXAgedDebt.Invoice;
***************************************************************************************************/

/******************************TODO - GET SUBSFULFILLMENT FLAG*****************************
----Update the Fulfilled field with the contactNo if they have fulfilled
--         UPDATE AX.tblAXAgedDebt
--           SET
--               Fulfilled = SF.ContactNo
--         FROM DBADB.dbo.SubsFulfilment SF
--              INNER JOIN AX.tblAXAgedDebt ST ON ST.ContactNo = SF.ContactNo
--         WHERE ST.ContactNo = SF.ContactNo;
*****************************************************************************************************/


--Update the CPD fields
--Current Year
         UPDATE AX.tblAXAgedDebt
           SET
               CPDComplete = Rics_CPDComplete,
               CompletedFormalHrs = CPD.rics_CompletedFormalHrs
          FROM dbo.vwRics_CPDAnnualSummary CPD
              LEFT JOIN dbo.vwContact CN ON CPD.rics_ContactId = CN.ContactID
              LEFT JOIN AX.tblAXAgedDebt ST ON CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
         WHERE CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
               AND CPD.Rics_CPDYear = DATEPART(yyyy, GETDATE());  --To Do - Verify that this needs to be the year prior to the current one. If so use DATEPART(yyyy,GETDATE())-1



--Previous Year  --ADDED DBA/PS 04/01/2018
         UPDATE AX.tblAXAgedDebt
           SET
               LYCPDComplete = Rics_CPDComplete,
               LYCompletedFormalHrs = rics_CompletedFormalHrs
         FROM dbo.vwRics_CPDAnnualSummary CPD
              LEFT JOIN .dbo.vwContact CN ON CPD.rics_ContactId = CN.ContactID
              LEFT JOIN AX.tblAXAgedDebt ST ON CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
         WHERE CN.Rics_ContactNo COLLATE Latin1_General_CI_AI = ST.ContactNo
               AND CPD.Rics_CPDYear = DATEPART(yyyy, GETDATE()) - 1;  

-- Update the TotalDebtStatus field  --Added DBA/PS 06/08/2018 - this will show if the member is in debt,credit or has a zero TOTAL balance

         SELECT ACCOUNTNUM,
                SUM(BalanceGBP) AS Balance
         INTO #Status
         FROM AX.tblAXAgedDebt
         WHERE
(
    SELECT SUM(BalanceGBP)
    FROM AX.tblAXAgedDebt
) > 0
         GROUP BY ACCOUNTNUM;
         UPDATE AX.tblAXAgedDebt
           SET
               TotalDebtStatus = 'In Debt'
         FROM #Status
         WHERE Balance > 0
               AND AX.tblAXAgedDebt.ACCOUNTNUM = #Status.ACCOUNTNUM;
         UPDATE AX.tblAXAgedDebt
           SET
               TotalDebtStatus = 'In Credit'
         FROM #Status
         WHERE Balance < 0
               AND AX.tblAXAgedDebt.ACCOUNTNUM = #Status.ACCOUNTNUM;
         UPDATE AX.tblAXAgedDebt
           SET
               TotalDebtStatus = 'Zero Balance'
         FROM  #Status
         WHERE Balance = 0
               AND AX.tblAXAgedDebt.ACCOUNTNUM = #Status.ACCOUNTNUM;
     END
