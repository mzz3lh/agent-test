CREATE   PROCEDURE [EventBrite].[usp_Upsert_TicketGroup]
AS

BEGIN

	MERGE [EventBrite].[tblTicketGroup] AS tgt
		USING [Work].[tblTicketGroup_EventBrite] AS src
			ON tgt.[Organization_Id] = src.[Organization_Id]
			AND tgt.[TicketGroup_Id] = src.[TicketGroup_Id]
	WHEN MATCHED THEN UPDATE SET
		tgt.[TicketGroup_Name] = src.[TicketGroup_Name],
		tgt.[Link_Id] = src.[Link_Id],
		tgt.[Status] = src.[Status]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[TicketGroup_Id],
		[TicketGroup_Name],
		[Link_Id],
		[Status],
		[Organization_Id]
	)
	VALUES
	(
		src.[TicketGroup_Id],
		src.[TicketGroup_Name],
		src.[Link_Id],
		src.[Status],
		src.[Organization_Id]
	);
END
