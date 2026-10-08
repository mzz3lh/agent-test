CREATE   PROCEDURE [synapse_ce].[usp_generate_droptable_script]
AS
/*
	Raj Maddala, 2022-10-06, Generate DROP TABLE script for staging 

*/
BEGIN

	;WITH cte1 AS
	(
		SELECT	[TABLE_SCHEMA], [TABLE_NAME]
		FROM		[INFORMATION_SCHEMA].[TABLES]
		WHERE	[TABLE_SCHEMA] IN ('synapse_ce')
			AND TABLE_TYPE = 'BASE TABLE'
	),
	cte2 AS
	(
		SELECT	[TABLE_SCHEMA], [TABLE_NAME]
		FROM		[INFORMATION_SCHEMA].[TABLES]
		WHERE	[TABLE_SCHEMA] IN ('staging')
			AND TABLE_TYPE = 'BASE TABLE'
	)

	SELECT	'DROP TABLE IF EXISTS [' + c1.[TABLE_SCHEMA] + '].[' + c1.TABLE_NAME + ']' AS Target_Table_Script,
					'DROP TABLE IF EXISTS [' + c2.[TABLE_SCHEMA] + '].[' + c2.TABLE_NAME + ']' AS Staging_Table_Script
	FROM		cte1 c1
		INNER JOIN cte2 c2
			ON c1.[TABLE_NAME] = c2.[TABLE_NAME]

END
