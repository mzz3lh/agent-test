CREATE PROCEDURE [DQ].[RunDQRules]
AS
BEGIN
	SET NOCOUNT ON
	/*
		Author:			Srini Akula
		Create date:	29/12/2021
		Description:	This procedure generates SQL statements from the DQ rules config table and 
						runs the script against source tables and then loads the results into a table. 
		Change history			
			11/02/2022	s.akula		Added condition to stop execution if any active rule has no script definied
									(just to avoid any mistakes)

			14/02/2022	s.akula		Made changes to validate the Rules execution and to do additional checks to check
									errors during execution. And to move previous data to summary tables.

			06/05/2022	s.akula		Replaced PriorityDataField with RuleId in the [DQ].[ValidationResultsSummary] INSERT
									to avoid issues with Priority Field name changes

		Info:			[DQ].[RuleValidationResults].ExtraFieldList is a comma separated field list required from the source table
						eg. CreatedBy, ModifiedBy, Rics_MemberGrade
	*/
	--Declare var
	DECLARE @EventId INT
	DECLARE @app AS VARCHAR (50) = 'DataQuality';
	DECLARE @spName AS VARCHAR (128) = 'Default';
	DECLARE @affRows INT

	--Add a log entry
	EXECUTE @EventId = DQ.AddEventLog 0, @app, 'Execution started', @spName, 'Info', 'Started', NULL   

	--Check if all Active Rules have Rule Script defined 
	IF 0 < (SELECT COUNT(*) FROM [DQ].[Rules] WHERE [RuleScript] IS NULL AND [Active] = 'Y')
		BEGIN
			EXECUTE DQ.AddEventLog @EventId, @app, 'Not all Active Rules have Rule Script defined, so the execution has been cancelled, please check.', @spName, 'Error', 'Failed', NULL   
			RETURN
		END

		--Declare var
		DECLARE @rulesID VARCHAR(10)
		DECLARE @rulesSQL VARCHAR(MAX)
		DECLARE @rulesCOUNT VARCHAR(MAX)
		DECLARE @n INT = 1
		DECLARE @ExecId INT
		DECLARE @Outcome VARCHAR(20) = 'Success' 


		/*************************************************************************/
		-- Add Execution Log entry and mark the new entry as latest snapshot(IsCurrent=1)
		INSERT INTO [DQ].[RulesExecLog]
				([StartDateTime])
		VALUES 
			(GETDATE())
		SET @ExecId = SCOPE_IDENTITY();

		/*************************************************************************/

