CREATE   PROCEDURE [CCPro].[usp_Update_UserStateDetail]
AS
BEGIN

	UPDATE tgt SET
		tgt.[_RowIndex] = src.[_RowIndex],
		tgt.[_ParentKeyField] = src.[_ParentKeyField],
		tgt.[User_Name] = src.[User_Name],
		tgt.[Timeline_Type] = src.[Timeline_Type],
		tgt.[Profile] = src.[Profile],
		tgt.[State_Attributes] = src.[State_Attributes],
		tgt.[End_Time] = src.[End_Time],
		tgt.[State_Duration] = src.[State_Duration],
		tgt.[Starttime_Ticks] = src.[Starttime_Ticks],
		tgt.[Queue_Name] = src.[Queue_Name],
		tgt.[Team] = src.[Team],
		tgt.[Channel] = src.[Channel],
		tgt.[Station_Type] = src.[Station_Type],
		tgt.[Station_Desc] = src.[Station_Desc],
		tgt.[Destination] = src.[Destination],
		tgt.[Duration] = src.[Duration]
	FROM [CCPro].[tblUserStateDetail] tgt
		INNER JOIN [Work].[tblUserStateDetail_CCPro] src
			ON tgt.[sessionid] = src.[sessionid]
			AND tgt.[userid] = src.[userid]
			AND tgt.[Start_Time] = src.[Start_Time]
			AND tgt.[State_Name] = src.[State_Name]
			AND tgt.[ccpro_platform] = src.[ccpro_platform]
END
