CREATE VIEW CE.LHMatricsAttendeePass
AS

SELECT DISTINCT LME.EventCode, LME.OrderNo,SOD.ricsv1_eventidName AS LineItemDesc, 
SOD.BaseAmount AS ItemAmountCUR,SOD.BaseAmount_Base AS ItemAmountGBP,EB.apuk_eventbookingid
,AP.msevtmgt_passname AS PassName
FROM [CE].[vwLionheartMatricsEvents] LME
LEFT JOIN [CE].[vwSalesOrderDetail] SOD
	ON LME.SalesOrderID = SOD.SalesOrderId
LEFT JOIN [CE].[vwEventBooking] EB
	ON EB.apuk_salesorderid = SOD.SalesOrderId
LEFT JOIN [synapse_ce].[apuk_delegatebooking] DB
	ON DB.apuk_eventbookingid = EB.apuk_eventbookingid
	AND DB.apuk_eventid = EB.apuk_eventid
LEFT JOIN [synapse_ce].[msevtmgt_attendeepass] AP
	ON AP.msevtmgt_eventid = LME.EventID
	AND AP.msevtmgt_eventregistrationid = DB.apuk_eventregistrationid
