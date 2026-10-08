CREATE   PROCEDURE [Subs].[usp_Refresh_SubsMemberStatuses] AS 
BEGIN

DROP TABLE IF EXISTS #QUO
	SELECT
	 Contact_No
	,Campaign_Year
	,COUNT(Quote_ID) AS 'Quote Count'
	,SUM(CASE WHEN Quote_State = 'Active' THEN 1 ELSE 0 END) AS 'Quote Active Count'
	,SUM(CASE WHEN Quote_State = 'Won' THEN 1 ELSE 0 END) AS 'Quote Won Count'
	,SUM(CASE WHEN Quote_State = 'Draft' THEN 1 ELSE 0 END) AS 'Quote Draft Count'
	,SUM(CASE WHEN Quote_State = 'Closed' THEN 1 ELSE 0 END) AS 'Quote Closed Count'
	,SUM(CASE WHEN Quote_State = 'Won' THEN Quote_Amount_GBP ELSE 0 END) AS 'Quote Won Amount'
	,SUM(CASE WHEN Quote_State = 'Fully Credited' THEN Quote_Amount_GBP ELSE 0 END) AS 'Quote Fully Credited Amount'
	INTO #QUO
	FROM Subs.tblSubsQuotes
	GROUP BY Contact_No, Campaign_Year

DROP TABLE IF EXISTS #INV
	SELECT
	 INV.Account_Num
	,INV.Campaign_Year
	,COUNT(Invoice) AS 'Invoice Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Fully Credited' THEN 1 ELSE 0 END) AS 'Inv Fully Credited Count'
	,SUM(CASE WHEN INV.Payment_Status = 'No Payment' THEN 1 ELSE 0 END) AS 'Inv No Payment Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Zero Value Invoice' THEN 1 ELSE 0 END) AS 'Inv Zero Value Invoice Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Full Concession' THEN 1 ELSE 0 END) AS 'Inv Full Concession Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Partially Paid' THEN 1 ELSE 0 END) AS 'Inv Partially Paid Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Pre-Subs Payment' THEN 1 ELSE 0 END) AS 'Inv Pre-Subs Payment Count'
	,SUM(CASE WHEN INV.Payment_Status = 'Fully Paid' THEN 1 ELSE 0 END) AS 'Inv Fully Paid Count'
	,SUM(CASE WHEN INV.Payment_Status <> 'Fully Credited' THEN Invoice_Amount_GBP ELSE 0 END) AS 'Inv Total Amount'
	,SUM(CASE WHEN INV.Payment_Status <> 'Fully Credited' THEN Paid_Amount_GBP ELSE 0 END) AS 'Inv Paid Amount'
	,SUM(CASE WHEN INV.Payment_Status = 'Fully Paid' THEN Paid_Amount_GBP ELSE 0 END) AS 'Inv Fully Paid Amount'
	,SUM(CASE WHEN INV.Payment_Status = 'Partially Paid' THEN Paid_Amount_GBP ELSE 0 END) AS 'Inv Partially Paid Amount'
	,SUM(CASE WHEN INV.Payment_Status <> 'Fully Credited' THEN Balance_GBP ELSE 0 END) AS 'Inv Balance Amount'
	,SUM(CASE WHEN INV.Payment_Status <> 'Fully Credited' AND Has_Concession = 'Y' THEN 1 ELSE 0 END) AS 'Has Conc. Count'
	,SUM(CASE WHEN INV.Payment_Status <> 'Fully Credited' AND Retired_Concession = 'Retired Conc.' THEN 1 ELSE 0 END) AS 'Retired Conc Count'
	-- Raj M, 2029-09-09   Bad Debt Write Off
	,SUM(CASE WHEN INV.Payment_Status = 'Bad Debt Write Off' THEN 1 ELSE 0 END) AS 'Bad Debt Write Off Count'
	INTO #INV
	FROM [Subs].tblSubsInvoices INV
	GROUP BY INV.Account_Num, INV.Campaign_Year

DROP TABLE IF EXISTS #FIRSTPAY
	SELECT 
	 Contact_No
	,Campaign_Year
	,MIN(Trans_Date) AS Trans_Date_Min
	,MIN(Trans_Date_Adj) AS Trans_Date_Adj_Min
	INTO #FIRSTPAY
	FROM Subs.tblSubsPayments
	WHERE Payment_Status IN ('Fully Paid', 'Partially Paid', 'Pre-Subs Payment')
	GROUP BY Contact_No, Campaign_Year

