CREATE   PROCEDURE [Expenses].[usp_Load_WebExpenses_Detailed]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-07-17
	Description: Stored procedure to load web expenses
*/
BEGIN

	DELETE FROM [Expenses].[tblWebExpenses_Detailed]
	WHERE [Date Created]  
		IN 
		(
			SELECT 
				DISTINCT 		
				CASE
					WHEN LTRIM(RTRIM([Date Created])) <> ''	THEN
							CASE
								WHEN TRY_CAST(SUBSTRING([Date Created], 1, 4) AS int) IS NOT NULL 
								THEN 
									DATEFROMPARTS(SUBSTRING([Date Created], 1, 4), SUBSTRING([Date Created], 6,2), SUBSTRING([Date Created], 9,2)) 
								ELSE	
									DATEFROMPARTS(SUBSTRING([Date Created], 7, 4), SUBSTRING([Date Created], 4,2), SUBSTRING([Date Created], 1,2)) 
							END
						ELSE
							NULL
				END 
			FROM [Work].[tblWebExpenses_Detailed]
		)

		--Insert into target table
		INSERT INTO [Expenses].[tblWebExpenses_Detailed]
		(
			[Filename],
			[Employee ID],
			[Claimant Name],
			[Item title],
			[Category],
			[Cost Centre],
			[Event Code],
			[Country],
			[VAT Amount],
			[Base Currency],
			[Source],
			[Accounts Person Name],
			[Advance],
			[Amend FxRate],
			[Amount],
			[amount Without VAT],
			[Amount in Billing Currency],
			[Approval Limit],
			[Approver Name],
			[Attendee Job Title],
			[Attendee Name],
			[Attendee Notes],
			[Bank Account Number],
			[Bank Country],
			[Base Amount Without VAT],
			[Base Ccy Amount],
			[Base Currency Id],
			[Billing Currency],
			[Billing Currency ID],
			[CC Amount],
			[CC Dual Number Last 4 Digits],
			[CC Fx Rate],
			[CC Mileage Import],
			[CC Number Last 4 Digits],
			[CC Per Diem Import],
			[CC Program Ccy],
			[Category GL Code],
			[Category Limit Exceeded],
			[Claim],
			[Claim Id],
			[Claim Notes],
			[Claim Status],
			[Claim Total Gross Amount],
			[Claim Total Without VAT],
			[Company],
			[Cost Centre Code],
			[Country Visited],
			[Credit Card Billing Date],
			[Date Approved],
			[Date Approved 1],
			[Approver 1],
			[Date Approved 2],
			[Approver 2],
			[Date Approved 3],
			[Approver 3],
			[Date Approved 4],
			[Approver 4],
			[Date Approved 5],
			[Approver 5],
			[Date Approved 6],
			[Approver 6],
			[Date Created],
			[Date Paid],
			[Date Pre-approved],
			[Date Submitted],
			[Destination],
			[Division Base Ccy Amount],
			[Duty Of Care Statement],
			[E-mail Address],
			[end Mileage Units],
			[Entity ID],
			[Event],
			[Expense Date],
			[Expense Date Exceeded],
			[Extra Detail],
			[First Name],
			[Fx Rate],
			[FxRate Exchange],
			[Incurred Ccy],
			[Item Number],
			[Last Name],
			[Migrated Mileage],
			[Migrated Mileage Added],
			[Mileage],
			[Mileage Rate],
			[Mileage Rate Description],
			[Net Due],
			[Offset Miles],
			[Offset Type],
			[P11d Category],
			[Payment Currency],
			[Per Diem Code],
			[Per Diem Duration],
			[Per Diem Rate],
			[Per Diem Rate Description],
			[Per Diem Units],
			[Pre-approved Amount],
			[Rate Vatable],
			[Receipt Attached],
			[Receipt Given],
			[start Mileage Units],
			[Sub Vendor],
			[Sub Vendor Code],
			[Supplier],
			[Supplier Code],
			[Total Miles],
			[travel From],
			[Travel Return],
			[travel To],
			[URN],
			[Unrecovered VAT],
			[VAT Name],
			[VAT Processed],
			[VAT Rate],
			[No of Spent Units],
			[No of units],
			[VUK Number]
		)

		SELECT
			[Filename],
			[Employee ID],
			[Claimant Name],
			[Item title],
			[Category],
			[Cost Centre],
			[Event Code],
			[Country],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([VAT Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [VAT Amount],
			[Base Currency],
			[Source],
			[Accounts Person Name],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Advance], ',', ''))) AS numeric(18,2)), 0.0) AS [Advance],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Amend FxRate], ',', ''))) AS numeric(18,2)), 0.0) AS [Amend FxRate],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [Amount],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([amount Without VAT], ',', ''))) AS numeric(18,2)), 0.0) AS [amount Without VAT],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Amount in Billing Currency], ',', ''))) AS numeric(18,2)), 0.0) AS [Amount in Billing Currency],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Approval Limit], ',', ''))) AS numeric(18,2)), 0.0) AS [Approval Limit],
			[Approver Name],
			[Attendee Job Title],
			[Attendee Name],
			[Attendee Notes],
			[Bank Account Number],
			[Bank Country],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Base Amount Without VAT], ',', ''))) AS numeric(18,2)), 0.0) AS [Base Amount Without VAT],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Base Ccy Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [Base Ccy Amount],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Base Currency Id], ',', ''))) AS INT),0) AS [Base Currency Id],
			[Billing Currency],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Billing Currency ID], ',', ''))) AS INT),0) AS [Billing Currency ID],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([CC Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [CC Amount],
			[CC Dual Number Last 4 Digits],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([CC Fx Rate], ',', ''))) AS numeric(18,2)), 0.0) AS [CC Fx Rate],
			[CC Mileage Import],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([CC Number Last 4 Digits], ',', ''))) AS INT),0) AS [CC Number Last 4 Digits],
			[CC Per Diem Import],
			[CC Program Ccy],
			[Category GL Code],
			[Category Limit Exceeded],
			[Claim],
			[Claim Id],
			[Claim Notes],
			[Claim Status],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Claim Total Gross Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [Claim Total Gross Amount],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Claim Total Without VAT], ',', ''))) AS numeric(18,2)), 0.0) AS [Claim Total Without VAT],
			[Company],
			[Cost Centre Code],
			[Country Visited],
			[Credit Card Billing Date],
			CASE
				WHEN LTRIM(RTRIM([Date Approved])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Approved], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Approved], 1, 4), SUBSTRING([Date Approved], 6,2), SUBSTRING([Date Approved], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Approved], 7, 4), SUBSTRING([Date Approved], 4,2), SUBSTRING([Date Approved], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Approved],
			CASE
				WHEN LTRIM(RTRIM([Date Approved 1])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Approved 1], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Approved 1], 1, 4), SUBSTRING([Date Approved 1], 6,2), SUBSTRING([Date Approved 1], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Approved 1], 7, 4), SUBSTRING([Date Approved 1], 4,2), SUBSTRING([Date Approved 1], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Approved 1],
			[Approver 1],
			CASE
				WHEN LTRIM(RTRIM([Date Approved 2])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Approved 2], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Approved 2], 1, 4), SUBSTRING([Date Approved 2], 6,2), SUBSTRING([Date Approved 2], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Approved 2], 7, 4), SUBSTRING([Date Approved 2], 4,2), SUBSTRING([Date Approved 2], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Approved 2],
			[Approver 2],
			CASE
				WHEN LTRIM(RTRIM([Date Approved 3])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Approved 3], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Approved 3], 1, 4), SUBSTRING([Date Approved 3], 6,2), SUBSTRING([Date Approved 3], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Approved 3], 7, 4), SUBSTRING([Date Approved 3], 4,2), SUBSTRING([Date Approved 3], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Approved 3],
			[Approver 3],
			CASE
				WHEN LTRIM(RTRIM([Date Approved 4])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Approved 4], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Approved 4], 1, 4), SUBSTRING([Date Approved 4], 6,2), SUBSTRING([Date Approved 4], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Approved 4], 7, 4), SUBSTRING([Date Approved 4], 4,2), SUBSTRING([Date Approved 4], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Approved 4],
			[Approver 4],
			CASE
				WHEN LTRIM(RTRIM([Date Approved 5])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Approved 5], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Approved 5], 1, 4), SUBSTRING([Date Approved 5], 6,2), SUBSTRING([Date Approved 5], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Approved 5], 7, 4), SUBSTRING([Date Approved 5], 4,2), SUBSTRING([Date Approved 5], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Approved 5],
			[Approver 5],
			CASE
				WHEN LTRIM(RTRIM([Date Approved 6])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Approved 6], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Approved 6], 1, 4), SUBSTRING([Date Approved 6], 6,2), SUBSTRING([Date Approved 6], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Approved 6], 7, 4), SUBSTRING([Date Approved 6], 4,2), SUBSTRING([Date Approved 6], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Approved 6],
			[Approver 6],
			CASE
				WHEN LTRIM(RTRIM([Date Created])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Created], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Created], 1, 4), SUBSTRING([Date Created], 6,2), SUBSTRING([Date Created], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Created], 7, 4), SUBSTRING([Date Created], 4,2), SUBSTRING([Date Created], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Created],
			[Date Paid],
			CASE
				WHEN LTRIM(RTRIM([Date Pre-approved])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Pre-approved], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Pre-approved], 1, 4), SUBSTRING([Date Pre-approved], 6,2), SUBSTRING([Date Pre-approved], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Pre-approved], 7, 4), SUBSTRING([Date Pre-approved], 4,2), SUBSTRING([Date Pre-approved], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Pre-approved],
			CASE
				WHEN LTRIM(RTRIM([Date Submitted])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Date Submitted], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Date Submitted], 1, 4), SUBSTRING([Date Submitted], 6,2), SUBSTRING([Date Submitted], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Date Submitted], 7, 4), SUBSTRING([Date Submitted], 4,2), SUBSTRING([Date Submitted], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Date Submitted],
			[Destination],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Division Base Ccy Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [Division Base Ccy Amount],
			[Duty Of Care Statement],
			[E-mail Address],
			[end Mileage Units],
			[Entity ID],
			[Event],
			CASE
				WHEN LTRIM(RTRIM([Expense Date])) <> ''	THEN
						CASE
							WHEN TRY_CAST(SUBSTRING([Expense Date], 1, 4) AS int) IS NOT NULL 
							THEN 
								DATEFROMPARTS(SUBSTRING([Expense Date], 1, 4), SUBSTRING([Expense Date], 6,2), SUBSTRING([Expense Date], 9,2)) 
							ELSE	
								DATEFROMPARTS(SUBSTRING([Expense Date], 7, 4), SUBSTRING([Expense Date], 4,2), SUBSTRING([Expense Date], 1,2)) 
						END
					ELSE
						NULL
			END  AS [Expense Date],
			[Expense Date Exceeded],
			[Extra Detail],
			[First Name],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Fx Rate], ',', ''))) AS numeric(18,2)), 0.0) AS [Fx Rate],
			[FxRate Exchange],
			[Incurred Ccy],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Item Number], ',', ''))) AS INT),0) AS [Item Number],
			[Last Name],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Migrated Mileage], ',', ''))) AS numeric(18,2)), 0.0) AS [Migrated Mileage],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Migrated Mileage Added], ',', ''))) AS numeric(18,2)), 0.0) AS [Migrated Mileage Added],
			[Mileage],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Mileage Rate], ',', ''))) AS numeric(18,2)), 0.0) AS [Mileage Rate],
			[Mileage Rate Description],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Net Due], ',', ''))) AS numeric(18,2)), 0.0) AS [Net Due],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Offset Miles], ',', ''))) AS numeric(18,2)), 0.0) AS [Offset Miles],
			[Offset Type],
			[P11d Category],
			[Payment Currency],
			[Per Diem Code],
			[Per Diem Duration],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Per Diem Rate], ',', ''))) AS numeric(18,2)), 0.0) AS [Per Diem Rate],
			[Per Diem Rate Description],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Per Diem Units], ',', ''))) AS numeric(18,2)), 0.0) AS [Per Diem Units],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Pre-approved Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [Pre-approved Amount],
			[Rate Vatable],
			[Receipt Attached],
			[Receipt Given],
			[start Mileage Units],
			[Sub Vendor],
			[Sub Vendor Code],
			[Supplier],
			[Supplier Code],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Total Miles], ',', ''))) AS numeric(18,2)), 0.0) AS [Total Miles],
			[travel From],
			[Travel Return],
			[travel To],
			[URN],
			[Unrecovered VAT],
			[VAT Name],
			[VAT Processed],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([VAT Rate], ',', ''))) AS numeric(18,2)), 0.0) AS [VAT Rate],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([No of Spent Units], ',', ''))) AS numeric(18,2)), 0.0) AS [No of Spent Units],
			ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([No of units], ',', ''))) AS numeric(18,2)), 0.0) AS [No of units],
			[VUK Number]
		FROM [Work].[tblWebExpenses_Detailed]

END
