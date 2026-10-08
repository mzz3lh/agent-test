CREATE   PROCEDURE [EventBrite].[usp_Update_Order]
AS
BEGIN

	UPDATE tgt SET
		tgt.[Link_Id] = src.[Link_Id],
		tgt.[CreatedOn] = src.[CreatedOn],
		tgt.[ModifiedOn] = src.[ModifiedOn],
		tgt.[FirstName] = src.[FirstName],
		tgt.[LastName] = src.[LastName],
		tgt.[Email] = src.[Email],
		tgt.[Status] = src.[Status]
	FROM [EventBrite].[tblOrder] tgt
		INNER JOIN [Work].[tblOrder_EventBrite] src
			ON src.[Order_Id] = tgt.[Order_Id]
			AND src.[Event_Id] = tgt.[Event_Id]
			AND src.[Organization_Id] = tgt.[Organization_Id]

END
