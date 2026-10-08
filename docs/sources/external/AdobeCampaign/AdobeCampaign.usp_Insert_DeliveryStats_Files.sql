CREATE PROCEDURE [AdobeCampaign].[usp_Insert_DeliveryStats_Files]
	@SourceFileName NVARCHAR(150),
	@NewFileId INT OUTPUT
AS
BEGIN
	
	INSERT INTO [AdobeCampaign].[tblDeliveryStats_Files]
	(
		[Source_File_Name],
		[Import_StartDate],
		[Import_Finished]
	)
	VALUES
	(
		@SourceFileName,
		GETDATE(),
		0
	)

	SET @NewFileId = @@IDENTITY

END
