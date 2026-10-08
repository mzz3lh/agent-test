CREATE   PROCEDURE [Adobe].[usp_Insert_Operatingsystem_mobileapp]	
AS
BEGIN

	--Insert to the target
	INSERT INTO [Adobe].[operatingsystem_mobileapp]
	(
		[osid],
		[os_name]
	)
	SELECT 
		src.[osid],
		src.[os_name]
	FROM [Staging_Adobe].[operatingsystem_mobileapp] src
		LEFT JOIN [Adobe].[operatingsystem_mobileapp] tgt
			ON src.[osid] = tgt.[osid]
	WHERE tgt.[osid] IS NULL

END
