CREATE   PROCEDURE [Expenses].[usp_Load_TravelExpenses]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-07-13
	Description: Stored procedure to load travel expenses (Egencia)
*/
BEGIN

	DELETE FROM [Expenses].[tblTravelExpenses]
	WHERE [Transaction Date]  
		IN 
		(
			SELECT 
				DISTINCT 		
				CASE
					WHEN LTRIM(RTRIM([Transaction Date])) <> ''	THEN
							CASE
								WHEN TRY_CAST(SUBSTRING([Transaction Date], 1, 4) AS int) IS NOT NULL 
								THEN 
									DATEFROMPARTS(SUBSTRING([Transaction Date], 1, 4), SUBSTRING([Transaction Date], 6,2), SUBSTRING([Transaction Date], 9,2)) 
								ELSE	
									DATEFROMPARTS(SUBSTRING([Transaction Date], 7, 4), SUBSTRING([Transaction Date], 4,2), SUBSTRING([Transaction Date], 1,2)) 
							END
						ELSE
							NULL
				END 
			FROM [Work].[tblTravelExpenses]
		)

		--Insert into target table
		INSERT INTO [Expenses].[tblTravelExpenses]
		(
			[File_Name]
			,[Point of Sale Country]
			,[Company Name]
			,[Department]
			,[Traveller Name]
			,[Traveller Email]
			,[Is Guest Traveler]
			,[Traveller Group]
			,[Transaction Date]
			,[Travel Start Date]
			,[Travel End Date]
			,[Is Active]
			,[Invoice Date]
			,[Itinerary Number]
			,[Record Locator]
			,[Confirmation Number]
			,[Line Of Business]
			,[Purchase Count]
			,[Transaction Type]
			,[Booker Name]
			,[Booker Role]
			,[Booking Method]
			,[Geography Type]
			,[Credit Card Type]
			,[Credit Card BIN]
			,[Credit Card Last 4 Digits]
			,[Invoice Number]
			,[Advance Purchase Window]
			,[In Policy]
			,[Policy Reason Code]
			,[Fare Rate Type]
			,[Vendor Name]
			,[Location]
			,[Ancillary Type]
			,[Department Cost Center]
			,[Reason for Travel]
			,[Employee ID]
			,[Cost Center]
			,[Department1]
			,[Directorate]
			,[Ticket Code]
			,[Base Amount GBP]
			,[Taxes GBP]
			,[Transaction Amount GBP]
			,[Advance Purchase Days]
			,[Meeting Name]
			,[Meeting Attendee Traveller Group]
			,[Policy Reason Description]
			,[Special Request]
		)
		SELECT
			[File_Name]
			,[Point of Sale Country]
			,[Company Name]
			,[Department]
			,[Traveller Name]
			,[Traveller Email]
			,[Is Guest Traveler]
			,[Traveller Group]
			,CASE
				WHEN LTRIM(RTRIM([Transaction Date])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Transaction Date], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Transaction Date], 1, 4), SUBSTRING([Transaction Date], 6,2), SUBSTRING([Transaction Date], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Transaction Date], 7, 4), SUBSTRING([Transaction Date], 4,2), SUBSTRING([Transaction Date], 1,2)) 
						END
					ELSE
						NULL
				END AS [Transaction Date]
			,CASE
				WHEN LTRIM(RTRIM([Travel Start Date])) <> '' THEN 
					CASE
						WHEN TRY_CAST(SUBSTRING([Travel Start Date], 1, 4) AS int) IS NOT NULL 
						THEN 
							DATETIMEFROMPARTS(SUBSTRING([Travel Start Date], 1, 4), SUBSTRING([Travel Start Date], 6,2), SUBSTRING([Travel Start Date], 9,2), SUBSTRING([Travel Start Date], 12,2), SUBSTRING([Travel Start Date], 15,2),0,0) 
						ELSE
							DATETIMEFROMPARTS(SUBSTRING([Travel Start Date], 7, 4), SUBSTRING([Travel Start Date], 4,2), SUBSTRING([Travel Start Date], 1,2), SUBSTRING([Travel Start Date], 12,2), SUBSTRING([Travel Start Date], 15,2),0,0) 
						END
				ELSE NULL
			END AS [Travel Start Date]
			,CASE
				WHEN LTRIM(RTRIM([Travel End Date])) <> '' THEN 
					CASE
						WHEN TRY_CAST(SUBSTRING([Travel End Date], 1, 4) AS int) IS NOT NULL 
						THEN 
							DATETIMEFROMPARTS(SUBSTRING([Travel End Date], 1, 4), SUBSTRING([Travel End Date], 6,2), SUBSTRING([Travel End Date], 9,2), SUBSTRING([Travel End Date], 12,2), SUBSTRING([Travel End Date], 15,2),0,0) 
						ELSE
							DATETIMEFROMPARTS(SUBSTRING([Travel End Date], 7, 4), SUBSTRING([Travel End Date], 4,2), SUBSTRING([Travel End Date], 1,2), SUBSTRING([Travel End Date], 12,2), SUBSTRING([Travel End Date], 15,2),0,0) 
						END
				ELSE NULL
			END AS [Travel End Date]
			,[Is Active]
			,CASE
				WHEN LTRIM(RTRIM([Invoice Date])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Invoice Date], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Invoice Date], 1, 4), SUBSTRING([Invoice Date], 6,2), SUBSTRING([Invoice Date], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Invoice Date], 7, 4), SUBSTRING([Invoice Date], 4,2), SUBSTRING([Invoice Date], 1,2)) 
						END
					ELSE
						NULL
				END AS [Invoice Date]
			,[Itinerary Number]
			,[Record Locator]
			,[Confirmation Number]
			,[Line Of Business]
			,TRY_CAST([Purchase Count] AS INT) AS [Purchase Count]
			,[Transaction Type]
			,[Booker Name]
			,[Booker Role]
			,[Booking Method]
			,[Geography Type]
			,[Credit Card Type]
			,[Credit Card BIN]
			,[Credit Card Last 4 Digits]
			,[Invoice Number]
			,[Advance Purchase Window]
			,[In Policy]
			,[Policy Reason Code]
			,[Fare Rate Type]
			,[Vendor Name]
			,[Location]
			,[Ancillary Type]
			,[Department Cost Center]
			,[Reason for Travel]
			,[Employee ID]
			,[Cost Center]
			,[Department1]
			,[Directorate]
			,[Ticket Code]
			,[Base Amount GBP]
			,[Taxes GBP]
			,[Transaction Amount GBP]
			,TRY_CAST([Advance Purchase Days] AS INT) AS [Advance Purchase Days]
			,[Meeting Name]
			,[Meeting Attendee Traveller Group]
			,[Policy Reason Description]
			,[Special Request]
		FROM [Work].[tblTravelExpenses]

END
