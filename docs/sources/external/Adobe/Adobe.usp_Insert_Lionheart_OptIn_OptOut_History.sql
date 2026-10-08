CREATE   PROCEDURE [Adobe].[usp_Insert_Lionheart_OptIn_OptOut_History]
	@source_file VARCHAR(50)
AS
BEGIN

	-- Delete existing data
	DELETE FROM [Adobe].[Lionheart_OptIn_OptOut_History] WHERE [Source_File_Name] = @source_file

	-- INsert new data
	INSERT INTO [Adobe].[Lionheart_OptIn_OptOut_History]
	(
		[Email]
		,[Member_Number]
		,[Action]
		,[External_Resource_Id]
		,[TransDate]
		,[Origin]
		,[Source_File_Name]
	)
	SELECT
		[Email]
		,[Member_Number]
		,[Action]
		,[External_Resource_Id]
		,CAST([TransDate] AS DATETIME) AS [TransDate]
		,[Origin]
		,[Source_File_Name]
	FROM [Work].[Lionheart_OptIn_OptOut_History_Adobe]


END