DROP TABLE IF EXISTS #MINVOICECONC
	SELECT 
	 Account_Num
	,Campaign_Year
	,CASE
		WHEN MIN(Trans_Date) < DATEFROMPARTS(Campaign_Year-1, 10, 1) THEN DATEFROMPARTS(Campaign_Year-1, 10, 1)
		WHEN MIN(Trans_Date) > DATEFROMPARTS(Campaign_Year, 9, 30) THEN DATEFROMPARTS(Campaign_Year, 9, 30)
		ELSE MIN(Trans_Date) END AS 'Trans_Date_Min'	
	INTO #MINVOICECONC
	FROM Subs.tblSubsInvoices
	WHERE Payment_Status = 'Full Concession'
	GROUP BY Account_Num, Campaign_Year

DROP TABLE IF EXISTS #MEM
	SELECT
	 Contact_No AS 'Contact No.'
	,Campaign_Year AS 'Campaign Year'
	INTO #MEM
	FROM Subs.tblSubsOmni
	GROUP BY Contact_No, Campaign_Year
	UNION
	SELECT  --Grabs anyone who Engaged Payment in the previous Subs Year, but hasn't appeared this Subs Year yet
	 Contact_No
	,Campaign_Year + 1
	FROM Subs.tblSubsOmni OMI
	LEFT JOIN CE.vwContact CON 
		ON CON.Rics_contactno = OMI.Contact_No
	WHERE Payment_Status IN ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment')
	AND Campaign_Year < CASE WHEN MONTH(GETDATE()) >= 10 THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END
	AND (
	Rics_LapsedDate IS NULL OR 
	(Campaign_Year <> CASE WHEN MONTH(CON.Rics_LapsedDate) >= 10 THEN YEAR(CON.Rics_LapsedDate)+1 ELSE YEAR(CON.Rics_LapsedDate) END) --Ignore those that lapsed in a year after they had Paid
	)
	UNION
	SELECT --One off for 2022 cohort: Grab all renewals from 2021 campaign which do not show up in 2022 campaign
	 MOO.rics_contactno
	,SubsCampaign_Plus_One
	 FROM Subs.tblMovementDefinition2021 MOO
	WHERE NOT EXISTS (
		SELECT Contact_No
		FROM Subs.tblSubsOmni OMNI
		WHERE OMNI.Contact_No = MOO.rics_contactno
		AND Campaign_Year = 2022
		)

DROP TABLE IF EXISTS #CONRETIRED
	SELECT 
	 Rics_contactno
	,apuk_subscriptionyear
	,apuk_perpetualnonperpetual
	,apuk_perpetualnonperpetual_description
	,statecode
	INTO #CONRETIRED
	FROM CE.vwConcession
	WHERE Product_Number IN (
		'rcsCONPWRQ2'
		,'rcsCONPWRQ3'
		,'rcsCONRETIREDSPECIAL'
		,'rcsCONPWRQ1'
		,'rcsCONRETIREDFL'
		,'rcsCONRETIRED'
		)
	AND statecode = 0

DROP TABLE IF EXISTS #MEMTWO
	SELECT
	 [Contact No.]
	,[Campaign Year]
	,CASE
		WHEN [Invoice Count] IS NULL THEN 'No Invoice'
		WHEN [Inv Full Concession Count] > 0 THEN 'Full Concession'
		WHEN [Inv Fully Paid Count] > 0 THEN 'Fully Paid'
		WHEN [Inv Partially Paid Count] > 0 THEN 'Partially Paid'
		WHEN [Inv Pre-Subs Payment Count] > 0 THEN 'Pre-Subs Payment'
		WHEN [Inv No Payment Count] > 0 THEN 'No Payment'
		WHEN [Inv Fully Credited Count] > 0 THEN 'Fully Credited'
		WHEN [Inv Zero Value Invoice Count] > 0 THEN 'Zero Value Invoice'
		-- Raj M, 2026-09-09 Bad Debt Write Off
		WHEN [Bad Debt Write Off Count] > 0 THEN 'Bad Debt Write Off'
		END AS 'Member Invoice Position'
	,CASE
		WHEN COALESCE(CRET1.Rics_contactno, CRET2.Rics_contactno) IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Retired Concession True'
	INTO #MEMTWO
	FROM #MEM MEM
		LEFT JOIN #INV INV
		ON INV.Account_Num = MEM.[Contact No.]
		AND INV.Campaign_Year = MEM.[Campaign Year]
		LEFT JOIN #CONRETIRED CRET1
		ON MEM.[Contact No.] = CRET1.Rics_contactno
			AND CRET1.apuk_subscriptionyear = MEM.[Campaign Year]
			AND CRET1.apuk_perpetualnonperpetual = 200000001 --Non-Perpetual
		LEFT JOIN #CONRETIRED CRET2
		ON MEM.[Contact No.] = CRET2.Rics_contactno
			AND CRET2.apuk_subscriptionyear <= MEM.[Campaign Year]
			AND CRET2.apuk_perpetualnonperpetual = 200000000 --Perpetual
	GROUP BY 
		[Contact No.]
	,[Campaign Year]
	,CASE
		WHEN [Invoice Count] IS NULL THEN 'No Invoice'
		WHEN [Inv Full Concession Count] > 0 THEN 'Full Concession'
		WHEN [Inv Fully Paid Count] > 0 THEN 'Fully Paid'
		WHEN [Inv Partially Paid Count] > 0 THEN 'Partially Paid'
		WHEN [Inv Pre-Subs Payment Count] > 0 THEN 'Pre-Subs Payment'
		WHEN [Inv No Payment Count] > 0 THEN 'No Payment'
		WHEN [Inv Fully Credited Count] > 0 THEN 'Fully Credited'
		WHEN [Inv Zero Value Invoice Count] > 0 THEN 'Zero Value Invoice'
		-- Raj M, 2026-09-09 Bad Debt Write Off
		WHEN [Bad Debt Write Off Count] > 0 THEN 'Bad Debt Write Off'
		END
	,CASE
		WHEN COALESCE(CRET1.Rics_contactno, CRET2.Rics_contactno) IS NOT NULL THEN 'Y' ELSE 'N' END

