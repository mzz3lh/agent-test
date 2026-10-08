CREATE   PROCEDURE [EventBrite].[usp_Insert_Order]
AS
BEGIN

	INSERT INTO [EventBrite].[tblOrder]
	(
		[Order_Id],
		[Link_Id],
		[CreatedOn],
		[ModifiedOn],
		[FirstName],
		[LastName],
		[Email],
		[Status],
		[Event_Id],
		[Organization_Id]
	)
	SELECT
		src.[Order_Id],
		src.[Link_Id],
		src.[CreatedOn],
		src.[ModifiedOn],
		src.[FirstName],
		src.[LastName],
		src.[Email],
		src.[Status],
		src.[Event_Id],
		src.[Organization_Id]
	FROM [Work].[tblOrder_EventBrite] src
		LEFT JOIN [EventBrite].[tblOrder] tgt
			ON src.[Order_Id] = tgt.[Order_Id]
			AND src.[Event_Id] = tgt.[Event_Id]
			AND src.[Organization_Id] = tgt.[Organization_Id]
	WHERE tgt.[Order_Id] IS NULL

END
