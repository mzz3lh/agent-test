CREATE   PROCEDURE [synapse_fo].[usp_Populate_DIMENSIONSETENTITY_RICS]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-19 09:40
	Description: Stored procedure to populate DIMENSIONSETENTITY_RICS BI table
*/
BEGIN

	--BEGIN TRY

	--	BEGIN TRANSACTION

			--Truncate target table
			TRUNCATE TABLE [synapse_fo].[DIMENSIONSETENTITY_RICS]

			--Load target table
			INSERT INTO [synapse_fo].[DIMENSIONSETENTITY_RICS]
			(
				[RECORDID],
				[MAINACCOUNT],
				[MODIFIEDDATETIME],
				[MODIFIEDBY],
				[CREATEDDATETIME],
				[CREATEDBY],
				[RECVERSION],
				[PARTITION],
				[RECID],
				[DISPLAYVALUE],
				[CAMPAIGNYEAR],
				[CHANNEL],
				[COSTCENTER],
				[COUNTRY],
				[CUSTOMER],
				[ENTITY],
				[FIXEDASSETGROUP],
				[FUNCTION_],
				[INTERCOMPANY],
				[INTERIMREPORTINGENTITY],
				[LOCATION],
				[NEW_RENEWAL],
				[PRODUCTCODE],
				[PRODUCTGROUP],
				[PROJECT]
			)
			SELECT
				[RECORDID],
				[MAINACCOUNT],
				[MODIFIEDDATETIME],
				[MODIFIEDBY],
				[CREATEDDATETIME],
				[CREATEDBY],
				[RECVERSION],
				[PARTITION],
				[RECID],
				[DISPLAYVALUE],
				[CAMPAIGNYEAR],
				[CHANNEL],
				[COSTCENTER],
				[COUNTRY],
				[CUSTOMER],
				[ENTITY],
				[FIXEDASSETGROUP],
				[FUNCTION_],
				[INTERCOMPANY],
				[INTERIMREPORTINGENTITY],
				[LOCATION],
				[NEW_RENEWAL],
				[PRODUCTCODE],
				[PRODUCTGROUP],
				[PROJECT]
			FROM [synapse_fo].[vwDIMENSIONSETENTITY]
/*		
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		DECLARE @Error_Message NVARCHAR(4000)
		SET @Error_Message = 'synapse_fo.usp_Populate_DIMENSIONSETENTITY_RICS procedure failed: ' + ERROR_MESSAGE()
		

		-- Transaction uncommittable
		IF (XACT_STATE()) = -1
		  ROLLBACK TRANSACTION
 
		-- Transaction committable
		IF (XACT_STATE()) = 1
		  COMMIT TRANSACTION

		--Fail the procedure
		RAISERROR (15600, 20, -1, @Error_Message);

	END CATCH
*/
END