print @ExecId
print @EventId
		--Declare Cursor
		DECLARE cRules CURSOR 
			FOR 
				SELECT
				 [Rule ID] AS ruleID
				,Exec_Script_Part_1 + ',' + CAST(@ExecId AS VARCHAR(10)) + Exec_Script_Part_2 AS 'ExecScript'
				,Count_Script_Part_1 + ',' + CAST(@ExecId AS VARCHAR(10)) +  Count_Script_Part_2 AS 'CountScript'
				FROM 
				[DQ].[vwDQ_Rules]
				WHERE [RuleScript] IS NOT NULL
				AND [Active] = 'Y'
				--AND [Rule ID] BETWEEN 220 AND 238

		--Add a log entry
		EXECUTE DQ.AddEventLog @EventId, @app, 'Before OPEN Cursor ', @spName, 'Info', 'Started', NULL

		--Open Cursor
		OPEN cRules

		--Fetch first row
		FETCH NEXT FROM cRules INTO @rulesID, @rulesSQL, @rulesCOUNT

		--Loop through each row
		WHILE @@FETCH_STATUS = 0  
		BEGIN 
					--Event Log add
					DECLARE @NewEvent INT
					EXECUTE @NewEvent = DQ.AddEventLog @EventId, @app, @rulesSQL, @spName, 'Info', 'Started', NULL

					-- Insert Execution results into Rules Validation Results table
					INSERT INTO [DQ].[RuleValidationResults] (
						 [RuleId]
						,[FieldValue]
						,[SourceRowId]
						,[CreatedBy]
						,[ModifiedBy]
						,[ExtraInfo1]
						,[ExtraInfo2]
						,[Region]							   
						,[JobExecId]
						)
					EXEC (@rulesSQL);

					INSERT INTO DQ.Results_Row_Counts (
						 [RuleID]
						,[RowCount]
						,[JobExecId]
						)
					EXEC (@rulesCOUNT);
						

					SET @affRows = @@ROWCOUNT
					EXECUTE DQ.AddEventLog @NewEvent, @app, 'Finished Rule execution', @spName, 'Info', 'Finished', @affRows
			--Keep on Looping
			FETCH NEXT FROM cRules INTO @rulesID, @rulesSQL, @rulesCOUNT
		END   
		--Close Cursor
		CLOSE cRules  
		--Deallocate Cursor
		DEALLOCATE cRules 

				--Event Log
				SET @affRows = @@ROWCOUNT
				EXECUTE DQ.AddEventLog @NewEvent, @app, 'Finished all Rules execution successfully.', @spName, 'Info', 'Finished', @affRows

					--Exec Log - Change IsCurrent status to 0 for previous records
					UPDATE [DQ].[RulesExecLog] SET [IsCurrent] = 0 WHERE ExecId <> @ExecId

					--Exec Log - Update with End Time and IsCurrent status to 1 for the latest records
					UPDATE  [DQ].[RulesExecLog]
						SET EndDateTime = SYSDATETIME(),
							Outcome = @Outcome,
							IsCurrent = 1 
					WHERE ExecId = @ExecId

					--Event Log
					EXECUTE DQ.AddEventLog @NewEvent, @app, 'Updated Execution Log Table', @spName, 'Info', 'Finished', NULL

					/**************************************************************************/
					--Delete previous data from Results table and keep only the latest results
					/**************************************************************************/
					DELETE res
					FROM 
						[DQ].[RuleValidationResults] res
					INNER JOIN DQ.RulesExecLog l ON res.JobExecId = l.ExecId
					WHERE l.IsCurrent = 0

					SET @affRows = @@ROWCOUNT
					EXECUTE DQ.AddEventLog @NewEvent, @app, 'Deleted previous results', @spName, 'Info', 'Finished', @affRows

					/**************************************************************************/
					--Move aggregated data into Summarised table from latest run 
					/**************************************************************************/
					INSERT INTO [DQ].[ValidationResultsSummary]
						([RunDate]
						,[Domain]
						,[DataOwner]
						,[DQDimension]
						,[RuleId]
						,[TotalRows]
						,[Pass]
						,[Fail])
					SELECT CAST(l.StartDateTime AS DATE) [RunDate]
						,dm.L1 [Domain]
						,dm.[DataOwner]
						,r.[DQDimension]
						,r.[RuleId]
						,rc.[RowCount]
						,rc.[RowCount] - COALESCE(COUNT(res.ResultID), 0) AS 'Pass'
						,COALESCE(COUNT(res.ResultID), 0) AS 'Fail'
					FROM DQ.Rules r
						LEFT JOIN [DQ].[RuleValidationResults] res ON res.RuleId = r.RuleId
						LEFT JOIN DQ.DataMap dm ON dm.DataMapId = r.DataMapId 
						LEFT JOIN DQ.Results_Row_Counts rc ON rc.RuleID = r.RuleId 
						INNER JOIN DQ.RulesExecLog l ON rc.JobExecId = l.ExecId
					WHERE 1=1 
					AND r.Active = 'Y'
					AND rc.[RowCount] <> 0 --Prevents transcribing of Rules that haven't run correctly
					AND l.IsCurrent = 1
					GROUP BY 
						l.StartDateTime
						,dm.L1
						,dm.[DataOwner]
						,r.[DQDimension]
						,r.[RuleId]
						,rc.[RowCount]
					ORDER BY l.StartDateTime, r.[RuleId]

					SET @affRows = @@ROWCOUNT
					EXECUTE DQ.AddEventLog @NewEvent, @app, 'Moved aggregates from latest results to Summary table', @spName, 'Info', 'Finished', @affRows


				/* --No reason for this to exist
					/**************************************************************************/
					--Move previous data into History table
					/**************************************************************************/
					
					--Clear History Table before moving previous results into History (History table always holds data from just the previous run NOT all history) 

					
					TRUNCATE TABLE [DQ].[RuleValidationResults_History]

					INSERT INTO [DQ].[RuleValidationResults_History]
							   ([ResultId]
							   ,[RuleId]
							   ,[FieldValue]
							   ,[SourceRowId]
							   ,[CreatedBy]
							   ,[ModifiedBy]
							   ,[ExtraInfo1]
							   ,[ExtraInfo2]
							   ,[JobExecId]
							   ,[Region])
					SELECT [ResultId]
						  ,[RuleId]
						  ,[FieldValue]
						  ,[SourceRowId]
						  ,[CreatedBy]
						  ,[ModifiedBy]
						  ,[ExtraInfo1]
						  ,[ExtraInfo2]
						  ,[JobExecId]
						  ,[Region]
					FROM [DQ].[RuleValidationResults] res
						INNER JOIN DQ.RulesExecLogl ON res.JobExecId = l.ExecId
					WHERE l.IsCurrent = 0

					SET @affRows = @@ROWCOUNT
					EXECUTE DQ.AddEventLog @NewEvent, @app, 'Moved previous results to History table', @spName, 'Info', 'Finished', @affRows
				*/

					/**************************************************************************/
					--Delete previous data from RowCounts table and keep only the latest results
					/**************************************************************************/

					DELETE rc
					FROM 
						[DQ].[Results_Row_Counts] rc
					INNER JOIN DQ.RulesExecLog l ON rc.JobExecId = l.ExecId
					WHERE l.IsCurrent = 0

					SET @affRows = @@ROWCOUNT
					EXECUTE DQ.AddEventLog @NewEvent, @app, 'Deleted previous RowCounts', @spName, 'Info', 'Finished', @affRows

		--Add a log entry
		EXECUTE DQ.AddEventLog @EventId, @app, 'END..Execution Completed', @spName, 'Info', 'Finished', NULL   

END

--EXEC [DQ].[RunDQRules]
