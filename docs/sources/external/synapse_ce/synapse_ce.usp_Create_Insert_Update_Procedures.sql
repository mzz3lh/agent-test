CREATE   PROCEDURE [synapse_ce].[usp_Create_Insert_Update_Procedures]
	@ProcedureType NVARCHAR(6)
AS
/*
	Raj Maddala, 2022-10-06, Procedure to execute create INSERT procs for CE entities
*/
BEGIN

		DECLARE @tempColumns TABLE(TableId INT IDENTITY(1,1), TableName NVARCHAR(150))

		INSERT INTO @tempColumns(TableName)
		SELECT		TABLE_NAME
		FROM			INFORMATION_SCHEMA.TABLES
		WHERE		
			TABLE_SCHEMA = 'staging_ce'
			AND	TABLE_NAME NOT IN ('GlobalOptionSetMetadata', 'OptionSetMetadata', 'StateMetadata', 'StatusMetadata', 'TargetMetadata')
			AND TABLE_TYPE = 'BASE TABLE'

		DECLARE @maxcounter INT
		DECLARE @counter INT = 1
		DECLARE @CurrentTableName NVARCHAR(150) = ''
		DECLARE @sql NVARCHAR(MAX) = ''


		SELECT	@maxcounter = MAX(TableId) 
		FROM		@tempColumns

		WHILE	@counter <= @maxcounter
			BEGIN
				SELECT @CurrentTableName = TableName FROM @tempColumns WHERE TableId = @counter	

				IF UPPER(@ProcedureType) = 'INSERT'
					BEGIN
						SET @sql = N'EXEC [synapse_ce].[usp_Generate_Insert_Procedure] ''synapse_ce'', ''' + @CurrentTableName + ''''
					END
				ELSE IF UPPER(@ProcedureType) = 'UPDATE'
					BEGIN
						SET @sql = N'EXEC [synapse_ce].[usp_Generate_Update_Procedure] ''synapse_ce'', ''' + @CurrentTableName + ''''
					END

				EXEC sp_executesql @stmt = @sql
				
				SET @counter = @counter + 1
			END


END
