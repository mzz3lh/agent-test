CREATE   PROCEDURE [Adobe].[usp_Insert_hit_data_mobileapp]
	@source_file_name NVARCHAR(150)
AS
BEGIN



	-- Delete if any exists for the current file
	DELETE FROM [Adobe].[hit_data_mobileapp] WHERE [source_file_name] = @source_file_name

	INSERT INTO [Adobe].[hit_data_mobileapp]
	(
		[App_Version],
		[Screen_Name],
		[MemberID],
		[App_Name],
		[Login_Status],
		[App_Launch_Timestamp],
		[Launch_Type],
		[date_time],
		[post_visid_high],
		[post_visid_low],
		[hit_time_gmt],
		[osid],
		[mobileosversion],
		[source_file_name]
	)
	SELECT
		src.[App_Version],
		src.[Screen_Name],
		src.[MemberID],
		src.[App_Name],
		src.[Login_Status],
		src.[App_Launch_Timestamp],
		src.[Launch_Type],
		src.[date_time],
		src.[post_visid_high],
		src.[post_visid_low],
		src.[hit_time_gmt],
		src.[osid],
		src.[mobileosversion],
		src.[source_file_name]
	FROM [Staging_Adobe].[hit_data_mobileapp] src
END
