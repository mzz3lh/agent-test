CREATE     PROCEDURE [synapse_fo].[usp_Insert_OMTeamMembershipCriterion]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:55
	Description: Insert stored procedure for OMTeamMembershipCriterion from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[OMTeamMembershipCriterion]
	(
		[ALLOWCONTACT],
		[ALLOWCONTRACTOR],
		[ALLOWCUSTOMER],
		[ALLOWEMPLOYEE],
		[ALLOWVENDOR],
		[CREATEDBY],
		[CREATEDDATETIME],
		[DataLakeModified_DateTime],
		--[FileName],
		[ISSYSTEMCRITERION],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[NAME],
		[PARTITION],
		[RECID],
		[RECVERSION],
		[REQUIRESAXUSER]
		--[SysRowId]
	)
	SELECT 
		stg.[ALLOWCONTACT],
		stg.[ALLOWCONTRACTOR],
		stg.[ALLOWCUSTOMER],
		stg.[ALLOWEMPLOYEE],
		stg.[ALLOWVENDOR],
		stg.[CREATEDBY],
		stg.[CREATEDDATETIME],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		stg.[ISSYSTEMCRITERION],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[NAME],
		stg.[PARTITION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[REQUIRESAXUSER]
		--stg.--[SysRowId]	
	FROM [staging_fo].[OMTeamMembershipCriterion] stg
		LEFT JOIN [synapse_fo].[OMTeamMembershipCriterion] tgt
			ON stg.[RECID] = tgt.[RECID] 
		
	WHERE tgt.[RECID] IS NULL
END
