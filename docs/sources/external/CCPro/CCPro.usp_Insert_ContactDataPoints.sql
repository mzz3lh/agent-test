CREATE   PROCEDURE [CCPro].[usp_Insert_ContactDataPoints]
AS
BEGIN

	--There might be duplicates in the resultset. Get only one if there are
	WITH cte AS
	(
		SELECT *, ROW_NUMBER() OVER(PARTITION BY [sessionid] ORDER BY [sysd] DESC) AS RowOrder
		FROM [Work].[tblContactDataPoints_CCPro] 
	)

	INSERT INTO [CCPro].[tblContactDataPoints]
	(
		[masterid],
		[sessionid],
		[_RowIndex],
		[_ParentKeyField],
		[Abandon_Time],
		[Duration],
		[Handle_Time],
		[Queue_Time],
		[Denied],
		[Forwarded],
		[Hold_Time],
		[Outbound_Dialing_Time],
		[Destination],
		[Dispositions],
		[Answered_In_SLA],
		[Discarded_With_No_Response],
		[orig],
		[sysd],
		[Team],
		[Completion_Code],
		[Recording_Opt_Out],
		[Notes],
		[Originator_Name],
		[PreQueue_Time],
		[Queue],
		[Wrap_Time],
		[Callback_Time],
		[Routing_Time],
		[Talk_Time],
		[Channel_Type],
		[Callback_Requested],
		[Destination_Description],
		[Completed_Date],
		[Direction],
		[Start_Time],
		[Followup_Comments],
		[User_Name],
		[Answered_Date],
		[Recording_Expiration_Date],
		[ccpro_platform]
	)
	SELECT
		src.[masterid],
		src.[sessionid],
		src.[_RowIndex],
		src.[_ParentKeyField],
		src.[Abandon_Time],
		src.[Duration],
		src.[Handle_Time],
		src.[Queue_Time],
		src.[Denied],
		src.[Forwarded],
		src.[Hold_Time],
		src.[Outbound_Dialing_Time],
		src.[Destination],
		src.[Dispositions],
		src.[Answered_In_SLA],
		src.[Discarded_With_No_Response],
		src.[orig],
		src.[sysd],
		src.[Team],
		src.[Completion_Code],
		src.[Recording_Opt_Out],
		src.[Notes],
		src.[Originator_Name],
		src.[PreQueue_Time],
		src.[Queue],
		src.[Wrap_Time],
		src.[Callback_Time],
		src.[Routing_Time],
		src.[Talk_Time],
		src.[Channel_Type],
		src.[Callback_Requested],
		src.[Destination_Description],
		src.[Completed_Date],
		src.[Direction],
		src.[Start_Time],
		src.[Followup_Comments],
		src.[User_Name],
		IIF(TRIM(src.answered_date) <> '', SUBSTRING(src.answered_Date, 1, 4) + '-' + SUBSTRING(src.answered_Date, 6, 2) + '-' + SUBSTRING(src.answered_Date, 9, 2) + ' ' + SUBSTRING(src.answered_Date, 12, 2) + ':' + SUBSTRING(src.answered_Date, 15, 2) + ':' + SUBSTRING(src.answered_Date, 18, 2), NULL) AS [Answered_Date],
		IIF(TRIM(src.Recording_Expiration_Date) <> '', SUBSTRING(src.Recording_Expiration_Date, 1, 4) + '-' + SUBSTRING(src.Recording_Expiration_Date, 6, 2) + '-' + SUBSTRING(src.Recording_Expiration_Date, 9, 2) + ' ' + SUBSTRING(src.Recording_Expiration_Date, 12, 2) + ':' + SUBSTRING(src.Recording_Expiration_Date, 15, 2) + ':' + SUBSTRING(src.Recording_Expiration_Date, 18, 2), NULL) AS [Recording_Expiration_Date],
		src.[ccpro_platform]
	FROM cte src--[Work].[tblContactDataPoints_CCPro] src
		LEFT JOIN [CCPro].[tblContactDataPoints] tgt
			ON src.[sessionid] = tgt.[sessionid]
			AND src.[ccpro_platform] = tgt.[ccpro_platform]
	WHERE src.[RowOrder] = 1
		AND tgt.[sessionid] IS NULL

END
