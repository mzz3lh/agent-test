CREATE   VIEW [Subs].[vwCorpQuotes] AS

 	SELECT
	 QUO.quoteid AS 'Quote ID'
	,QUO.msdyn_quotenumber AS 'Quote Number'
	,CON.Rics_contactno AS 'Contact No'
	,QUO.customerid AS 'Contact ID'
	,CAST(QUO.createdon AS DATE) AS 'Quote Created Date' 
	,QUO.apuk_campaignyear AS 'Quote Campaign Year'
	,QUO.apuk_paymentmethod_description AS 'Quote Payment Method'
	,QUO.msdyn_isocurrencycode AS 'Quote Currency'
	,QUO.StateCode_Description AS 'Quote State'
	,QUO.StatusCode_Description AS 'Quote Status'
	,QUO.apuk_corppaymentref AS 'Quote Scheme No'
	--,ISNULL(totalamount, 0.0) + ISNULL(apuk_lionheartdonation, 0.0) + ISNULL(apuk_directdebitfees, 0.0) AS 'Quote Amount CUR OG'
	--,ISNULL(totalamount_base, 0.0) + ISNULL(apuk_lionheartdonation_base, 0.0) + ISNULL(apuk_directdebitfees_base, 0.0) AS 'Quote Amount GBP OG'
	,QUOD.[Quote Amount CUR] 
	,QUOD.[Quote Amount GBP]
	,QUOD.[Tax Amount CUR]
	--,QUOD.[Tax Amount GBP]
	,QUOD.[LHL Amount CUR]
	--,QUOD.[LHL Amount GBP]
	,QUOD.[SUB Amount CUR]
	--,QUOD.[SUB Amount GBP]
	,QUOD.[ELE Amount CUR]
	--,QUOD.[ARC Amount GBP]
	,QUOD.[ENR Amount CUR]
	--,QUOD.[ENR Amount GBP]
	,QUOD.[UPG Amount CUR]
	--,QUOD.[UPG Amount GBP]
	,QUOD.[RAD Amount CUR]
	--,QUOD.[RAD Amount GBP]
	,QUOD.[APP Amount CUR]
	--,QUOD.[APP Amount GBP]
	,QUOD.[Other Amount CUR]
	--,QUOD.[Other Amount GBP]
	,QUOD.[REGS Amount CUR]
	,shipto_fax AS 'Quote Round'
	FROM CE.vwQuote QUO
	LEFT JOIN Subs.vwCorpQuoteDetail_Grouped QUOD
		ON QUOD.quoteid = QUO.quoteid
	LEFT JOIN CE.vwContact CON
		ON QUO.customerid = CON.ContactId
	INNER JOIN Subs.tblCorpValidContacts CVC
		ON CVC.[Contact No] = CON.Rics_contactno --Filter only Corp relevant records

	WHERE QUO.apuk_campaignyear IS NOT NULL
	AND [REGS Amount CUR] = 0
