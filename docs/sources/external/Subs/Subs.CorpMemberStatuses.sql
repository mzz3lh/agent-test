CREATE VIEW Subs.CorpMemberStatuses AS

WITH QUO AS (
	SELECT
	 [Contact No]
	,[Scheme No]
	,[Sub Campaign Year]
	,[Round]
	,COUNT([Quote ID]) AS 'Quote Count'
	,SUM(CASE WHEN [Quote State] = 'Active' THEN 1 ELSE 0 END) AS 'Quote Active Count'
	,SUM(CASE WHEN [Quote State] = 'Won' AND [Quote Amount CUR] = 0 THEN 1 ELSE 0 END) AS 'Quote Won Full Conc Count'
	,SUM(CASE WHEN [Quote State] = 'Won' THEN 1 ELSE 0 END) AS 'Quote Won Count'
	,SUM(CASE WHEN [Quote State] = 'Draft' THEN 1 ELSE 0 END) AS 'Quote Draft Count'
	,SUM(CASE WHEN [Quote State] = 'Closed' THEN 1 ELSE 0 END) AS 'Quote Closed Count'
	,SUM(CASE WHEN [Quote State] = 'Fully Credited' THEN 1 ELSE 0 END) AS 'Quote Fully Credited Count'
	FROM Subs.tblCorp_Cost_Breakdown
	WHERE [Valid Quote] = 'Y'
	GROUP BY [Contact No], [Scheme No], [Scheme Name], [Sub Campaign Year], [Round]
)
,INV AS (
	SELECT
	 INV.[Contact No]
	,[Scheme No]
	,INV.[Sub Campaign Year]
	,INV.[Round]
	,COUNT(Invoice) AS 'Invoice Count'
	,SUM(CASE WHEN INV.[Payment Status] = 'Fully Credited' THEN 1 ELSE 0 END) AS 'Inv Fully Credited Count'
	,SUM(CASE WHEN INV.[Payment Status] = 'No Payment' THEN 1 ELSE 0 END) AS 'Inv No Payment Count'
	,SUM(CASE WHEN INV.[Payment Status] = 'Zero Value Invoice' THEN 1 ELSE 0 END) AS 'Inv Zero Value Invoice Count'
	,SUM(CASE WHEN INV.[Payment Status] = 'Full Concession' THEN 1 ELSE 0 END) AS 'Inv Full Concession Count'
	,SUM(CASE WHEN INV.[Payment Status] = 'Partially Paid' THEN 1 ELSE 0 END) AS 'Inv Partially Paid Count'
	,SUM(CASE WHEN INV.[Payment Status] = 'Pre-Subs Payment' THEN 1 ELSE 0 END) AS 'Inv Pre-Subs Payment Count'
	,SUM(CASE WHEN INV.[Payment Status] = 'Fully Paid' THEN 1 ELSE 0 END) AS 'Inv Fully Paid Count'
	,SUM(CASE WHEN INV.[Payment Status] <> 'Fully Credited' THEN [Inv Full Amount CUR] ELSE 0 END) AS 'Inv Total Amount'
	,SUM(CASE WHEN INV.[Payment Status] <> 'Fully Credited' THEN [Paid Amount CUR] ELSE 0 END) AS 'Inv Paid Amount'
	--,SUM(CASE WHEN INV.[Payment Status] = 'Fully Paid' THEN Paid_Amount_GBP ELSE 0 END) AS 'Inv Fully Paid Amount'
	--,SUM(CASE WHEN INV.[Payment Status] = 'Partially Paid' THEN Paid_Amount_GBP ELSE 0 END) AS 'Inv Partially Paid Amount'
	,SUM(CASE WHEN INV.[Payment Status] <> 'Fully Credited' THEN [Balance CUR] ELSE 0 END) AS 'Inv Balance Amount'
	FROM Subs.tblCorp_Cost_Breakdown INV
	WHERE [Valid Invoice] = 'Y'
	GROUP BY INV.[Contact No], [Scheme No], INV.[Sub Campaign Year], INV.[Round]
)

SELECT
 CCB.[Contact No]
,CCB.[Scheme No]
,CCB.[Scheme Name]
,CCB.[Sub Campaign Year]
,CCB.[Round]
,CCB.[Quote Expected]
--,COUNT(QUOTESOMETHING)
--,COUNT(INVOICESOMETHING)
,SUM(CASE WHEN CCB.[Sub User State] = 'Inactive' THEN 1 ELSE 0 END) AS 'Inactive Sub Count'
,SUM(CASE WHEN CCB.[Valid Quote] = 'Y' AND CCB.[Quote State] IN ('Won', 'Active') THEN 1 ELSE 0 END) AS 'Valid Quote Count'
,SUM(CASE WHEN CCB.[Valid Invoice] = 'Y' AND CCB.[Quote State] IN ('Won', 'Active') THEN 1 ELSE 0 END) AS 'Valid Invoice Count'

,SUM(CASE WHEN CCB.[Valid Quote] = 'Y' AND CCB.[Quote State] IN ('Won', 'Active') THEN CCB.[Quote Amount CUR] END) AS 'Quote Amount CUR'
,SUM(CASE WHEN CCB.[Valid Quote] = 'Y' AND CCB.[Quote State] IN ('Won', 'Active') THEN CCB.[Quote Amount GBP] END) AS 'Quote Amount GBP'

