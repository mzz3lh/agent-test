CREATE   PROCEDURE [Expenses].[usp_Load_WebExpenses]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-07-13
	Description: Stored procedure to load web expenses
*/
BEGIN

	DELETE FROM [Expenses].[tblWebExpenses]
	WHERE [Date]  
		IN 
		(
			SELECT 
				DISTINCT 		
				CASE
					WHEN LTRIM(RTRIM([Date])) <> ''	THEN
							CASE
								WHEN TRY_CAST(SUBSTRING([Date], 1, 4) AS int) IS NOT NULL 
								THEN 
									DATEFROMPARTS(SUBSTRING([Date], 1, 4), SUBSTRING([Date], 6,2), SUBSTRING([Date], 9,2)) 
								ELSE	
									DATEFROMPARTS(SUBSTRING([Date], 7, 4), SUBSTRING([Date], 4,2), SUBSTRING([Date], 1,2)) 
							END
						ELSE
							NULL
				END 
			FROM [Work].[tblWebExpenses]
		)

		--Insert into target table
		INSERT INTO [Expenses].[tblWebExpenses]
		(
			[file_name]
			,[Company Name]
			,[Date]
			,[Claimant Name]
			,[Employee ID]
			,[Claim ID]
			,[Claim Header]
			,[Item title]
			,[Category]
			,[GL Code]
			,[Cost Centre]
			,[Client Code]
			,[Event Code]
			,[Country]
			,[FX Currency]
			,[Amount Without VAT]
			,[VAT Amount]
			,[VAT Percentage]
			,[FX Currency Amount]
			,[Base Currency]
			,[Base Currency Amount]
			,[Source]
			,[Status]
			,[Claim Item Receipts]
			,[Sub Code]
		)
		SELECT
			[file_name]
			,[Company Name]
			,CASE
					WHEN LTRIM(RTRIM([Date])) <> ''	THEN
							CASE
								WHEN TRY_CAST(SUBSTRING([Date], 1, 4) AS int) IS NOT NULL 
								THEN 
									DATEFROMPARTS(SUBSTRING([Date], 1, 4), SUBSTRING([Date], 6,2), SUBSTRING([Date], 9,2)) 
								ELSE	
									DATEFROMPARTS(SUBSTRING([Date], 7, 4), SUBSTRING([Date], 4,2), SUBSTRING([Date], 1,2)) 
							END
						ELSE
							NULL
				END AS [Date]
			,[Claimant Name]
			,[Employee ID]
			,[Claim ID]
			,[Claim Header]
			,[Item title]
			,[Category]
			,[GL Code]
			,[Cost Centre]
			,[Client Code]
			,[Event Code]
			,[Country]
			,[FX Currency]
			,ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Amount Without VAT], ',', ''))) AS numeric(18,2)), 0.0) AS [Amount Without VAT]
			,ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([VAT Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [VAT Amount]
			,ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([VAT Percentage], ',', ''))) AS numeric(18,2)), 0.0) AS [VAT Percentage]
			,ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([FX Currency Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [FX Currency Amount]
			,[Base Currency]
			,ISNULL(TRY_CAST(LTRIM(RTRIM(REPLACE([Base Currency Amount], ',', ''))) AS numeric(18,2)), 0.0) AS [Base Currency Amount]
			,[Source]
			,[Status]
			,[Claim Item Receipts]
			,[Sub Code]
		FROM [Work].[tblWebExpenses]

END
