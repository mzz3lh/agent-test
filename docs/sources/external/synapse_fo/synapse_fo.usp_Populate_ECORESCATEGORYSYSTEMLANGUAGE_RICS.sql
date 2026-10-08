CREATE   PROCEDURE [synapse_fo].[usp_Populate_ECORESCATEGORYSYSTEMLANGUAGE_RICS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-19 09:40
	Description: Stored procedure to populate ECORESCATEGORYSYSTEMLANGUAGE_RICS BI table
*/
BEGIN

	BEGIN TRY

		BEGIN TRANSACTION

			--Truncate target table
			DELETE FROM [synapse_fo].[ECORESCATEGORYSYSTEMLANGUAGE_RICS]

			--Load target table
			INSERT INTO [synapse_fo].[ECORESCATEGORYSYSTEMLANGUAGE_RICS]
			(
				[CATEGORY],
				[PARTITION],
				[RECID],
				[SYSTEMLANGUAGEID],
				[PARTITION#2]
			)
			SELECT
				[CATEGORY],
				[PARTITION],
				[RECID],
				[SYSTEMLANGUAGEID],
				[PARTITION#2]
			FROM [synapse_fo].[vwECORESCATEGORYSYSTEMLANGUAGE]
		
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		DECLARE @Error_Message NVARCHAR(4000)
		SET @Error_Message = 'synapse_fo.usp_Populate_ECORESCATEGORYSYSTEMLANGUAGE_RICS procedure failed: ' + ERROR_MESSAGE()
		

		-- Transaction uncommittable
		IF (XACT_STATE()) = -1
		  ROLLBACK TRANSACTION
 
		-- Transaction committable
		IF (XACT_STATE()) = 1
		  COMMIT TRANSACTION

		--Fail the procedure
		RAISERROR (15600, 20, -1, @Error_Message);

	END CATCH

END
