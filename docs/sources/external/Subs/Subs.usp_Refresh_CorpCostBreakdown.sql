CREATE PROCEDURE [Subs].[usp_Refresh_CorpCostBreakdown]
AS 
BEGIN

	DROP TABLE IF EXISTS #CSUB
	SELECT * 
	INTO #CSUB
	FROM Subs.vwCorpSubscriptions

	DROP TABLE IF EXISTS #QUO
	SELECT * 
	INTO #QUO
	FROM Subs.vwCorpQuotes

	DROP TABLE IF EXISTS #INV
	SELECT
	 [Quote ID]
	,[Invoice]
	,[Inv Full Amount CUR]
	,[Inv Full Amount GBP]
	,[Settle Amount CUR]
	,[Settle Amount GBP]
	,[Paid Amount CUR]
	,[Paid Amount GBP]
	,[Balance CUR]
	,[Balance GBP]
	,[Open Balance]
	,[Open Balance GBP]
	,[Credit Amount CUR]
	,[Credit Amount GBP]
	,[Fully Credited]
	,[Payment Method]
	,[Payment Status]
	INTO #INV
	FROM Subs.vwCorpInvoices

	DROP TABLE IF EXISTS #TT
	SELECT 
	 CSUB.[Contact No]
	,CSUB.[Contact ID]
	,CSUB.[Scheme No]
	,CSUB.[Scheme Name]
	,CSUB.[Sub Start Date]
	,CSUB.[Sub End Date]
	,CSUB.[Sub State]
	,CSUB.[Sub Status]
	,CSUB.[Sub Campaign Year]
	,CSUB.[Quote Expected]
	,COALESCE(QUO.[Quote Round], CSUB.[Round]) AS 'Round'
	,CSUB.[Sub User State]
	,CSUB.[Sub User Status]
	,QUO.[Quote ID]
	,QUO.[Quote Number]
	,QUO.[Quote Created Date]
	,QUO.[Quote Campaign Year]
	,QUO.[Quote Payment Method]
	,QUO.[Quote Currency]
	,QUO.[Quote State]
	,QUO.[Quote Status]
	,QUO.[Quote Round]
	,QUO.[Quote Scheme No]
	,QUO.[Quote Amount CUR]
	,QUO.[Tax Amount CUR]
	,QUO.[LHL Amount CUR]
	,QUO.[SUB Amount CUR]
	,QUO.[ELE Amount CUR]
	,QUO.[ENR Amount CUR]
	,QUO.[UPG Amount CUR]
	,QUO.[RAD Amount CUR]
	,QUO.[APP Amount CUR]
	,QUO.[Other Amount CUR]
	,QUO.[Quote Amount GBP]
	,INV.[Invoice]
	,INV.[Inv Full Amount CUR]
	,INV.[Inv Full Amount GBP]
	,INV.[Settle Amount CUR]
	,INV.[Settle Amount GBP]
	,INV.[Paid Amount CUR]
	,INV.[Paid Amount GBP]
	,INV.[Balance CUR]
	,INV.[Balance GBP]
	,INV.[Open Balance]
	,INV.[Open Balance GBP]
	,INV.[Credit Amount CUR]
	,INV.[Credit Amount GBP]
	,COALESCE(INV.[Fully Credited], 'N/A') AS 'Fully Credited'
	,INV.[Payment Method]
	,[Payment Status]
	,CASE WHEN QUO.[Quote Payment Method] = 'Corporate' THEN 'Y' ELSE 'N' END AS 'Corp Quote'
	,CASE WHEN COALESCE(QUO.[Quote Scheme No], '') = CSUB.[Scheme No] THEN 'Y' ELSE 'N' END AS 'Scheme Match'
	,CASE WHEN INV.[Quote ID] IS NULL THEN 'N' ELSE 'Y' END AS 'Has Invoice'
	,CASE WHEN INV.[Payment Method] = 'Corporate' THEN 'Y' ELSE 'N' END AS 'Corp Invoice'
	,CASE WHEN QUO.[RAD Amount CUR] > 0 THEN 'Y' ELSE 'N' END AS 'Readmission Flag'
	,CASE WHEN QUO.[ELE Amount CUR] > 0 THEN 'Y' ELSE 'N' END AS 'Election Fee Flag'
	,CASE WHEN QUO.[ENR Amount CUR] > 0 THEN 'Y' ELSE 'N' END AS 'Enrolment Fee Flag'
	,CASE WHEN QUO.[UPG Amount CUR] > 0 THEN 'Y' ELSE 'N' END AS 'Upgrade Fee Flag'
	,CASE WHEN QUO.[Tax Amount CUR] > 0 THEN 'Y' ELSE 'N' END AS 'GST Amount Flag'
	,CASE 
		WHEN INV.[Quote ID] IS NULL THEN 'N/A'
		WHEN [Fully Credited] = 'Y' THEN 'Y' ELSE 'N' END AS 'Is Fully Credited'
	,CASE 
		WHEN QUO.[Quote Payment Method] <> 'Corporate' 
		OR COALESCE(QUO.[Quote Scheme No], '') <> CSUB.[Scheme No] 
		OR CSUB.[Sub User State] <> 'Active'
		OR (INV.[Quote ID] IS NOT NULL AND [Fully Credited] = 'Y')
		OR QUO.[RAD Amount CUR] > 0
		OR QUO.[ENR Amount CUR] > 0
		THEN 'N' ELSE 'Y' END AS 'Valid Quote'
	,CASE 
		WHEN INV.Invoice IS NULL
		OR QUO.[Quote Payment Method] <> 'Corporate' 
		OR INV.[Payment Method] <> 'Corporate'
		OR COALESCE(QUO.[Quote Scheme No], '') <> CSUB.[Scheme No] 
		OR CSUB.[Sub User State] <> 'Active'
		OR (INV.[Quote ID] IS NOT NULL AND [Fully Credited] = 'Y')
		OR QUO.[RAD Amount CUR] > 0
		OR QUO.[ENR Amount CUR] > 0
		THEN 'N' ELSE 'Y' END AS 'Valid Invoice'
	INTO #TT
	FROM #CSUB CSUB
	LEFT JOIN #QUO QUO
		ON QUO.[Contact No] = CSUB.[Contact No]
		AND QUO.[Quote Campaign Year] = CSUB.[Sub Campaign Year]
	LEFT JOIN #INV INV
		ON INV.[Quote ID] = QUO.[Quote ID]

	--DROP TABLE Subs.tblCorp_Cost_Breakdown SELECT * INTO Subs.tblCorp_Cost_Breakdown FROM #TT

	TRUNCATE TABLE Subs.tblCorp_Cost_Breakdown

	INSERT INTO Subs.tblCorp_Cost_Breakdown (
	 [Contact No]
    ,[Contact ID]
    ,[Scheme No]
    ,[Scheme Name]
    ,[Sub Start Date]
    ,[Sub End Date]
    ,[Sub State]
    ,[Sub Status]
    ,[Sub Campaign Year]
	,[Quote Expected]
    ,[Round]
    ,[Sub User State]
    ,[Sub User Status]
    ,[Quote ID]
    ,[Quote Number]
    ,[Quote Created Date]
    ,[Quote Campaign Year]
    ,[Quote Payment Method]
    ,[Quote Currency]
    ,[Quote State]
    ,[Quote Status]
    ,[Quote Round]
    ,[Quote Scheme No]
    ,[Quote Amount CUR]
	,[Quote Amount GBP]
    ,[Tax Amount CUR]
    ,[LHL Amount CUR]
    ,[SUB Amount CUR]
    ,[ELE Amount CUR]
	,[ENR Amount CUR]
    ,[UPG Amount CUR]
    ,[RAD Amount CUR]
    ,[APP Amount CUR]
    ,[Other Amount CUR]
    ,[Invoice]
   	,[Inv Full Amount CUR]
	,[Inv Full Amount GBP]
	,[Settle Amount CUR]
	,[Settle Amount GBP]
	,[Paid Amount CUR]
	,[Paid Amount GBP]
	,[Balance CUR]
	,[Balance GBP]
	,[Open Balance]
	,[Open Balance GBP]
	,[Credit Amount CUR]
	,[Credit Amount GBP]
    ,[Fully Credited]
    ,[Payment Method]
	,[Payment Status]
    ,[Corp Quote]
    ,[Scheme Match]
    ,[Has Invoice]
    ,[Corp Invoice]
    ,[Readmission Flag]
    ,[Election Fee Flag]
	,[Enrolment Fee Flag]
    ,[Upgrade Fee Flag]
    ,[GST Amount Flag]
    ,[Is Fully Credited]
    ,[Valid Quote]
    ,[Valid Invoice]
		)

	SELECT
	 [Contact No]
    ,[Contact ID]
    ,[Scheme No]
    ,[Scheme Name]
    ,[Sub Start Date]
    ,[Sub End Date]
    ,[Sub State]
    ,[Sub Status]
    ,[Sub Campaign Year]
	,[Quote Expected]
    ,[Round]
    ,[Sub User State]
    ,[Sub User Status]
    ,[Quote ID]
    ,[Quote Number]
    ,[Quote Created Date]
    ,[Quote Campaign Year]
    ,[Quote Payment Method]
    ,[Quote Currency]
    ,[Quote State]
    ,[Quote Status]
    ,[Quote Round]
    ,[Quote Scheme No]
    ,[Quote Amount CUR]
	,[Quote Amount GBP]
    ,[Tax Amount CUR]
    ,[LHL Amount CUR]
    ,[SUB Amount CUR]
    ,[ELE Amount CUR]
	,[ENR Amount CUR]
    ,[UPG Amount CUR]
    ,[RAD Amount CUR]
    ,[APP Amount CUR]
    ,[Other Amount CUR]
    ,[Invoice]
	,[Inv Full Amount CUR]
	,[Inv Full Amount GBP]
	,[Settle Amount CUR]
	,[Settle Amount GBP]
	,[Paid Amount CUR]
	,[Paid Amount GBP]
	,[Balance CUR]
	,[Balance GBP]
	,[Open Balance]
	,[Open Balance GBP]
	,[Credit Amount CUR]
	,[Credit Amount GBP]
    ,[Fully Credited]
    ,[Payment Method]
	,[Payment Status]
    ,[Corp Quote]
    ,[Scheme Match]
    ,[Has Invoice]
    ,[Corp Invoice]
    ,[Readmission Flag]
    ,[Election Fee Flag]
	,[Enrolment Fee Flag]
    ,[Upgrade Fee Flag]
    ,[GST Amount Flag]
    ,[Is Fully Credited]
    ,[Valid Quote]
    ,[Valid Invoice]
	FROM #TT

END

--EXEC Subs.usp_Refresh_CorpCostBreakdown
