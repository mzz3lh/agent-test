CREATE     PROCEDURE [synapse_fo].[usp_Update_OMTeamMembershipCriterion]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:48
	Description: Update stored procedure for OMTeamMembershipCriterion from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ALLOWCONTACT] = stg.[ALLOWCONTACT],
		tgt.[ALLOWCONTRACTOR] = stg.[ALLOWCONTRACTOR],
		tgt.[ALLOWCUSTOMER] = stg.[ALLOWCUSTOMER],
		tgt.[ALLOWEMPLOYEE] = stg.[ALLOWEMPLOYEE],
		tgt.[ALLOWVENDOR] = stg.[ALLOWVENDOR],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		tgt.[ISSYSTEMCRITERION] = stg.[ISSYSTEMCRITERION],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NAME] = stg.[NAME],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[REQUIRESAXUSER] = stg.[REQUIRESAXUSER]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[OMTeamMembershipCriterion] tgt
		INNER JOIN [staging_fo].[OMTeamMembershipCriterion] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
