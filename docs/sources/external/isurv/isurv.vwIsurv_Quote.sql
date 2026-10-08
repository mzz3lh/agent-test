CREATE   VIEW [isurv].[vwIsurv_Quote] AS

	SELECT
	 QUO.quoteid AS 'Quote ID'
	,QUO.msdyn_quotenumber AS 'Quote Number'
	,CON.Rics_contactno AS 'Contact No'
	,QUO.customerid AS 'Contact ID'
	,CAST(QUO.createdon AS DATE) AS 'Quote Created Date' 
	,QUO.apuk_paymentmethod_description AS 'Quote Payment Method'
	,QUO.msdyn_isocurrencycode AS 'Quote Currency'
	,QUO.StateCode_Description AS 'Quote State'
	,QUO.StatusCode_Description AS 'Quote Status'
	,QUO.apuk_totalprofessionalfees AS 'Quote Amount CUR'
	,QUO.apuk_totalprofessionalfees_base AS 'Quote Amount GBP'
	,QUO.totaltax AS 'Tax Amount CUR'
	,QUO.totaltax_base AS 'Tax Amount GBP'
	,QUO.apuk_subscriptionstartdate AS 'Quote Sub Start Date'
	,QUO.apuk_subscriptionenddate  AS 'Quote Sub End Date'
	,YEAR(QUO.apuk_subscriptionstartdate) AS 'Quote Sub Start Year'
	,YEAR(QUO.apuk_subscriptionenddate) AS 'Quote Sub End Year'
	,QUOD.[Isurv Base Amount CUR]
	,QUOD.[Isurv Base Amount GBP]
	,QUOD.[Isurv Amount CUR]
	,QUOD.[Isurv Amount GBP]
	,QUOD.[Isurv Discount Amount CUR]
	,QUOD.[Isurv Discount Amount GBP]
	,QUOD.[Isurv Tax Amount CUR]
	,QUOD.[Isurv Tax Amount GBP]
	,QUOD.[Non-Isurv Amount CUR]
	,QUOD.[Non-Isurv Amount GBP]
	FROM synapse_ce.vwQuote QUO
	INNER JOIN isurv.vwIsurv_Quote_Detail_Grouped QUOD
		ON QUOD.quoteid = QUO.quoteid
	LEFT JOIN CE.vwContact CON
		ON QUO.customerid = CON.ContactId
