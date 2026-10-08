CREATE VIEW [Subs].[vwCorpQuoteDetail_Grouped] AS

	SELECT 
	 QUOD.quoteid
	,QUO.apuk_totalprofessionalfees AS 'Quote Amount CUR'
	,QUO.apuk_totalprofessionalfees_base AS 'Quote Amount GBP'
	--,SUM(QUOD.extendedamount) + COALESCE(apuk_lionheartdonation, 0) + COALESCE(apuk_directdebitfees, 0) AS 'Quote Amount CUR'
	--,SUM(QUOD.extendedamount_base) + COALESCE(apuk_lionheartdonation_base, 0) + COALESCE(apuk_directdebitfees_base, 0) AS 'Quote Amount GBP'
	,COALESCE(QUO.apuk_lionheartdonation, 0) AS 'LHL Amount CUR'
	,COALESCE(QUO.apuk_lionheartdonation_base, 0) AS 'LHL Amount GBP'
	,COALESCE(QUO.apuk_directdebitfees, 0) AS 'SUR Amount CUR'
	,COALESCE(QUO.apuk_directdebitfees_base, 0) AS 'SUR Amount GBP'
	,QUO.totaltax AS 'Tax Amount CUR'
	,QUO.totaltax_base AS 'Tax Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsPROAPCCAND', 'rcsPROASSOC', 'rcsPROASSOCCAND', 'rcsPROFRICS', 'rcsPROMRICS', 'rcsPROMRICSU2') 
		 OR QUOD.productnumber LIKE 'rcsCON%' THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'SUB Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsPROAPCCAND', 'rcsPROASSOC', 'rcsPROASSOCCAND', 'rcsPROFRICS', 'rcsPROMRICS', 'rcsPROMRICSU2') 
		 OR QUOD.productnumber LIKE 'rcsCON%' THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'SUB Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsAFAELE', 'rcsAFCELE') THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'ELE Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsAFAELE', 'rcsAFCELE') THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'ELE Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsAFCAPCPRE', 'rcsAFCASS', 'rcsAFAASS', 'rcsAFCSPA') THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'ENR Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsAFCAPCPRE', 'rcsAFCASS', 'rcsAFAASS', 'rcsAFCSPA') THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'ERN Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsPFUAPCM', 'rcsPFUAPCM2', 'rcsPFUAM', 'rcsPFUACA') THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'UPG Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber IN ('rcsPFUAPCM', 'rcsPFUAPCM2', 'rcsPFUAM', 'rcsPFUACA') THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'UPG Amount GBP'
	,SUM(CASE WHEN PG.ProductGroup = 'Readmission Fees' THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'RAD Amount CUR'
	,SUM(CASE WHEN PG.ProductGroup = 'Readmission Fees' THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'RAD Amount GBP'
	,SUM(CASE WHEN PG.ProductGroup = 'Application Fees' THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'APP Amount CUR'
	,SUM(CASE WHEN PG.ProductGroup = 'Application Fees' THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'APP Amount GBP'
	,SUM(CASE WHEN PG.ProductGroup = 'Regulation' THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'REGS Amount CUR'
	,SUM(CASE WHEN PG.ProductGroup = 'Regulation' THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'REGS Amount GBP'
	,SUM(CASE WHEN (PG.ProductGroup IS NULL OR PG.ProductGroup NOT IN ('Membership', 'Readmission Fees', 'Application Fees', 'Regulation')) AND
		Product_Number NOT IN ('rcsAFAELE', 'rcsAFCELE', 'rcsPFUAPCM', 'rcsPFUAPCM2', 'rcsPFUAM', 'rcsPFUACA', 'rcsAFCAPCPRE', 'rcsAFCASS', 'rcsAFAASS', 'rcsAFCSPA')
		THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'Other Amount CUR'
	,SUM(CASE WHEN (PG.ProductGroup IS NULL OR PG.ProductGroup NOT IN ('Membership', 'Readmission Fees', 'Application Fees', 'Regulation')) AND
		Product_Number NOT IN ('rcsAFAELE', 'rcsAFCELE', 'rcsPFUAPCM', 'rcsPFUAPCM2', 'rcsPFUAM', 'rcsPFUACA', 'rcsAFCAPCPRE', 'rcsAFCASS', 'rcsAFAASS', 'rcsAFCSPA') 
		THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'Other Amount GBP'
	FROM synapse_ce.quotedetail QUOD
	LEFT JOIN synapse_ce.quote QUO
		ON QUO.quoteid = QUOD.quoteid 
	LEFT JOIN synapse_ce.vwContact CON
		ON QUO.customerid = CON.ContactId
	LEFT JOIN CE.vwProduct PRD
		ON PRD.Product_Number = QUOD.productnumber
	LEFT JOIN CE.vwProductGroup PG
		ON PG.RICS_ProductGroupId = PRD.Rics_ProductGroupId
	INNER JOIN Subs.tblCorpValidContacts CVC
		ON CVC.[Contact No] = CON.Rics_contactno --Filter only Corp relevant records
	GROUP BY 
	 QUOD.quoteid
	,QUO.apuk_totalprofessionalfees
	,QUO.apuk_totalprofessionalfees_base
	,QUO.apuk_lionheartdonation
	,QUO.apuk_lionheartdonation_base
	,QUO.apuk_directdebitfees
	,QUO.apuk_directdebitfees_base
	,QUO.totaltax
	,QUO.totaltax_base
