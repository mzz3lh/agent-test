CREATE   PROCEDURE [Subs].[usp_Refresh_SubsCommsChase]
AS 
BEGIN

DECLARE @Current_CampaignYear INT

IF DATEPART(MONTH, getdate()) >= 10
BEGIN
	SET @Current_CampaignYear = DATEPART(YEAR, getdate())+1 END
ELSE
BEGIN
	SET @Current_CampaignYear = DATEPART(YEAR, getdate()) END

--SET @Current_CampaignYear = 2023
	
DROP TABLE IF EXISTS #TT1
	SELECT 
	 CON.Rics_contactno AS 'Contact No'
	,CON.ContactId AS 'Contact ID'
	,@Current_CampaignYear AS 'Campaign Year'
	,CON.FirstName AS 'First Name'
	,CON.LastName AS 'Surname'
	,CON.Rics_MailName AS 'Mail Name'
	,CURR.isocurrencycode AS 'Currency (Contact)'
	,CON.Rics_PaymentMethod_Description AS 'Payment Method (Contact)'
	,CON.Rics_PaymentCycle_Description AS 'PayCycle (Contact)'
	,CON.Rics_PreventLapse_Description AS 'Prevent Lapse'
	,ACC.name AS 'Account Name'
	,CON.address1_Line1 AS 'Address Line 1'
	,CON.Address1_Line2 AS 'Address Line 2'
	,CON.Address1_Line3 AS 'Address Line 3'
	,CON.Address1_County AS 'County'
	,CON.Address1_City AS 'City'
	,CON.Address1_Country AS 'Country'
	,CON.Address1_PostalCode AS 'Postcode'
	,CON.rics_localgroupid AS 'Local Group ID'
	,MemberGrade_Description AS 'Member Grade'
	,apuk_designation_description As 'Designation'
	,MobilePhone AS 'Mobile Phone'
	,Salutation AS 'Salutation'
	,CON.EMailAddress1 AS 'Email Address'
	,Rics_Donotchase_Description AS 'Do Not Chase Reason'
	,Rics_HardcopySubs AS 'Hardcopy Subs'
	,CASE WHEN apuk_disabilities = '000000000' THEN 'Y' ELSE 'N' END AS 'Visual Disability'
	,Rics_LapsedCode_Description AS 'Lapsed Reason'
	,Rics_ElectionDate AS 'Election Date'
	INTO #TT1
	FROM [CE].[vwContact] CON
	LEFT JOIN CE.vwAccount ACC
		ON CON.AccountId = ACC.AccountId
	LEFT JOIN CE.vwTransactionCurrency CURR
		ON CURR.transactioncurrencyid = CON.TransactionCurrencyId
	WHERE CON.StateCode = 0
	AND Rics_MemberGrade IN (200000000, 200000001, 200000002) 
	AND Rics_LapsedCode IS NULL

DROP TABLE IF EXISTS #APPR
	SELECT
	Rics_contactno
	INTO #APPR
	FROM [CE].[vwConcession]
	WHERE Product_Number = 'rcsCONAPPRENTICE'
	AND apuk_subscriptionyear = @Current_CampaignYear
	AND statecode = 0
	GROUP BY Rics_contactno

DROP TABLE IF EXISTS #ENR
	SELECT
	 [Contact No]
	,[Enrolment Date]
	INTO #ENR
	FROM CE.vwEnrolments_Valid_First


--Raj Maddala, 2025-04-23
DROP TABLE IF EXISTS #ENR_LAST
	SELECT
	 [Contact No]
	,[Enrolment Date]
	INTO #ENR_LAST
	FROM CE.vwEnrolments_Valid_Last



DROP TABLE IF EXISTS #CONCSPCL
	SELECT 
	 Rics_contactno
	INTO #CONCSPCL
	FROM CE.vwConcession
	WHERE Product_Number IN (
		'rcsCONEMINENT',
		'rcsCONEXCEPTIONHP',
		'rcsCONLIFEMEMBER',
		'rcsCONMEMBERINVITATION',
		'rcsCONPASTPRESIDENT',
		'rcsCONRETIREDFL',
		'rcsCONSTAFFMEMBER',
		'rcsCONSANDWICH'
		--'rcsCONMATERNITYADOPTION'
		)
	AND apuk_dualmembership = 0
	AND statecode = 0
	AND (	
		(apuk_subscriptionyear = @Current_CampaignYear
		AND apuk_perpetualnonperpetual = 200000001) --Non-Perpetual
		OR
		apuk_perpetualnonperpetual = 200000000 --Perpetual
		)
	GROUP BY Rics_contactno