,SUM(CASE WHEN CCB.[Valid Invoice] = 'Y' AND [Payment Status] <> 'Fully Credited' THEN CCB.[Inv Full Amount CUR] END) AS 'Invoice Amount CUR'
,SUM(CASE WHEN CCB.[Valid Invoice] = 'Y' AND [Payment Status] <> 'Fully Credited' THEN CCB.[Inv Full Amount GBP] END) AS 'Invoice Amount GBP'
,SUM(CASE WHEN CCB.[Valid Invoice] = 'Y' AND [Payment Status] <> 'Fully Credited' THEN CCB.[Paid Amount CUR] END) AS 'Paid Amount CUR'
,SUM(CASE WHEN CCB.[Valid Invoice] = 'Y' AND [Payment Status] <> 'Fully Credited' THEN CCB.[Paid Amount GBP] END) AS 'Paid Amount GBP'
,SUM(CASE WHEN CCB.[Valid Invoice] = 'Y' AND [Payment Status] <> 'Fully Credited' THEN CCB.[Balance CUR] END) AS 'Invoice Balance CUR'
,SUM(CASE WHEN CCB.[Valid Invoice] = 'Y' AND [Payment Status] <> 'Fully Credited' THEN CCB.[Balance GBP] END) AS 'Invoice Balance GBP'

,CASE
	WHEN QUO.[Quote Count] IS NULL THEN 'No Quote'
	WHEN QUO.[Quote Won Full Conc Count] > 0 THEN 'Won (Full Conc.)'
	WHEN QUO.[Quote Won Count] > 0 THEN 'Won'
	WHEN QUO.[Quote Active Count] > 0 THEN 'Active'
	WHEN QUO.[Quote Draft Count] > 0 THEN 'Draft'
	WHEN QUO.[Quote Closed Count] > 0 THEN 'Closed'
	WHEN QUO.[Quote Fully Credited Count] > 0 THEN 'Fully Credited'
	END AS 'Member Quote Position' 
,CASE
	WHEN [Invoice Count] IS NULL THEN 'No Invoice'
	WHEN [Inv Full Concession Count] > 0 THEN 'Full Concession'
	WHEN [Inv Zero Value Invoice Count] > 0 THEN 'Zero Value Invoice'
	WHEN [Inv Fully Paid Count] > 0 THEN 'Fully Paid'
	WHEN [Inv Partially Paid Count] > 0 THEN 'Partially Paid'
	WHEN [Inv Pre-Subs Payment Count] > 0 THEN 'Pre-Subs Payment'
	WHEN [Inv No Payment Count] > 0 THEN 'No Payment'
	WHEN [Inv Fully Credited Count] > 0 THEN 'Fully Credited'
	END AS 'Member Invoice Position'
FROM [Subs].[tblCorp_Cost_Breakdown] CCB
LEFT JOIN QUO QUO
	ON CCB.[Contact No] = QUO.[Contact No]
	AND CCB.[Scheme No] = QUO.[Scheme No]
	AND CCB.[Sub Campaign Year] = QUO.[Sub Campaign Year]
	AND CCB.[Round] = QUO.[Round]
LEFT JOIN INV INV
	ON CCB.[Contact No] = INV.[Contact No]
	AND CCB.[Scheme No] = INV.[Scheme No]
	AND CCB.[Sub Campaign Year] = INV.[Sub Campaign Year]
	AND CCB.[Round] = INV.[Round]

WHERE CCB.[Sub Campaign Year] >= 2023 --TEMP
--AND CCB.[Scheme No] = 'SUB-0000000' --TEMP
GROUP BY
 CCB.[Contact No]
,CCB.[Contact ID]
,CCB.[Scheme No]
,CCB.[Scheme Name]
,CCB.[Sub Campaign Year]
,CCB.[Round]
,CCB.[Quote Expected]
,CASE
	WHEN QUO.[Quote Count] IS NULL THEN 'No Quote'
	WHEN QUO.[Quote Won Full Conc Count] > 0 THEN 'Won (Full Conc.)'
	WHEN QUO.[Quote Won Count] > 0 THEN 'Won'
	WHEN QUO.[Quote Active Count] > 0 THEN 'Active'
	WHEN QUO.[Quote Draft Count] > 0 THEN 'Draft'
	WHEN QUO.[Quote Closed Count] > 0 THEN 'Closed'
	WHEN QUO.[Quote Fully Credited Count] > 0 THEN 'Fully Credited'
	END
,CASE
	WHEN [Invoice Count] IS NULL THEN 'No Invoice'
	WHEN [Inv Full Concession Count] > 0 THEN 'Full Concession'
	WHEN [Inv Zero Value Invoice Count] > 0 THEN 'Zero Value Invoice'
	WHEN [Inv Fully Paid Count] > 0 THEN 'Fully Paid'
	WHEN [Inv Partially Paid Count] > 0 THEN 'Partially Paid'
	WHEN [Inv Pre-Subs Payment Count] > 0 THEN 'Pre-Subs Payment'
	WHEN [Inv No Payment Count] > 0 THEN 'No Payment'
	WHEN [Inv Fully Credited Count] > 0 THEN 'Fully Credited'
	END

--HAVING SUM(CASE WHEN [Valid Quote] = 'Y' AND [Quote State] IN ('Won', 'Active') THEN 1 ELSE 0 END) > 1

--SELECT * FROM Subs.tblCorp_Cost_Breakdown WHERE [Contact No] = '0000000' AND [Sub Campaign Year] = 2024
