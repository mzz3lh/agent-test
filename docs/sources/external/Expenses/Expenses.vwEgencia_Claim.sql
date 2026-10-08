CREATE    VIEW [Expenses].[vwEgencia_Claim] 
AS 

	SELECT
		CASE 
			WHEN [Employee ID] IS NULL THEN '00000'
			WHEN [Employee ID] IN ('NONE', 'N/a', '', '0') THEN '00000'
			ELSE [Employee ID]
			END AS 'Employee ID'
		,[Cost Center]
		,[Point of Sale Country] AS 'Country'
		,Department
		,Directorate
		,[Is Guest Traveler]
		,[Traveller Email]
		,[Traveller Group]
		,[Traveller Name]
		,[Invoice Date]
		,[Transaction Date]
		,[Travel Start Date]
		,[Travel End Date]
		,[Booking Method]
		,[Is Active]
		,[Line Of Business]
		,[Itinerary Number]
		,[Record Locator]
		,[Special Request] AS [Special Request?]
		,[Transaction Type]
		,[Ticket Code]
		,[Fare Rate Type]
		,[Geography Type]
		,[Vendor Name]
		,[Location]
		,[Invoice Number]
		,[Transaction Amount GBP] AS [Transaction Amount(£)]
		,[In Policy]
		,[Policy Reason Code]
		,[Policy Reason Description]
	FROM [Expenses].[tblTravelExpenses]