DROP TABLE IF EXISTS #CORP
	SELECT
	ricsv2_Contact AS Contact_ID
	INTO #CORP
	FROM CE.vwSubscriptionUser SUSER
	INNER JOIN CE.vwRicsv2Subscription SUB
			ON SUSER.ricsv2_SubscriptionId = SUB.ricsv2_subscriptionId
	WHERE SUB.ricsv1_SubscriptionProduct = '00000000-0000-0000-0000-000000000000' --Corporate Subscription Product
	AND CAST(SUB.apuk_licensekey AS INT) = @Current_CampaignYear
	AND SUB.statuscode = 1 --Active 
	AND SUSER.StatusCode = 1 --Active
	GROUP BY ricsv2_Contact

DROP TABLE IF EXISTS #VALIDQUOTE
	SELECT
	 QUO.Contact_No
	INTO #VALIDQUOTE
	FROM CE.vwQuote QUO
	LEFT JOIN [CE].[vwQuoteDetail] QUOD ON QUO.quoteid = QUOD.quoteid
	LEFT JOIN CE.vwProduct PRD ON PRD.ProductId = QUOD.productid
	WHERE PRD.Product_Number IN (
	   'rcsPROAPCCAND'
	  ,'rcsPROFRICS'
	  ,'rcsPROASSOC'
	  ,'rcsPROASSOCCAND'
	  ,'rcsPROMRICS'
	  ,'rcsPROMRICSU2'
	  )
	AND QUO.StateCode_Description IN ('Won', 'Active')
	AND apuk_campaignyear = @Current_CampaignYear
	GROUP BY QUO.Contact_No

DROP TABLE IF EXISTS #MEMSTAT
	SELECT
	 [Contact No.]
	,[Member Quote Position]
	,[Member Invoice Position]
	INTO #MEMSTAT
	FROM Subs.vwSubsMemberStatuses
	WHERE [Campaign Year] = @Current_CampaignYear

DROP TABLE IF EXISTS #CONC
	SELECT 
	 Rics_contactno
	,MIN([apuk_name]) AS apuk_name
	--,[apuk_dualmembership]
	--,[apuk_discount]
	--,apuk_subscriptionyear
	INTO #CONC
	FROM CE.vwConcession
	WHERE apuk_dualmembership = 0
	AND statecode = 0         ------------------------------------------------------------------------------------------------------TEST WITH PERP
	AND (	
		(apuk_subscriptionyear = @Current_CampaignYear
		AND apuk_perpetualnonperpetual = 200000001) --Non-Perpetual
		OR
		apuk_perpetualnonperpetual = 200000000 --Perpetual
		)
	GROUP BY Rics_contactno

DROP TABLE IF EXISTS #SQUO
	SELECT
	[Quote ID]
	INTO #SQUO
	FROM Subs.vwSubsQuotes
	WHERE [Quote State] = 'Active'
	AND [Campaign Year] = @Current_CampaignYear
	GROUP BY [Quote ID]

