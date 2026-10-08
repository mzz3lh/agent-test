CREATE   PROCEDURE [Chattermill].[usp_Insert_ImportFiles_Log]
	@SourceFileName NVARCHAR(150),
	@Bucket NVARCHAR(50),
	@NewFileId INT OUTPUT
AS
BEGIN
	
	INSERT INTO [Chattermill].[tblImportFiles_Log]
	(
		[Source_File_Name],
		[S3Bucket],
		[Import_StartDate],
		[Import_Finished]
	)
	VALUES
	(
		@SourceFileName,
		@Bucket,
		GETDATE(),
		0
	)

	SET @NewFileId = @@IDENTITY

END
