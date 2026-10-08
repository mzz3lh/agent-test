CREATE   PROCEDURE [EventBrite].[usp_Update_Event]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[Link_Id] = src.[Link_Id],
		tgt.[CreatedOn] = src.[CreatedOn],
		tgt.[ModifiedOn] = src.[ModifiedOn],
		tgt.[Status] = src.[Status],
		tgt.[Capacity] = src.[Capacity],
		tgt.[Category_Id] = src.[Category_Id],
		tgt.[Currency_Code] = src.[Currency_Code],
		tgt.[Description] = src.[Description],
		tgt.[StartTime] = src.[StartTime],
		tgt.[EndTime] = src.[EndTime],
		tgt.[InviteOnly] = src.[inviteonly],
		tgt.[Is_Externally_Ticketed] = src.[Is_Externally_Ticketed],
		tgt.[IsFree] = src.[isfree],
		tgt.[IsLocked] = src.[islocked],
		tgt.[Is_Reserved_Seating] = src.[Is_Reserved_Seating],
		tgt.[IsSeries] = src.[isseries],
		tgt.[Is_Series_Parent] = src.[Is_Series_Parent],
		tgt.[Listed] = src.[Listed],
		tgt.[Name] = src.[Name],
		tgt.[Online_Event] = src.[Online_Event],
		tgt.[Organizer_Id] = src.[Organizer_Id],
		tgt.[Series_Id] = src.[Series_Id],
		tgt.[SubCategory_Id] = src.[SubCategory_Id],
		tgt.[Total_Time_Limit] = src.[Total_Time_Limit],
		tgt.[Venue_Id] = src.[Venue_Id],
		tgt.[ReadyToLoad_Orders] = 1
	FROM [EventBrite].[tblEvent] tgt
		INNER JOIN [Work].[tblEvent_EventBrite] src
			ON src.[Event_Id] = tgt.[Event_Id]
			AND src.[organization_id] = tgt.[organization_id]
	
END
