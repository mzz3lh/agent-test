CREATE VIEW [CE].[vwLionheartMatricsEvents]
AS


WITH ctePass  --Get the small dataset of Lionheart related passes
AS
(

SELECT msevtmgt_eventid
,msevtmgt_contact
,msevtmgt_passname
FROM [synapse_ce].[msevtmgt_attendeepass] AP
WHERE AP.msevtmgt_passname LIKE '%Lionheart%'
--AND msevtmgt_eventid =  '00000000-0000-0000-0000-000000000000'

),
cteSOandInvoice
AS
(
SELECT E.apuk_eventcode AS EventCode,--
E.id AS EventID,
E. msevtmgt_name AS EventName,--
E.apuk_businessarea AS BusinessArea,
--P.msevtmgt_passname AS PassName,
EB.apuk_bookingreference AS BookingRef,--
SUBSTRING(SO.ordernumber,4,20) AS OrderNo,--
EB.Rics_contactno AS BookerContactNo,--contactNo
C.ContactId AS BookerContactID,
C.FullName AS BookerFullName,--fullname
EB.TransactionCurrencyIdName AS CurrencyName,
SO.IsoCurrencyCode AS CurrencyCode,
SO.StateCode_Description AS SalesOrderStatus,
SO.salesorderid AS SalesOrderID,
SO.TotalLineItemAmount AS TotalAmountCUR,
SO.TotalLineItemAmount_Base AS TotalAmountGBP,
I.msdyn_invoicenumber AS InvoiceNo,
I.msdyn_ledgervoucher AS InvoiceVoucher

--INTO #Matrics

FROM [synapse_ce].[msevtmgt_event] E 
LEFT JOIN [CE].[vwEventBooking] EB
	ON E.id = EB.apuk_eventid
LEFT JOIN [CE].[vwSalesOrder] SO
	ON SO.SalesOrderId = EB.apuk_salesorderid
LEFT JOIN CE.vwContact C
	ON C.Rics_ContactNo = EB.Rics_contactno
LEFT JOIN synapse_ce.invoice I
	ON SO.salesorderid = I.salesorderid


WHERE E.id IN
(SELECT DISTINCT msevtmgt_eventid FROM ctePass)
AND E.apuk_businessarea = 200000003  --Matrics
AND SO.statecode_Description = 'invoiced'
--AND E.apuk_eventcode = 'EV-Z1C1H-3004'
--AND E.id = '00000000-0000-0000-0000-000000000000'
--AND C.ContactId = '00000000-0000-0000-0000-000000000000'
)

SELECT * FROM cteSOandInvoice
