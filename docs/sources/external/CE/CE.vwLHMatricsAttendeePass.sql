CREATE VIEW CE.vwLHMatricsAttendeePass
AS

SELECT DISTINCT LME.EventCode, LME.OrderNo,SOD.ricsv1_eventidName AS LineItemDesc, SOD.SalesOrderID,
SOD.BaseAmount AS ItemAmountCUR,SOD.BaseAmount_Base AS ItemAmountGBP
,EB.apuk_eventbookingid, EB.BookerName + ' - ' + EB.Rics_ContactNo AS BookerNameContactNo
,AP.msevtmgt_passname AS PassName, AP.msevtmgt_attendeepassid,AP.msevtmgt_eventregistrationid

FROM [CE].[vwLionheartMatricsEvents] LME
LEFT JOIN [CE].[vwSalesOrderDetail] SOD
	ON LME.SalesOrderID = SOD.SalesOrderId
LEFT JOIN [CE].[vwEventBooking] EB   --DON'T NEED EVENT BOOKING
	ON EB.apuk_salesorderid = SOD.SalesOrderId
LEFT JOIN [synapse_ce].[apuk_delegatebooking] DB
	ON DB.apuk_salesorderlineid = SOD.SalesOrderDetailID
	AND DB.apuk_eventbookingid = EB.apuk_eventbookingid
	AND DB.apuk_eventid = EB.apuk_eventid
LEFT JOIN [synapse_ce].[msevtmgt_eventregistration]ER
	ON DB.apuk_eventid = ER.msevtmgt_eventid
	AND DB.apuk_eventregistrationid = ER.msevtmgt_eventregistrationid
LEFT JOIN [synapse_ce].[msevtmgt_attendeepass] AP
	ON AP.msevtmgt_eventid = LME.EventID
	AND AP.msevtmgt_eventregistrationid = DB.apuk_eventregistrationid
