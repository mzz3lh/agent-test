--/****** Object:  View [FO].[vwSubsRenewals2022]    Script Date: 06/04/2022 13:15:09 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO








CREATE VIEW [FO].[vwSubsRenewals2022]
AS

WITH cteMain
AS
(
  SELECT DISTINCT SR.SubsCampaign AS [Subs Campaign],
'01/01/2022' AS PaymentDate,
C.Rics_ContactNo + '/2022' AS Reference,
C.Rics_ContactNo AS MemberNumber,
C.[ContactId] AS ContactGUID, --Added 17/02/2022 - AAB
C.FirstName AS [First Name],
C.Rics_MailName AS MailName,
A.rics_registeredname AS CompanyName,   --Changed PS 30/03/2022  was --C.AccountidName AS CompanyName,  
C.address1_Line1 AS Addr1,
C.Address1_Line2 AS Addr2,
C.Address1_Line3 AS Addr3,
C.Address1_City AS Addr4,
C.Address1_County AS Addr5,
C.Address1_PostalCode AS PostCode,
C.Address1_Country AS CountryName,
C.rics_countryidname AS SubsCountry,
RG.Rics_Region AS Region,
RG.rics_ReportingLocalGroup AS ReportingLocalGroup,
--RG.ricsRics_ReportingRegionIDName AS ReportingRegion,  NOT IN VIEW
RG.Rics_ReportingSubWorldRegion AS ReportingSubWorlRegion,
RG.Rics_WorldRegion AS WorldRegion,
C.Salutation AS Salutation,
C.rics_honours AS Honours,
C.Telephone1 AS PreferredPhone,  
C.mobilephone AS MobilePhone,  
C.EmailAddress1 AS Email, 
C.rics_ElectionDate as PAEntranceDate,
F.rics_electiondate AS FellowDate, 
C.apuk_designation_description AS MemberGrade,
C.MemberGrade_Description AS RICSContactType, 
--SM1.Value AS NYGrade,    NOT IN VIEW
SR.Concession AS ContactConcessionCode, --17/11/2021 Raj to exclude description of Dual membership (flag is sufficient) --C.rics_ConcessionCode_Descritpion AS [ContactConcessionCode], --incorrect spelling Not Me!
--SM2.Value AS NYStatus,    NOT IN VIEW
TC.isocurrencycode AS Currency,  --Currency on the contact record
C.Rics_paymentMethod_Description AS PaymentMethod,
CASE FOQ.apuk_paymentmethod 
		WHEN 200000000 THEN 'Direct Debit'
		WHEN 200000001 THEN 'Corporate'
		WHEN 200000002 THEN 'Credit Card'
		WHEN 200000003 THEN 'BACS'
		WHEN 200000004 THEN 'Trade Account'
		WHEN 200000005 THEN 'Invoice'
		WHEN 200000006 THEN 'Cheque'
END AS PaymentMethod_Quote,
--SM3.Value AS NYPaymentMethod, --check that this should default to the current PaymentMethod name  NOT IN VIEW
C.Rics_PaymentCycle_Description AS PaymentCycle,
--CASE C.rics_InvalidAddress1
--	WHEN 1 THEN 'True'
--	ELSE 'False' 
--END AS InvalidHomeAddress,  NOT IN VIEW
NULL AS SubsInvoice,
FOQ.SubsDueCur AS SubsFee_FOQuote, ---SR.subsduecur AS SubsDue, this was giving incorrect amount see 0000000
CEQ.totalamount AS Total_CEQuote,
SR.Concession_amount_CUR As ConcessionAmount_Renewals,
ISNULL(SA.AdjustedAmount,0.00) AS SubsDue_SubsAdjusted,
CAST(SR.SubsDueCur AS DECIMAL(10,2)) AS SubsDue_Renewals,
SR.subsduemst AS SubsDue_Renewals_GBP,
ISNULL(FOQ.apuk_LionHeartDonation_CUR,0.00) AS LionHeartDue_FOQuote,  
0.00 AS Surcharge, --??
--curr.currencysymbol AS CurrencySymbol,  NOT IN VIEW
CASE C.apuk_declinelionheart
	WHEN 1 THEN 'True'
	ELSE 'False'
END AS LHDecline,  
C.rics_electiondate AS ELECTIONDATE,
C.birthdate AS DOB,
C.rics_dualmembership AS NYDUALMEMBERSHIP,
SR.dualmembership AS CYDUALMEMBERSHIP,
aAPC.rics_enrolmentdate AS APCCENROLDATE,
--(SELECT TOP (1) rics_nameonaccount
--FROM FilteredRics_directdebit AS FilteredRics_directdebit_1
--WHERE (rics_contactid = C.contactid) AND (statecode = 0)
--ORDER BY modifiedon DESC) AS AccountName,
--(SELECT TOP (1) rics_accountnumber
--FROM FilteredRics_directdebit
--WHERE (rics_contactid = C.contactid) AND (statecode = 0)
--ORDER BY modifiedon DESC) AS AccountNumber,
--(SELECT TOP (1) rics_sortcode
--FROM FilteredRics_directdebit AS FilteredRics_directdebit_2
--WHERE (rics_contactid = C.contactid) AND (statecode = 0)
--ORDER BY modifiedon DESC) AS SORTCODE,
NULL AS BankAccountNo,
NULL AS IBAN,
C.EmailAddress2 AS BusinessEmail,
C.EMailAddress3 AS PersonalEMail,
C.EMailAddress1 AS PreferredEMail,
--NULL AS CPDF, --irrelevant now?
C.Rics_Donotchase_Description AS DoNotChase,
C.Rics_LapsedCode_Description AS LapsedCode, 
CASE 
WHEN ISNULL(C.Rics_HardcopySubs,0) = 0 THEN 'No'
WHEN ISNULL(C.Rics_HardcopySubs,0) = 1 THEN 'Yes'
END AS HardcopySubs,
C.Rics_PreventLapse AS PreventLapse,
--C.Rics_DisabilityVisual AS VisualImpairment  NOT IN VIEW
FOQ.StateCode_Description AS QuoteStatus,
--SR.Quote_StateCode,
--SR.Quote_StatusCode,
CEQ.msdyn_quotenumber AS QuoteNo,  --just here as a check
CASE FOQ.Movement
	WHEN 'M01' THEN 'New'
	WHEN 'M02' THEN 'Renewal'
END AS [New/Renewal],
SA.TotalPaid,
SA.Paid,
SA.BalanceGBP,
CT.LASTSETTLEDATE AS DatePaid  --Added PS 30/03/2022
 

FROM CE.vwContact C 
LEFT JOIN CE.vwRicsGroup AS RG 
	ON C.rics_localgroupid = RG.rics_groupid

LEFT JOIN
    (SELECT rics_contactid, MAX(rics_electiondate) AS rics_electiondate
     FROM  CE.vwRicsAPC
     WHERE (rics_applicationtypeidname = 'Fellowship')
     GROUP BY rics_contactid) AS F 
		ON C.contactid = F.rics_contactid

LEFT JOIN
    (SELECT rics_contactid, MAX(rics_enrolmentdate) AS rics_enrolmentdate
    FROM  CE.vwRicsAPC AS FilteredRics_apc_1
   -- WHERE (rics_applicationtypeidname = 'APC')
    GROUP BY rics_contactid) AS aAPC ON C.contactid = aAPC.rics_contactid

LEFT JOIN FO.vwSubsRenewals SR
	ON C.rics_ContactNo = SR.rics_ContactNo
	--AND SR.SubsCampaign = 'Subs0000'
	AND (SR.Quote_StateCode IS NULL OR SR.Quote_StateCode  <> 'Closed')

LEFT JOIN [SubsRep_BI].[vwSubsAdjusted_FO] SA
	ON SA.rics_contactNo = SR.rics_ContactNo
	--AND SA.SubsCampaign = 'Subs0000'
	AND SA.SubsCampaign = SR.SubsCampaign

LEFT JOIN FO.vwSubsQuotes FOQ
	ON FOQ.rics_contactNo= C.rics_contactNo
	AND FOQ.StateCode_Description IN ('Won','Active')
	--AND FOQ.SubsCampaign = 'Subs0000'
	AND FOQ.ProductNumber NOT LIKE 'rcsCON%'

LEFT JOIN CE.vwQuote CEQ
	ON CEQ.quoteid= FOQ.quoteid
	AND FOQ.StateCode_Description IN ('Won','Active')
	--AND FOQ.SubsCampaign = 'Subs0000'

LEFT JOIN CE.vwTransactionCurrency TC
	ON TC.TransactionCurrencyID = C.transactioncurrencyid

LEFT JOIN CE.vwAccount A
ON A.AccountId = C.ParentCustomerId

LEFT JOIN [FO].[vwCustTrans] CT
ON CT.Voucher = SA.Voucher


WHERE C.rics_ContactNo IN (SELECT rics_ContactNo FROM [FO].vwSubsQuotes)--[vwSubsRenewals]
												--WHERE SubsCampaign = 'Subs0000')
AND C.statecode = 0
--AND SR.Quote_StateCode <> 'Closed' --Added 18-02-22 by AAB After changing the SP for SubsRenewals to allow all Closed in.


),


--cteMulti  --just a check for multiple rows per member
--AS
--(
--SELECT MemberNumber, COUNT(MemberNumber) AS [Count] FROM cteMain
--GROUP BY MemberNumber
--HAVING COUNT(MemberNumber) >1)

--SELECT * FROM cteMain
--WHERE MemberNumber IN (SELECT MemberNumber FROM cteMulti) 



cteOtherAgedDebt
AS
(
SELECT  [CRM Contact No] AS MemberNumber, 
SUM (BalanceGBP)AS TotalDebtGBP
FROM FinBi.vwD365CommercialandNonCommercialAgedDebt
WHERE [CRM Contact No] IN (SELECT MemberNumber FROM cteMain)
GROUP BY [CRM Contact No]
)



--Final Query
SELECT M.*, 
CASE 
	WHEN ISNULL(AD.TotalDebtGBP,0.00) = 0.00 THEN 0.00
	ELSE ISNULL(AD.TotalDebtGBP,0.00) - M.SubsDue_Renewals_GBP
END AS OtherOutstandingDebtGBP
FROM cteMain M
LEFT JOIN cteOtherAgedDebt AD
	ON M.MemberNumber = AD.MemberNumber
	--WHERE M.MemberNumber = '0000000'
	--AND [Subs Campaign] = 'Subs0000'
