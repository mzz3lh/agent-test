CREATE   PROCEDURE [EventBrite].[usp_Upsert_Venue]
AS

BEGIN

;WITH cte AS
(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY [Organization_Id], [Venue_Id] ORDER BY [Organization_Id], [Venue_Id]) RowNo
	FROM [Work].[tblVenue_EventBrite]
)
,cte1 AS
(
	SELECT *
	FROM cte 
	WHERE RowNo = 1
)

	MERGE [EventBrite].[tblVenue] AS tgt
		USING cte1 src--[Work].[tblVenue_EventBrite] AS src
			ON tgt.[Organization_Id] = src.[Organization_Id]
			AND tgt.[Venue_Id] = src.[Venue_Id]
			AND src.[RowNo] = 1
	WHEN MATCHED THEN UPDATE SET
		tgt.[Name] = src.[Name],
		tgt.[Address1] = src.[Address1],
		tgt.[Address2] = src.[Address2],
		tgt.[City] = src.[City],
		tgt.[Country] = src.[Country],
		tgt.[PostCode] = src.[PostCode],
		tgt.[Region] = src.[Region],
		tgt.[AgeRestriction] = src.[AgeRestriction],
		tgt.[Capacity] = src.[Capacity]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[Venue_Id],
		[Name],
		[Address1],
		[Address2],
		[City],
		[Country],
		[PostCode],
		[Region],
		[AgeRestriction],
		[Capacity],
		[Organization_Id]
	)
	VALUES
	(
		src.[Venue_Id],
		src.[Name],
		src.[Address1],
		src.[Address2],
		src.[City],
		src.[Country],
		src.[PostCode],
		src.[Region],
		src.[AgeRestriction],
		src.[Capacity],
		src.[Organization_Id]
	);
END
