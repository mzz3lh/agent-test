CREATE   VIEW [FO].[vwCybersource_CCI]
AS

	WITH cci AS 
	(
		SELECT 
			s.*
			,p.amount as paid
			, DENSE_RANK() over(partition by s.membernumber order by s.processedtime desc) rn
			, DATEADD(MM,numberofpayments-1,startdate) EndDate
			FROM [FO].[vwCybersourceSubscription] s
				LEFT JOIN [FO].[vwCybersourcePayment] p
					ON s.orderreference = p.orderreference
						AND p.reasoncode = 100
						AND p.istestmode = 0
		WHERE 1=1
			AND s.istestmode = 0
			AND s.reasoncode = 100

	)

	SELECT 
		membernumber collate database_default as rics_contactno
		, [Description] collate database_default as subscampaign
		, orderreference
		, amount as scheduleamount
		, NumberOfPayments as ExpectedPayments
		, currency
		, count(paid) as PaymentsMade 
		, sum(paid) as SumPayments
		,startdate
		,EndDate
		,subscriptionid
	FROM cci
	WHERE rn =1
	GROUP BY 
		membernumber, 
		orderreference,
		amount,
		[Description],
		currency,
		NumberOfPayments,
		subscriptionid,
		startdate,
		enddate
