CREATE   PROCEDURE [synapse_ce].[usp_Generate_Insert_Procedure]
	@schemaname NVARCHAR(25) = 'synapse_ce',
	@entity_name nvarchar(100)
AS
/*
	Raj Maddala, 2022-10-06, Generic stored procedure to generate INSERT stored procedure for synapse_ce entities
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @errmsg NVARCHAR(200)
	DECLARE @entity_exists NVARCHAR(150) = ''

	SELECT	@entity_exists =  TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'synapse_ce'
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
			DECLARE @targetcolsql NVARCHAR(MAX) = ''
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
			WHERE TABLE_SCHEMA = 'staging_ce'
				AND TABLE_NAME = @entity_name
			)


			INSERT INTO @tempColumns(ColName, DataType, CharMaxLength, NumericPosition, NumericScale)

			SELECT 
				c1.COLUMN_NAME, c1.DATA_TYPE, c1.CHARACTER_MAXIMUM_LENGTH, c1.NUMERIC_PRECISION, c1.NUMERIC_SCALE
			FROM cteTgt c1
				INNER JOIN cteSrc c2
					ON c1.TABLE_NAME = c2.TABLE_NAME
						AND c1.COLUMN_NAME = c2.COLUMN_NAME
	

			SELECT	@maxcounter = MAX(ColId) 
			FROM		@tempColumns


			--Initiate SQL statement
			SET @sql = N'CREATE OR ALTER PROCEDURE [synapse_ce].[usp_Insert_' + @entity_name + ']' + CHAR(13) + 'AS' + CHAR(13) + 'BEGIN' + CHAR(13) + CHAR(9) 
			SET @sql = @sql + 'INSERT INTO [synapse_ce].[' + @entity_name + ']' + CHAR(13) + CHAR(9) + '(' + CHAR(13) + CHAR(9) + CHAR(9) 

			WHILE	@counter <= @maxcounter
			BEGIN
				SELECT @CurrentColName = ColName FROM @tempColumns WHERE ColId = @counter	

				SET @targetcolsql = @targetcolsql + '[' + @CurrentColName + '],' + CHAR(13) + CHAR(9) + CHAR(9)
				SET @sourcecolsql = @sourcecolsql + 'stg.[' + @CurrentColName + '],' + CHAR(13) + CHAR(9) + CHAR(9)

				SET @counter = @counter + 1
			END

			SET @targetcolsql = LEFT(@targetcolsql, LEN(@targetcolsql)-4) + CHAR(13) + CHAR(9) + ')'
			SET @sourcecolsql = LEFT(@sourcecolsql, LEN(@sourcecolsql)-4)  + CHAR(9)

			SET @sql = @sql + @targetcolsql + CHAR(13) + CHAR(9) + 'SELECT ' + CHAR(13) + CHAR(9) + CHAR(9) + @sourcecolsql + CHAR(13) + CHAR(9)
			SET @sql = @sql + 'FROM [staging_ce].[' + @entity_name + '] stg' + CHAR(13) + CHAR(9) + CHAR(9) + 'LEFT JOIN [synapse_ce].[' + @entity_name + '] tgt'
			SET @sql = @sql + CHAR(13) + CHAR(9) + CHAR(9) + CHAR(9) + 'ON tgt.[id] = stg.[id]' + CHAR(13) + CHAR(9) 
			SET @sql = @sql + 'WHERE tgt.[id] IS NULL' + CHAR(13) + 'END' + CHAR(13)


			EXEC sp_executesql @stmt = @sql

			--PRINT @sql
			PRINT 'Stored Procedure [synapse_ce].[usp_Insert_' + @entity_name + '] created/updated successfully'
	
		END


END
