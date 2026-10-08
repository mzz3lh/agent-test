CREATE     PROCEDURE [synapse_fo].[usp_Generate_Update_Procedure]
	@schemaname NVARCHAR(25) = 'synapse_fo',
	@entity_name nvarchar(100)
AS
/*
	Raj Maddala, 2022-10-06, Generic stored procedure to generate UPDATE stored procedure for synapse_fo entities
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @errmsg NVARCHAR(200)
	DECLARE @entity_exists NVARCHAR(150) = ''

	SELECT	@entity_exists =  TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'synapse_fo'
		AND TABLE_NAME = @entity_name


	IF @entity_name = 'GlobalOptionSetMetadata' OR @entity_name = 'OptionSetMetadata' OR @entity_name = 'StateMetadata' OR @entity_name = 'StatusMetadata' OR @entity_name = 'TargetMetadata'
		BEGIN
			 SET @errmsg = 'Warning: This entity ' + '[' + @entity_name + '] doesn''t need INSERT procedure. It requires MERGE procedure'
			RAISERROR (@errmsg, 16, 1, 1)
		END
	ELSE IF ISNULL(@entity_exists, '') = ''
		BEGIN
			SET @errmsg = 'Error: This entity ' + '[' + @entity_name + '] doesn''t exist in the schema'
			RAISERROR (@errmsg, 16, 1, 1)
		END
	ELSE
		BEGIN

			DECLARE @sql NVARCHAR(MAX) = ''
			DECLARE @targetcolsql NVARCHAR(MAX) = '' + CHAR(9)
			DECLARE @sourcecolsql NVARCHAR(MAX)  = ''
			DECLARE @maxcounter INT
			DECLARE @counter INT = 1
			DECLARE @CurrentColName NVARCHAR(150) = ''

			DECLARE @tempColumns TABLE(ColId INT IDENTITY(1,1), ColName NVARCHAR(150), DataType NVARCHAR(25), CharMaxLength INT, NumericPosition INT, NumericScale INT)

			;WITH cteTgt AS
			(
			SELECT 
				TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_SCHEMA = @schemaname
				AND TABLE_NAME = @entity_name
			),
			cteSrc AS
			(
			SELECT 
				TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_SCHEMA = 'staging_fo'
				AND TABLE_NAME = @entity_name
			)


			INSERT INTO @tempColumns(ColName, DataType, CharMaxLength, NumericPosition, NumericScale)

			SELECT 
				c1.COLUMN_NAME, c1.DATA_TYPE, c1.CHARACTER_MAXIMUM_LENGTH, c1.NUMERIC_PRECISION, c1.NUMERIC_SCALE
			FROM cteTgt c1
				INNER JOIN cteSrc c2
					ON c1.TABLE_NAME = c2.TABLE_NAME
						AND c1.COLUMN_NAME = c2.COLUMN_NAME
			WHERE c1.COLUMN_NAME <> 'id'

/*
			INSERT INTO @tempColumns(ColName)
			SELECT		COLUMN_NAME
			FROM			INFORMATION_SCHEMA.COLUMNS
			WHERE		TABLE_SCHEMA = @schemaname
						AND	TABLE_NAME = @entity_name
						AND COLUMN_NAME <> 'id'
*/

			SELECT	@maxcounter = MAX(ColId) 
			FROM		@tempColumns


			--Initiate SQL statement
			SET @sql = N'CREATE OR ALTER PROCEDURE [synapse_fo].[usp_Update_' + @entity_name + ']' + CHAR(13) + 'AS' + CHAR(13) + 'BEGIN' + CHAR(13) + CHAR(9) 
			SET @sql = @sql + 'UPDATE tgt SET ' + CHAR(13) + CHAR(9) -- [synapse_fo].[' + @entity_name + ']' + CHAR(13) + CHAR(9) + '(' + CHAR(13) + CHAR(9) + CHAR(9) 

			WHILE	@counter <= @maxcounter
			BEGIN
				SELECT @CurrentColName = ColName FROM @tempColumns WHERE ColId = @counter	

				SET @targetcolsql = @targetcolsql + 'tgt.[' + @CurrentColName + '] = stg.[' + @CurrentColName + '],' + CHAR(13) + CHAR(9) + CHAR(9)

				SET @counter = @counter + 1
			END

			SET @targetcolsql = LEFT(@targetcolsql, LEN(@targetcolsql)-4) + CHAR(13) + CHAR(9) + ' FROM [synapse_fo].[' + @entity_name + '] tgt' + CHAR(13) + CHAR(9) + CHAR(9)

			SET @sql = @sql + @targetcolsql + 'INNER JOIN [staging_fo].[' + @entity_name + '] stg' + CHAR(13) + CHAR(9) + CHAR(9) + CHAR(9)

			SET @sql = @sql + 'ON tgt.[id] = stg.[id]' + CHAR(13) + 'END'


			--EXEC sp_executesql @stmt = @sql
			print @sql
			
			PRINT 'Stored Procedure [synapse_fo].[usp_Update_' + @entity_name + '] created/updated successfully'
	
		END


END