DROP TABLE IF EXISTS #RETIREDFIRSTTEAR
	SELECT
	 Rics_contactno
	,MIN(apuk_subscriptionyear) AS 'First_Retired_Year'
	INTO #RETIREDFIRSTTEAR
	FROM CE.vwConcession
	WHERE Product_Number IN ( 
	 'rcsCONPWRQ2'
	,'rcsCONPWRQ3'
	,'rcsCONRETIREDSPECIAL'
	,'rcsCONPWRQ1'
	,'rcsCONRETIREDFL'
	,'rcsCONRETIRED'
	)
	GROUP BY Rics_contactno

DROP TABLE IF EXISTS #TEMP
	SELECT
	 MEMTWO.[Contact No.]
	,MEMTWO.[Campaign Year]
	,CASE
		WHEN MEMTWO.[Campaign Year] = 2022 AND MOV.rics_contactno IS NOT NULL THEN 'Renewal'
		WHEN MEMTWO.[Campaign Year] = 2022 AND MOV.rics_contactno IS NULL THEN 'New'
		WHEN MEMTHREE.[Member Invoice Position] IN ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment')
		THEN 'Renewal' ELSE 'New' END AS 'Movement'
	,QUO.[Quote Count]
	,QUO.[Quote Active Count]
	,QUO.[Quote Won Count]
	,QUO.[Quote Draft Count]
	,QUO.[Quote Closed Count]
	,QUO.[Quote Won Amount]
	,QUO.[Quote Fully Credited Amount]
	,CASE
		WHEN QUO.[Quote Count] IS NULL THEN 'No Quote'
		WHEN QUO.[Quote Won Count] > 0 THEN 'Won'
		WHEN QUO.[Quote Active Count] > 0 THEN 'Active'
		WHEN QUO.[Quote Draft Count] > 0 THEN 'Draft'
		WHEN QUO.[Quote Closed Count] > 0 THEN 'Closed'
		WHEN QUO.[Quote Fully Credited Amount] > 0 THEN 'Fully Credited'
		END AS 'Member Quote Position' 
	,CASE WHEN QUO.[Quote Count] IS NULL THEN 'N' ELSE 'Y' END AS 'Has Quote'
	,CASE WHEN QUO.[Quote Won Count] > 0 THEN 'Y' ELSE 'N' END AS 'Has Won Quote'
	,INV.[Invoice Count]
	,INV.[Inv Full Concession Count]
	,INV.[Inv Fully Paid Count]
	,INV.[Inv Partially Paid Count]
	,INV.[Inv No Payment Count]
	,INV.[Inv Fully Credited Count]
	,INV.[Inv Zero Value Invoice Count]
	,INV.[Inv Total Amount]
	,INV.[Inv Paid Amount]
	,INV.[Inv Fully Paid Amount]
	,INV.[Inv Partially Paid Amount]
	,INV.[Inv Balance Amount]
	,MEMTWO.[Member Invoice Position]
	,CASE
		WHEN INV.Account_Num IS NULL THEN NULL
		WHEN [Has Conc. Count] > 0 THEN 'Y' ELSE 'N' END AS 'Has Concession'
	,CASE 
		WHEN INV.Account_Num IS NULL THEN 'No Invoice'
		WHEN [Has Conc. Count] = 0 THEN 'No Conc.'
		WHEN [Retired Conc Count] > 0 THEN 'Retired Conc.' ELSE 'Non-Retired Conc.' 
		END AS 'Retired Concession'
	,MEMTWO.[Retired Concession True]
	,COALESCE(MONC.Trans_Date_Min, FPAY.Trans_Date_Min) AS 'Renewal Date'
	,COALESCE(MONC.Trans_Date_Min, FPAY.Trans_Date_Adj_Min) AS 'Renewal Date Adj'
	,RFY.First_Retired_Year AS 'First Retired Year'

	INTO #TEMP
	FROM #MEMTWO MEMTWO
	LEFT JOIN #QUO QUO
		ON QUO.Contact_No = MEMTWO.[Contact No.]
		AND QUO.Campaign_Year = MEMTWO.[Campaign Year]
	LEFT JOIN #INV INV
		ON INV.Account_Num = MEMTWO.[Contact No.]
		AND INV.Campaign_Year = MEMTWO.[Campaign Year]
	LEFT JOIN #MEMTWO MEMTHREE
		ON MEMTHREE.[Contact No.] = MEMTWO.[Contact No.]
		AND MEMTHREE.[Campaign Year]  = MEMTWO.[Campaign Year]-1
	LEFT JOIN #FIRSTPAY FPAY
		ON FPAY.Contact_No = MEMTWO.[Contact No.]
		AND FPAY.Campaign_Year = MEMTWO.[Campaign Year]
	LEFT JOIN #MINVOICECONC MONC
		ON MONC.Account_Num = MEMTWO.[Contact No.]
		AND MONC.Campaign_Year = MEMTWO.[Campaign Year]
	LEFT JOIN Subs.tblMovementDefinition2021 MOV
		ON MOV.rics_contactno = MEMTWO.[Contact No.]
		AND MOV.SubsCampaign + 1 = MEMTWO.[Campaign Year]
	LEFT JOIN #RETIREDFIRSTTEAR RFY 
		ON RFY.Rics_contactno = MEMTWO.[Contact No.]
		AND [Retired Conc Count] > 0

