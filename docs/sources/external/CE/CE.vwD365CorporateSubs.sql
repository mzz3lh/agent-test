CREATE  VIEW [CE].[vwD365CorporateSubs]
AS

--Get Users and firm name of the subscription
WITH cteUsers
AS
(
SELECT DISTINCT S.statuscode,
C.ContactId,
C.Rics_ContactNo AS ContactNo,
C.LastName,
C.FirstName,
C.MemberGrade_Description,
C.Rics_LapsedCode_Description AS LapsedCode,
SU.Created_On AS SUCreatedOn,
SUBSTRING(S.ricsv2_subscriptionsIDname,CHARINDEX('-',S.ricsv2_subscriptionsIDname)+2,200) AS SFirmName
FROM [CE].[vwSubscriptionUser] SU 
INNER JOIN [CE].[vwRicsv2Subscription] S
	ON SU.ricsv2_subscriptionID = S.ricsv2_subscriptionid
INNER JOIN [CE].[vwSubscriptionOwner] SO
	ON SO.ricsv2_contact= S.apuk_subscriptionownerId
INNER JOIN CE.vwContact C
	ON C.contactid = SU.ricsv2_contact

WHERE S.ricsv2_Subscriptionid IN (
		SELECT ricsv2_subscriptionid FROM [CE].[vwRicsv2Subscription] WHERE ricsv1_subscriptionProduct = '00000000-0000-0000-0000-000000000000')
		AND SU.statuscode = 1 --active
		--AND S.statuscode = 000000000  --Not Yet Active
),


--Get the Subs Aged Debt

cteData
AS
(
SELECT * --ContactNo,Surname,Forename,MemberGrade,SFirmName,[Debt Currency],[Balance (currency)] AS Amount,[Year]  
FROM
(
SELECT U.ContactID,
U.ContactNo,
U.LastNAme AS Surname,
U.FirstName AS Forename,
U.MemberGrade_Description AS MemberGrade,
U.SFirmName,
U.LapsedCode,
U.SUCreatedOn,
ISNULL(AD.Currency,'N/A')AS [Debt Currency],
CAST(AD.[Balance (currency)] AS NUMERIC (10,2)) AS Amount,--can take this as the balance
DATEPART(YYYY,[Due Date]) AS [Year]
FROM cteUsers U
LEFT JOIN  FinBi.vwD365SubscriptionOutstandingDebt AD
	ON U.ContactNo = AD.[Contact Number]
) T

PIVOT(
    SUM(amount)
    FOR Year IN (
		[2016],
		[2017],
		[2018],
		[2019],
        [2020], 
        [2021]
		)
) AS PivotTable

--To include the test quote
--UNION
--SELECT '00000000-0000-0000-0000-000000000000','0000000','Test 12','Data','Qualified Professional','A made up Company Ltd','ZAR',NULL,NULL,NULL,100.00,200.00,300.00
),
--SELECT * FROM cteData WHERE ContactNo = '0000000'

--Get the Upgrade Fee Aged Debt
cteUPGData
AS
(
SELECT *  
FROM
(
SELECT U.ContactID,
U.ContactNo,
U.LastNAme AS Surname,
U.FirstName AS Forename,
U.MemberGrade_Description AS MemberGrade,
U.SFirmName,
CT.AMOUNTCUR AS Amount,
DATEPART(YYYY,[TRANSDATE]) AS [Year]
FROM cteUsers U
LEFT JOIN  FO.vwCusttrans CT
	ON U.ContactNo = CT.[ACCOUNTNUM]
	WHERE RICINVOICETYPE = 'UPG'
	AND CLOSED = '01-JAN-1900'
) T

PIVOT(
    SUM(amount)
    FOR Year IN (
		[2018],
		[2019],
        [2020], 
        [2021]
		)
) AS PivotTable2
),

--SELECT * FROM cteUPGData

--Get the Corporate quotes
cteQuote
AS
(
SELECT Q.name,
Q.transactioncurrencyid,
C.rics_ContactNo,
Q.msdyn_isocurrencycode AS [Subs Currency],
Q.totallineitemamount AS [2022 - Subs],
Q.totallineitemamount_base,
Q.totalamount AS [2022 - Total],   --Q.apuk_totalprofessionalfees AS [2022 - Total], 
Q.apuk_totalprofessionalfees_base,
Q.apuk_lionheartdonation AS LionHeart,
CASE WHEN ISNULL(CT.ORDERNUM,'')  <>''-- IS NOT NULL
			THEN 'Yes'
			ELSE 'No'
			END AS HasInvoice,
CT.INVOICE AS InvoiceNo,
CT.TRANSDATE AS InvoiceDate
--Q.* 
FROM CE.vwQuote Q
INNER JOIN CE.vwContact C
	ON Q.customerid = C.contactid
LEFT JOIN CE.vwSalesOrder SO
	ON SO.quoteid = Q.quoteid
LEFT JOIN FO.vwCustTrans CT
	ON CT.ORDERNUM = SUBSTRING(SO.ordernumber,4,200)
WHERE 1=1
AND Q.customerid IN (SELECT ContactID FROM cteUsers)  --OR  Q.customerid  = '00000000-0000-0000-0000-000000000000')
AND Q.apuk_campaignyear = 2022
AND Q.apuk_paymentmethod = 200000001 --Corporate
AND Q.statecode IN (1, 2)  -- 2=Won
AND Q.statuscode IN (3,4)  --4=Won        --3 =Open     --2  =in progress 
),

