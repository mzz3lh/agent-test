CREATE   PROCEDURE [CCPro].[usp_Update_ContactDataPoints]
AS
BEGIN

	WITH cte AS
	(
		SELECT *, ROW_NUMBER() OVER(PARTITION BY [sessionid] ORDER BY [sysd] DESC) AS RowOrder
		FROM [Work].[tblContactDataPoints_CCPro] 
	)


	UPDATE tgt SET
		tgt.[masterid] = src.[masterid],
		tgt.[_RowIndex] = src.[_RowIndex],
		tgt.[_ParentKeyField] = src.[_ParentKeyField],
		tgt.[Abandon_Time] = src.[Abandon_Time],
		tgt.[Duration] = src.[Duration],
		tgt.[Handle_Time] = src.[Handle_Time],
		tgt.[Queue_Time] = src.[Queue_Time],
		tgt.[Denied] = src.[Denied],
		tgt.[Forwarded] = src.[Forwarded],
		tgt.[Hold_Time] = src.[Hold_Time],
		tgt.[Outbound_Dialing_Time] = src.[Outbound_Dialing_Time],
		tgt.[Destination] = src.[Destination],
		tgt.[Dispositions] = src.[Dispositions],
		tgt.[Answered_In_SLA] = src.[Answered_In_SLA],
		tgt.[Discarded_With_No_Response] = src.[Discarded_With_No_Response],
		tgt.[orig] = src.[orig],
		tgt.[sysd] = src.[sysd],
		tgt.[Team] = src.[Team],
		tgt.[Completion_Code] = src.[Completion_Code],
		tgt.[Recording_Opt_Out] = src.[Recording_Opt_Out],
		tgt.[Notes] = src.[Notes],
		tgt.[Originator_Name] = src.[Originator_Name],
		tgt.[PreQueue_Time] = src.[PreQueue_Time],
		tgt.[Queue] = src.[Queue],
		tgt.[Wrap_Time] = src.[Wrap_Time],
		tgt.[Callback_Time] = src.[Callback_Time],
		tgt.[Routing_Time] = src.[Routing_Time],
		tgt.[Talk_Time] = src.[Talk_Time],
		tgt.[Channel_Type] = src.[Channel_Type],
		tgt.[Callback_Requested] = src.[Callback_Requested],
		tgt.[Destination_Description] = src.[Destination_Description],
		tgt.[Completed_Date] = src.[Completed_Date],
		tgt.[Direction] = src.[Direction],
		tgt.[Start_Time] = src.[Start_Time],
		tgt.[Followup_Comments] = src.[Followup_Comments],
		tgt.[User_Name] = src.[User_Name],
		tgt.[Answered_Date] = IIF(TRIM(src.answered_date) <> '', SUBSTRING(src.answered_Date, 1, 4) + '-' + SUBSTRING(src.answered_Date, 6, 2) + '-' + SUBSTRING(src.answered_Date, 9, 2) + ' ' + SUBSTRING(src.answered_Date, 12, 2) + ':' + SUBSTRING(src.answered_Date, 15, 2) + ':' + SUBSTRING(src.answered_Date, 18, 2), NULL),
		tgt.[Recording_Expiration_Date] = IIF(TRIM(src.Recording_Expiration_Date) <> '', SUBSTRING(src.Recording_Expiration_Date, 1, 4) + '-' + SUBSTRING(src.Recording_Expiration_Date, 6, 2) + '-' + SUBSTRING(src.Recording_Expiration_Date, 9, 2) + ' ' + SUBSTRING(src.Recording_Expiration_Date, 12, 2) + ':' + SUBSTRING(src.Recording_Expiration_Date, 15, 2) + ':' + SUBSTRING(src.Recording_Expiration_Date, 18, 2), NULL)
	FROM [CCPro].[tblContactDataPoints] tgt
		INNER JOIN cte src--[Work].[tblContactDataPoints_CCPro] src
			ON src.[sessionid] = tgt.[sessionid]
			AND src.[ccpro_platform] = tgt.[ccpro_platform]
	WHERE src.[RowOrder] = 1

END
