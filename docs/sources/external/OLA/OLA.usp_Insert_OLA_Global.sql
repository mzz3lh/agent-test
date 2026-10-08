CREATE   PROCEDURE [OLA].[usp_Insert_OLA_Global]
AS
BEGIN

	-- Delete existing rows
	--This needs to be commented when the data range statement below is uncommented
	DELETE FROM [OLA].[tblOLA_Global]
	WHERE [Order_Id] IN (SELECT [Order_Id] FROM [Work].[tblOLA_Global])

	/****   Commented this on 2021-08-02 because the file has orders with OrderDate = 2020-08-01
		This needs to be enabled soon***/
	--DECLARE @StartingDate DATETIME
	--SELECT @StartingDate = MIN([Order_Date]) FROM [Work].[tblOLA_Global]
	--DELETE FROM [dbo].[tblOLA_Global] WHERE [Order_Date] >= @StartingDate
	
	-- Insert current load
	INSERT INTO [OLA].[tblOLA_Global]
	(
		[CRM_CM_Code],
		[Course_Title],
		[CPD_Hours],
		[Primary_Category],
		[Secondary_Category],
		[Course_Family],
		[Fee],
		[Currency],
		[Exchange_Rate],
		[Fee_GBP],
		[Full_Name],
		[E_Mail],
		[Contact_Name],
		[RICS_Qualification],
		[Member_Since],
		[Member_Pathway],
		[Company],
		[FirstName],
		[Surname],
		[Street],
		[City],
		[Post_Code],
		[CountryName],
		[Order_Id],
		[Order_Date],
		[Order_Number],
		[VAT],
		[Payment_Method],
		[Region],
		[Rics_ContactNo]
	)
	SELECT
		wrk.[CRM_CM_Code],
		wrk.[Course_Title],
		wrk.[CPD_Hours],
		wrk.[Primary_Category],
		wrk.[Secondary_Category],
		wrk.[Course_Family],
		CAST(wrk.[Fee] AS DECIMAL(18,4)) AS [Fee],
		wrk.[Currency],
		TRY_CAST(wrk.[Exchange_Rate] AS DECIMAL(18,6)) AS [Exchange_Rate],
		CAST(wrk.[Fee_GBP] AS DECIMAL(18,4)) AS [Fee_GBP],
		wrk.[Full_Name],
		wrk.[E_Mail],
		wrk.[Contact_Name],
		wrk.[RICS_Qualification],
		TRY_CAST(wrk.[Member_Since] AS DATETIME) AS [Member_Since],
		wrk.[Member_Pathway],
		wrk.[Company],
		wrk.[FirstName],
		wrk.[Surname],
		wrk.[Street],
		wrk.[City],
		wrk.[Post_Code],
		wrk.[CountryName],
		wrk.[Order_Id],
		TRY_CAST(wrk.[Order_Date] AS DATETIME) AS [Order_Date],
		--DATETIMEFROMPARTS(SUBSTRING(wrk.[Order_Date], 7,4), SUBSTRING(wrk.[Order_Date], 4,2), SUBSTRING(wrk.[Order_Date],1,2),0,0,0,0),
		wrk.[Order_Number],
		CAST(wrk.[VAT] AS DECIMAL(18,4)) AS [VAT],
		wrk.[Payment_Method],
		wrk.[Region],
		RIGHT('0000000'+ CAST(wrk.Contact_Name AS VARCHAR(7)),7)
	FROM [Work].[tblOLA_Global] wrk

END