--SELECT * FROM cteQuote



--Get the Upgrade Fee's on the current quotes
cteUPG
AS
(
SELECT C.rics_ContactNo,ISNULL(QD.extendedamount,0.00) AS [2022 - UPG]
FROM CE.vwQuote Q
INNER JOIN CE.vwContact C
	ON Q.customerid = C.contactid
INNER JOIN CE.vwQuoteDetail QD
	ON Q.quoteid = QD.quoteid
WHERE QD.productname LIKE '%Upgrade%'
),

--SELECT * FROM cteUPG



--Final Query cte
cteFinal
AS
(
SELECT 
#.ContactNo,
#.Surname,
#.Forename,
#.MemberGrade,
#.LapsedCode,
#.SFirmName,
#.[Debt Currency],
#.SUCreatedOn,
CAST(ISNULL(#.[2016],0.00) AS NUMERIC (10,2)) AS [2016],
CAST(ISNULL(#.[2017],0.00) AS NUMERIC (10,2)) AS [2017],
CAST(ISNULL(#.[2018],0.00) AS NUMERIC (10,2)) AS [2018],
CAST(ISNULL(UPGD.[2018],0.00) AS NUMERIC (10,2)) AS [2018 UPG],
CAST(ISNULL(#.[2019],0.00) AS NUMERIC (10,2)) AS [2019],
CAST(ISNULL(UPGD.[2019],0.00) AS NUMERIC (10,2)) AS [2019 UPG],
CAST(ISNULL(#.[2020],0.00) AS NUMERIC (10,2)) AS [2020],
CAST(ISNULL(UPGD.[2020],0.00) AS NUMERIC (10,2)) AS [2020 UPG],
CAST(ISNULL(#.[2021],0.00) AS NUMERIC (10,2)) AS [2021],
CAST(ISNULL(UPGD.[2021],0.00) AS NUMERIC (10,2)) AS [2021 UPG],
[Subs Currency], 
[2022 - Subs] - ISNULL([2022 - UPG],0.00) AS [2022 - Subs], 
ISNULL([LionHeart],0.00) AS LionHeart,
ISNULL([2022 - UPG],0.00) AS [2022 - UPG],
[2022 - Total],
HasInvoice,
InvoiceNo,
InvoiceDate

FROM cteData #
LEFT JOIN cteQuote
	ON cteQuote.rics_contactNo = #.ContactNo
LEFT JOIN cteUPGData UPGD
	ON #.ContactNo = UPGD.ContactNo
	LEFT JOIN cteUPG UGP
ON UGP.Rics_contactno = #.ContactNo

)
--SELECT * FROM cteFinal


--Final View SELECT
SELECT DISTINCT ContactNo,
Surname,
Forename,
MemberGrade,
SFirmName,
LapsedCode,
[Debt Currency],
[2016],
[2017],
[2018],
[2018 UPG],
[2019],
[2019 UPG],
[2020],
[2020 UPG],
CASE WHEN HasInvoice = 'Yes'
	THEN [2021]-[2022 - Subs]
	ELSE [2021]
END AS [2021],
[2021 UPG],
[Subs Currency],
CASE WHEN
HasInvoice IS NULL AND LapsedCode IS NULL
THEN 0.00
ELSE [2022 - Subs]
END AS [2022 - Subs],
[LionHeart],
[2022 - UPG],
[2022 - Total],
--[2016] + [2017] + [2018] + [2018 UPG] + [2019] + [2019 UPG] + [2020] + [2020 UPG] + [2021] + [2021 UPG] + [2022 - Subs] + [LionHeart] + [2022 - UPG] AS [All Years Total],
CASE WHEN [2016] + [2017] + [2018] + [2018 UPG] + [2019] + [2019 UPG] + [2020] + [2020 UPG] + [2021] + [2021 UPG] >0
			THEN 'Yes'
			ELSE 'No'
END AS [Has OS Debt],
CASE WHEN [subs Currency] IS NOT NULL
			THEN 'Yes'
			ELSE 'No'
END AS [Has Current Debt],
HasInvoice,
InvoiceNo,
InvoiceDate,
SUCreatedOn
--INTO #Data
FROM cteFinal
