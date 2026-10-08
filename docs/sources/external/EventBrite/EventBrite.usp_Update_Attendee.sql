CREATE   PROCEDURE [EventBrite].[usp_Update_Attendee]
AS
BEGIN
	
	UPDATE tgt SET
		tgt.[Link_Id] = src.[Link_Id],
		tgt.[CreatedOn] = src.[CreatedOn],
		tgt.[ModifiedOn] = src.[ModifiedOn],
		tgt.[Status] = src.[Status],
		tgt.[IsCanceleld] = src.[IsCanceleld],
		tgt.[IsCheckedIn] = src.[IsCheckedIn],
		tgt.[Delivery_Method] = src.[Delivery_Method],
		tgt.[Order_Id] = src.[Order_Id],
		tgt.[Profile_Company] = src.[Profile_Company],
		tgt.[Profile_Email] = src.[Profile_Email],
		tgt.[Profile_FirstName] = src.[Profile_FirstName],
		tgt.[Profile_LastName] = src.[Profile_LastName],
		tgt.[Profile_Gender] = src.[Profile_Gender],
		tgt.[Profile_Age] = src.[Profile_Age],
		tgt.[Profile_Cellphone] = src.[Profile_Cellphone],
		tgt.[Profile_JobTitle] = src.[Profile_JobTitle],
		tgt.[Profile_Name] = src.[Profile_Name],
		tgt.[Profile_Prefix] = src.[Profile_Prefix],
		tgt.[Profile_Suffix] = src.[Profile_Suffix],
		tgt.[IsRefunded] = src.[IsRefunded],
		tgt.[Team_EventId] = src.[Team_EventId],
		tgt.[Team_Id] = src.[Team_Id],
		tgt.[Team_Name] = src.[Team_Name],
		tgt.[TicketClass_Id] = src.[TicketClass_Id],
		tgt.[TicketClass_Name] = src.[TicketClass_Name],
		tgt.[Cost_Base_CurrencyCode] = src.[Cost_Base_CurrencyCode],
		tgt.[Cost_Base_Fee] = src.[Cost_Base_Fee],
		tgt.[Cost_EventBrite_CurrencyCode] = src.[Cost_EventBrite_CurrencyCode],
		tgt.[Cost_EventBrite_Fee] = src.[Cost_EventBrite_Fee],
		tgt.[Cost_Gross_CurrencyCode] = src.[Cost_Gross_CurrencyCode],
		tgt.[Cost_Gross_Fee] = src.[Cost_Gross_Fee],
		tgt.[Cost_Payment_CurrencyCode] = src.[Cost_Payment_CurrencyCode],
		tgt.[Cost_Payment_Fee] = src.[Cost_Payment_Fee],
		tgt.[Cost_Tax_CurrencyCode] = src.[Cost_Tax_CurrencyCode],
		tgt.[Cost_Tax_Fee] = src.[Cost_Tax_Fee]
	FROM [EventBrite].[tblAttendee] tgt
	INNER JOIN [Work].[tblAttendee_EventBrite] src
			ON src.[Event_Id] = tgt.[Event_Id]
			AND src.[Attendee_Id] = tgt.[Attendee_Id]
			AND src.[Organization_Id] = tgt.[Organization_Id]
END