DROP TABLE IF EXISTS #QUO
	SELECT
	 QUO.Contact_No
	--,QUO.quoteid AS 'Quote ID'
	,QUO.msdyn_quotenumber AS 'Quote Number'
	,QUO.createdon AS 'Quote Created'
	--,QUO.name AS 'Quote Name'
	--,QUO.description AS 'Quote Description'
	,QUO.msdyn_isocurrencycode AS 'Quote Currency'
	,QUO.TotalAmount AS 'Line Amount CUR'
	--,QUO.TotalAmount_Base AS 'Line Amount GBP'
	,QUO.apuk_lionheartdonation AS 'LHL Amount CUR'
	--,QUO.apuk_lionheartdonation_base AS 'LHL Amount GBP'
	,QUO.apuk_directdebitfees AS 'Surcharge Amount CUR'
	--,QUO.apuk_directdebitfees_base AS 'Surcharge Amount GBP'
	,QUO.Total_Incl_Charges AS 'Total Amount CUR'
	--,QUO.Total_Incl_Charges_Base AS 'Total Amount GBP'
	--,QUO.apuk_campaignyear AS 'Quote Campaign Year'
	,QUO.apuk_paymentmethod_description AS 'Quote Payment Method'
	,StateCode_Description AS 'Quote State'
	INTO #QUO
	FROM CE.vwQuote QUO
	LEFT JOIN #SQUO SQUO
		ON QUO.quoteid = SQUO.[Quote ID]
	INNER JOIN Subs.tblSubsMemberStatuses MS
		ON QUO.Contact_No = MS.[Contact No.]
		AND QUO.apuk_campaignyear = MS.[Campaign Year]
		AND MS.[Member Quote Position] = 'Active'
	WHERE SQUO.[Quote ID] IS NOT NULL
	AND apuk_campaignyear = @Current_CampaignYear

	--SELECT * FROM #SQUO
	--SELECT * FROM #QUO

DROP TABLE IF EXISTS #INV
	SELECT
	 INV.[Account Num]
	,INV.[Full Invoice Amount CUR] AS 'Inv Full Amount CUR'
	,INV.[Settle Amount CUR] AS 'Inv Settle Amount CUR'
	,INV.[Full Invoice Amount CUR] - [Settle Amount CUR] AS 'Inv Full Balance CUR'
	,INV.[Invoice]
	,INV.[Trans Date] AS 'Invoice Date'
	,INV.[Currency] AS 'Invoice Currency'
	,INV.[Payment Method] AS 'Invoice Payment Method'
	,INV.[Payment Status]
	,INV.[Last Settle Date]
	,MS.[Member Invoice Position] AS 'Inv Member Invoice Position'
	INTO #INV
	FROM Subs.vwSubsInvoices INV
	INNER JOIN Subs.tblSubsMemberStatuses MS
		ON INV.[Account Num] = MS.[Contact No.]
		AND INV.[Campaign Year] = MS.[Campaign Year]
		AND MS.[Member Invoice Position] IN ('No Payment', 'Partially Paid')
	WHERE INV.[Campaign Year] = @Current_CampaignYear
	AND INV.[Payment Status] <> 'Fully Credited'

DROP TABLE IF EXISTS #FINAL
SELECT 
 TT1.*
,QUO.*
,INV.*
,CONC.apuk_name AS 'Concession'
,ENR.[Enrolment Date] AS First_Enrolment_Date
,TT1.[Election Date] AS First_Election_Date
,CASE WHEN [Lapsed Reason] IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is Lapsed'
,COALESCE([Member Quote Position], 'Not in Subs Cohort') AS 'Member Quote Position'
,COALESCE([Member Invoice Position], 'Not in Subs Cohort') AS 'Member Invoice Position'
,CASE WHEN CORP.Contact_ID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Corporate Member'
,CASE WHEN APPR.Rics_contactno IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Current Apprentice'
,CASE WHEN CONCSPCL.Rics_contactno IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Special Concession'
,CASE WHEN TT1.Designation = 'Honorary' THEN 'Y' ELSE 'N' END AS 'Honorary Member'
,CASE 
	WHEN NOT(
	(ENR.[Enrolment Date] IS NULL AND TT1.[Election Date] IS NULL) OR
	(ENR.[Enrolment Date] IS NULL OR CAST(ENR.[Enrolment Date] AS DATE) < DATEFROMPARTS(@Current_CampaignYear-1, 10, 01)) OR
	(ENR.[Enrolment Date] IS NULL AND CAST(TT1.[Election Date] AS DATE) < DATEFROMPARTS(@Current_CampaignYear-1, 10, 01))
	)
	THEN 'Y' ELSE 'N' END AS 'Election / Enrolment Exception'
