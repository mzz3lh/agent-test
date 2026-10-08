CREATE    VIEW [D365_Exception].[vwQuote_NoSalesOrder]
AS
SELECT
	Q.msdyn_quotenumber AS QuoteNumber,
	suser.FullName AS Owner,
	Q.name,
	Q.statuscode_Description,
	Q.TotalAmount,
	Q.TotalTax as TotalTax,
	Q.customerid as PotentialCustomerId,
	Con.fullname as PotentialCustomerName ,
	Q.apuk_billto,
	Conbillto.fullname as BilltoName,
	Q.apuk_paymentmethod_description as PaymentMethod,
	con.Rics_contactno AS ContactNumber,
	q.msdyn_isocurrencycode AS CurrencyCode,
	Q.createdon
FROM synapse_ce.vwQuote Q
	LEFT JOIN synapse_ce.tblContact_BI Con
		ON q.customerid = Con.contactid
	LEFT JOIN synapse_ce.tblContact_BI Conbillto
		ON q.apuk_billto = Conbillto.ContactId
	LEFT JOIN synapse_ce.vwSalesOrder SO
		ON Q.QuoteId= SO.QuoteId
	--LEFT JOIN synapse_ce.vwSalesOrderDetail SOD
	--	ON SO.SalesOrderId = SOD.SalesOrderId
	LEFT JOIN synapse_ce.SystemUser suser
		ON q.ownerid = suser.SystemUserId
WHERE Q.StateCode_Description = 'Won'
	AND SO.SalesOrderId IS NULL