--DROP TABLE Subs.tblSubsMemberStatuses SELECT * INTO Subs.tblSubsMemberStatuses FROM #TEMP

TRUNCATE TABLE Subs.tblSubsMemberStatuses

INSERT INTO Subs.tblSubsMemberStatuses (
	 [Contact No.]
	,[Campaign Year]
	,[Movement]
	,[Quote Count]
	,[Quote Active Count]
	,[Quote Won Count]
	,[Quote Draft Count]
	,[Quote Closed Count]
	,[Quote Won Amount]
	,[Quote Fully Credited Amount]
	,[Member Quote Position]
	,[Has Quote]
	,[Has Won Quote]
	,[Invoice Count]
	,[Inv Full Concession Count]
	,[Inv Fully Paid Count]
	,[Inv Partially Paid Count]
	,[Inv No Payment Count]
	,[Inv Fully Credited Count]
	,[Inv Zero Value Invoice Count]
	,[Inv Total Amount]
	,[Inv Paid Amount]
	,[Inv Fully Paid Amount]
	,[Inv Partially Paid Amount]
	,[Inv Balance Amount]
	,[Member Invoice Position]
	,[Has Concession]
	,[Retired Concession]
	,[Retired Concession True]
	,[Renewal Date]
	,[Renewal Date Adj]
	,[First Retired Year]
	)

SELECT
	 [Contact No.]
	,[Campaign Year]
	,[Movement]
	,[Quote Count]
	,[Quote Active Count]
	,[Quote Won Count]
	,[Quote Draft Count]
	,[Quote Closed Count]
	,[Quote Won Amount]
	,[Quote Fully Credited Amount]
	,[Member Quote Position]
	,[Has Quote]
	,[Has Won Quote]
	,[Invoice Count]
	,[Inv Full Concession Count]
	,[Inv Fully Paid Count]
	,[Inv Partially Paid Count]
	,[Inv No Payment Count]
	,[Inv Fully Credited Count]
	,[Inv Zero Value Invoice Count]
	,[Inv Total Amount]
	,[Inv Paid Amount]
	,[Inv Fully Paid Amount]
	,[Inv Partially Paid Amount]
	,[Inv Balance Amount]
	,[Member Invoice Position]
	,[Has Concession]
	,[Retired Concession]
	,[Retired Concession True]
	,[Renewal Date]
	,[Renewal Date Adj]
	,[First Retired Year]
	FROM #TEMP

END
