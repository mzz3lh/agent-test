CREATE    VIEW [Subs].[vwSubsQuotes] AS
WITH cte As
(
	SELECT so.quoteid, ct.ORDERNUM, ct.INVOICE
	FROM synapse_ce.salesorder so
		INNER JOIN synapse_fo.CUSTTRANS_RICS ct
			ON so.[msdyn_salesordernumber] = ct.ORDERNUM
	GROUP BY so.quoteid, ct.ORDERNUM, ct.INVOICE
)

	SELECT 
		 Contact_No AS 'Contact No.'
		,Quote_ID AS 'Quote ID'
		,Contact_ID AS 'Contact ID'
		,Quote_Number AS 'Quote Number'
		,Campaign_Year AS 'Campaign Year'
		,Quote_Currency AS 'Currency'
		,Quote_Payment_Method_Code AS 'Payment Method Code'
		,Quote_Payment_Method AS 'Payment Method'
		,Created_Date AS 'Created Date'
		,Modified_Date AS 'Modified Date'
		,Quote_State AS 'Quote State'
		,Quote_Status AS 'Quote Status'
		,Exchange_Rate AS 'Exchange Rate'
		,Quote_Amount_CUR AS 'Quote Amount CUR'
		,Quote_Amount_GBP AS 'Quote Amount GBP'
		,[Quote_Amount_GBP_(OG)] AS 'Quote Amount GBP (OG)'
		,c1.[ORDERNUM]
		,c1.[INVOICE]
	FROM Subs.tblSubsQuotes t1
		LEFT JOIN cte c1
			ON t1.[Quote_ID] = c1.quoteid
