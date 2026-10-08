CREATE PROCEDURE [DQ].[LogDBErrors]
	@DBFunction VARCHAR(100),
	@DBProcName VARCHAR(128)
AS  

-- =============================================
-- Author:		srini.akula
-- Create date: 28.12.2021
-- Description:	Logs SQL errors into Error log table

-- Change History
/*	Date			Author			Comments
			

*/
-- ================================================================================================


	INSERT INTO [DQ].[DBErrors]
			   ([DBFunction]
			   ,[ErrorDateTime]
			   ,[SQLErrorNumber]
			   ,[SQLErrorSeverity]
			   ,[SQLErrorState]
			   ,[ProcName]
			   ,[ProcErrorLine]
			   ,[ErrorMessage])
		 VALUES
		 (
				@DBFunction
			   ,GETDATE()
			   ,ERROR_NUMBER()
			   ,ERROR_SEVERITY()
			   ,ERROR_STATE()
			   ,@DBProcName
			   ,ERROR_LINE()
			   ,ERROR_MESSAGE()
		 )