,CASE
	WHEN CORP.Contact_ID IS NOT NULL
	OR APPR.Rics_contactno IS NOT NULL
	OR CONCSPCL.Rics_contactno IS NOT NULL
	OR TT1.Designation = 'Honorary'
	OR NOT(
		 (ENR.[Enrolment Date] IS NULL AND TT1.[Election Date] IS NULL) OR
		 (ENR.[Enrolment Date] IS NULL OR CAST(ENR.[Enrolment Date] AS DATE) < DATEFROMPARTS(@Current_CampaignYear-1, 10, 01)) OR
		 (ENR.[Enrolment Date] IS NULL AND CAST(TT1.[Election Date] AS DATE) < DATEFROMPARTS(@Current_CampaignYear-1, 10, 01))
		 )
	THEN 'Y' ELSE 'N' END AS 'Excluded from Consideration'
,CASE WHEN [Member Quote Position] IS NULL 
		OR [Member Quote Position] IN ('Fully Credited', 'No Quote', 'Closed', 'Draft') 
	  THEN 'Y' ELSE 'N' END AS 'Invalid Quote'
,CASE WHEN [Member Quote Position] = 'Active' THEN 'Y' ELSE 'N' END AS 'Active Quote only'
,CASE WHEN [Member Invoice Position] = 'No Payment' THEN 'Y' ELSE 'N' END AS 'No Payment'
,CASE WHEN [Member Invoice Position] = 'Partially Paid' THEN 'Y' ELSE 'N' END AS 'Partially Paid'
,CASE
	WHEN CORP.Contact_ID IS NOT NULL
		OR APPR.Rics_contactno IS NOT NULL
		OR CONCSPCL.Rics_contactno IS NOT NULL
		OR TT1.Designation = 'Honorary'
		OR NOT(
			 (ENR.[Enrolment Date] IS NULL AND TT1.[Election Date] IS NULL) OR
			 (ENR.[Enrolment Date] IS NULL OR CAST(ENR.[Enrolment Date] AS DATE) < DATEFROMPARTS(@Current_CampaignYear-1, 10, 01)) OR
			 (ENR.[Enrolment Date] IS NULL AND CAST(TT1.[Election Date] AS DATE) < DATEFROMPARTS(@Current_CampaignYear-1, 10, 01))
			 )
		THEN 'Excluded from Consideration'
	WHEN [Member Quote Position] IS NULL 
		OR [Member Quote Position] IN ('Fully Credited', 'No Quote', 'Closed', 'Draft') 
		THEN 'Invalid Quote'
	WHEN [Member Quote Position] = 'Active'
		THEN 'Active Quote Only'
	WHEN [Member Invoice Position] = 'No Payment'
		THEN 'No Payment'
	WHEN [Member Invoice Position] = 'Partially Paid'
		THEN 'Partially Paid'
	ELSE 'No Issue'
	END AS 'Member Subs Status'
,ENR_Last.[Enrolment Date] AS [Latest_Enrolment_Date]
INTO #FINAL
FROM #TT1 TT1
LEFT JOIN #CORP CORP 
	ON CORP.Contact_ID = TT1.[Contact ID]
LEFT JOIN #ENR ENR
	ON ENR.[Contact No] = TT1.[Contact No]
LEFT JOIN #ENR_LAST ENR_Last
	ON ENR_Last.[Contact No] = TT1.[Contact No]

LEFT JOIN #APPR APPR
	ON APPR.rics_contactno = TT1.[Contact No]
LEFT JOIN #CONCSPCL CONCSPCL
	ON CONCSPCL.Rics_contactno = TT1.[Contact No]
LEFT JOIN #VALIDQUOTE Q
	ON Q.Contact_No = TT1.[Contact No]
LEFT JOIN #MEMSTAT MS
	ON MS.[Contact No.] = TT1.[Contact No]
LEFT JOIN #CONC CONC
	ON TT1.[Contact No] = CONC.Rics_contactno
LEFT JOIN #QUO QUO
	ON QUO.Contact_No = TT1.[Contact No]
LEFT JOIN #INV INV
	ON INV.[Account Num] = TT1.[Contact No]
	AND INV.[Inv Member Invoice Position] = MS.[Member Invoice Position]
	
	--DROP TABLE Subs.tblSubsCommsChase SELECT * INTO Subs.tblSubsCommsChase FROM #FINAL
