CREATE PROCEDURE [DQ].[AddEventLog]
	@pParentId INT NULL = NULL
	,@pApplication VARCHAR (128) NULL = 'Unknown'
	,@pComment VARCHAR (MAX) NULL
	,@pEventSource VARCHAR (128) NULL = 'Unknown'
	,@pEventType VARCHAR (128) NULL = 'Unknown'
	,@pOutcome VARCHAR (16) NULL = 'Started'
	,@pRecordsAffected INT NULL = NULL
AS  

-- =============================================
-- Author:		srini.akula
-- Create date: 28.12.2021
-- Description:	Add an entry into EventLog table

-- Change History
/*	Date			Author			Comments

	--Testing
	DECLARE @EventId INT
	EXECUTE @EventId = DQ.AddEventLog 0, 'DataQuality', 'Execution started', 'TEST', 'Info', 'Started', NULL   
	SELECT @EventId 
*/
-- ================================================================================================


		INSERT INTO [DQ].[EventLog]
			([ParentId]
			,[EventDate]
			,[Application]
			,[EventType]
			,[EventSource]
			,[EventMessage]
			,[EventOutcome]
			,[RecordsAffected]
			,[Username])
		VALUES
			(
				@pParentId
				,GETDATE()
				,@pApplication
				,@pEventType
				,@pEventSource
				,@pComment
				,@pOutcome
				,@pRecordsAffected
				,SUSER_NAME()
			)

		RETURN SCOPE_IDENTITY();
