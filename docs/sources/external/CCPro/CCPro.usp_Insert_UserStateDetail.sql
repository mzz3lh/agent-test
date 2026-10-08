CREATE   PROCEDURE [CCPro].[usp_Insert_UserStateDetail]
AS
BEGIN

	INSERT INTO [CCPro].[tblUserStateDetail]
	(
		[_RowIndex],
		[_ParentKeyField],
		[User_Name],
		[sessionid],
		[Timeline_Type],
		[State_Name],
		[Profile],
		[State_Attributes],
		[Start_Time],
		[End_Time],
		[State_Duration],
		[Starttime_Ticks],
		[Queue_Name],
		[Team],
		[Channel],
		[Station_Type],
		[Station_Desc],
		[Destination],
		[userid],
		[Duration],
		[ccpro_platform]
	)
	SELECT
		src.[_RowIndex],
		src.[_ParentKeyField],
		src.[User_Name],
		src.[sessionid],
		src.[Timeline_Type],
		src.[State_Name],
		src.[Profile],
		src.[State_Attributes],
		src.[Start_Time],
		src.[End_Time],
		src.[State_Duration],
		src.[Starttime_Ticks],
		src.[Queue_Name],
		src.[Team],
		src.[Channel],
		src.[Station_Type],
		src.[Station_Desc],
		src.[Destination],
		src.[userid],
		src.[Duration],
		src.[ccpro_platform]
	FROM [Work].[tblUserStateDetail_CCPro] src
		LEFT JOIN [CCPro].[tblUserStateDetail] tgt
			ON tgt.[sessionid] = src.[sessionid]
			AND tgt.[userid] = src.[userid]
			AND tgt.[Start_Time] = src.[Start_Time]
			AND tgt.[State_Name] = src.[State_Name]
			AND tgt.[ccpro_platform] = src.[ccpro_platform]
	WHERE tgt.[sessionid] IS NULL

END
