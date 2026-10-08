CREATE   PROCEDURE [EventBrite].[usp_Insert_Event]
AS
BEGIN

	INSERT INTO [EventBrite].[tblEvent]
	(
		[Event_Id],
		[Link_Id],
		[CreatedOn],
		[ModifiedOn],
		[Status],
		[Capacity],
		[Category_Id],
		[Currency_Code],
		[Description],
		[StartTime],
		[EndTime],
		[InviteOnly],
		[Is_Externally_Ticketed],
		[IsFree],
		[IsLocked],
		[Is_Reserved_Seating],
		[IsSeries],
		[Is_Series_Parent],
		[Listed],
		[Name],
		[Online_Event],
		[Organization_Id],
		[Organizer_Id],
		[Series_Id],
		[SubCategory_Id],
		[Total_Time_Limit],
		[Venue_Id],
		[ReadyToLoad_Orders]
	)
	SELECT
		src.[Event_Id],
		src.[Link_Id],
		src.[CreatedOn],
		src.[ModifiedOn],
		src.[Status],
		src.[Capacity],
		src.[Category_Id],
		src.[Currency_Code],
		src.[Description],
		src.[StartTime],
		src.[EndTime],
		src.[inviteonly],
		src.[Is_Externally_Ticketed],
		src.[isfree],
		src.[islocked],
		src.[Is_Reserved_Seating],
		src.[isseries],
		src.[Is_Series_Parent],
		src.[Listed],
		src.[Name],
		src.[Online_Event],
		src.[Organization_Id],
		src.[Organizer_Id],
		src.[Series_Id],
		src.[SubCategory_Id],
		src.[Total_Time_Limit],
		src.[Venue_Id],
		1
	FROM [Work].[tblEvent_EventBrite] src
		LEFT JOIN [EventBrite].[tblEvent] tgt
			ON src.[Event_Id] = tgt.[Event_Id]
			AND src.[organization_id] = tgt.[organization_id]
	WHERE tgt.[Event_Id] IS NULL
END