TRUNCATE TABLE Subs.tblSubsCommsChase

INSERT INTO Subs.tblSubsCommsChase (
	 [Contact No]
	,[Contact ID]
	,[Campaign Year]
	,[First Name]
	,[Surname]
	,[Mail Name]
	,[Currency (Contact)]
	,[Payment Method (Contact)]
	,[PayCycle (Contact)]
	,[Prevent Lapse]
	,[Account Name]
	,[Address Line 1]
	,[Address Line 2]
	,[Address Line 3]
	,[County]
	,[City]
	,[Country]
	,[Postcode]
	,[Local Group ID]
	,[Member Grade]
	,[Designation]
	,[Mobile Phone]
	,[Salutation]
	,[Email Address]
	,[Do Not Chase Reason]
	,[Hardcopy Subs]
	,[Visual Disability]
	,[Lapsed Reason]
	,[Contact_No]
	,[Quote Number]
	,[Quote Created]
	,[Quote Currency]
	,[Line Amount CUR]
	,[LHL Amount CUR]
	,[Surcharge Amount CUR]
	,[Total Amount CUR]
	,[Quote Payment Method]
	,[Quote State]
	,[Account Num]
	,[Inv Full Amount CUR]
	,[Inv Settle Amount CUR]
	,[Inv Full Balance CUR]
	,[Invoice]
	,[Invoice Date]
	,[Invoice Currency]
	,[Invoice Payment Method]
	,[Payment Status]
	,[Last Settle Date]
	,[Inv Member Invoice Position]
	,[Concession]
	,[First_Enrolment_Date]
	,[First_Election_Date]
	,[Is Lapsed]
	,[Member Quote Position]
	,[Member Invoice Position]
	,[Corporate Member]
	,[Current Apprentice]
	,[Special Concession]
	,[Honorary Member]
	,[Election / Enrolment Exception]
	,[Excluded from Consideration]
	,[Invalid Quote]
	,[Active Quote only]
	,[No Payment]
	,[Partially Paid]
	,[Member Subs Status]
	,[Latest_Enrolment_Date]
	)

SELECT
     [Contact No]
	,[Contact ID]
	,[Campaign Year]
	,[First Name]
	,[Surname]
	,[Mail Name]
	,[Currency (Contact)]
	,[Payment Method (Contact)]
	,[PayCycle (Contact)]
	,[Prevent Lapse]
	,[Account Name]
	,[Address Line 1]
	,[Address Line 2]
	,[Address Line 3]
	,[County]
	,[City]
	,[Country]
	,[Postcode]
	,[Local Group ID]
	,[Member Grade]
	,[Designation]
	,[Mobile Phone]
	,[Salutation]
	,[Email Address]
	,[Do Not Chase Reason]
	,[Hardcopy Subs]
	,[Visual Disability]
	,[Lapsed Reason]
	,[Contact_No]
	,[Quote Number]
	,[Quote Created]
	,[Quote Currency]
	,[Line Amount CUR]
	,[LHL Amount CUR]
	,[Surcharge Amount CUR]
	,[Total Amount CUR]
	,[Quote Payment Method]
	,[Quote State]
	,[Account Num]
	,[Inv Full Amount CUR]
	,[Inv Settle Amount CUR]
	,[Inv Full Balance CUR]
	,[Invoice]
	,[Invoice Date]
	,[Invoice Currency]
	,[Invoice Payment Method]
	,[Payment Status]
	,[Last Settle Date]
	,[Inv Member Invoice Position]
	,[Concession]
	,[First_Enrolment_Date]
	,[First_Election_Date]
	,[Is Lapsed]
	,[Member Quote Position]
	,[Member Invoice Position]
	,[Corporate Member]
	,[Current Apprentice]
	,[Special Concession]
	,[Honorary Member]
	,[Election / Enrolment Exception]
	,[Excluded from Consideration]
	,[Invalid Quote]
	,[Active Quote only]
	,[No Payment]
	,[Partially Paid]
	,[Member Subs Status]
	,[Latest_Enrolment_Date]
FROM #FINAL

END
