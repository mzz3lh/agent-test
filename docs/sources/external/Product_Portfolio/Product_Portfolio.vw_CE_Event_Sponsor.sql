CREATE VIEW [Product_Portfolio].[vw_CE_Event_Sponsor] AS

	SELECT
	 SPON.Id AS 'Event Sponsorship ID'
	,SPON.msevtmgt_event AS 'Event ID'
	,SPON.createdon  AS 'Created Datetime'
	,CAST(SPON.createdon AS DATE) AS 'Created Date'
	,TYP.LocalizedLabel AS 'Sponsorship Type'
	,CAT.LocalizedLabel AS 'Sponsorship Category'
	,CURR.isocurrencycode AS 'Currency'
	,SPON.msevtmgt_sponsor AS 'Sponsor Account ID'
	,SPON.msevtmgt_sponsorname AS 'Sponsor'
	,SPON.msevtmgt_name AS 'Sponsor Description'
	,SPON.msevtmgt_sponsorshipamount AS 'Sponsorship Amt CUR'
	,SPON.msevtmgt_sponsorshipamount_base  AS 'Sponsorship Amt MST'
	FROM synapse_ce.msevtmgt_sponsorship SPON
	LEFT JOIN synapse_ce.transactioncurrency CURR
		ON SPON.transactioncurrencyid = CURR.transactioncurrencyid
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata TYP
		ON TYP.[Option] = SPON.msevtmgt_sponsorshiptype
		AND TYP.OptionSetName = 'msevtmgt_sponsorshiptype'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata CAT
		ON CAT.[Option] = SPON.msevtmgt_sponsorshipcategory
		AND CAT.OptionSetName = 'msevtmgt_sponsorshipcategory'
	WHERE SPON.statecode = 0
	AND SPON.createdon >= '2022-01-01'
