CREATE   VIEW [CE].[vwDirectDebitDetail_AUDDIS_Exports] AS

SELECT
 REPLACE(apuk_sortcode, '-', '') AS apuk_sortcode
,apuk_accountnumber
,'0N' AS DefaultOne
,'0.00' AS DefaultTwo
,DDD.apuk_bankaccountid
,apuk_name AS apuk_name
,'' AS DefaultThree
,NULL AS DefaultFour
,DDD.modifiedon
,CON.Rics_contactno
FROM [synapse_ce].[vwDirectDebitDetail] DDD
	LEFT JOIN synapse_ce.tblContact_BI CON ON CON.ContactId = DDD.apuk_customerid
