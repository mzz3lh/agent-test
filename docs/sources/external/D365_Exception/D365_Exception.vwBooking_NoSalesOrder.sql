CREATE   VIEW [D365_Exception].[vwBooking_NoSalesOrder]
AS
SELECT 
	camp.[Name] AS EventName,
	BR.BookerName as CustomerName,
	BR.apuk_bookingreference as BookingReference,
	BR.Owner,
	BR.apuk_totaldelegates as TotalDelegates,
	BR.apuk_totalpassprice as TotalPassPrice,
	BR.apuk_totaldiscount as Total_Discount, 
	BR.apuk_totaltax as TotalTax,
	BR.apuk_totalvalue as TotalValue,
	BR.StateCode_Description as StateCode,
	BR.StatusCode_Description as StatusCode,
	BR.createdon Created_On

FROM CE.vwEventBooking BR
	LEFT JOIN synapse_ce.vwCampaign camp
		ON BR.apuk_eventid = camp.CampaignId
	LEFT JOIN synapse_ce.vwSalesOrder SO
		ON BR.apuk_salesorderid = SO.SalesOrderId
WHERE BR.StatusCode_Description = 'Confirmed'
	AND apuk_bookingreference LIKE 'EV%' 
	AND SO.SalesOrderId IS NULL
