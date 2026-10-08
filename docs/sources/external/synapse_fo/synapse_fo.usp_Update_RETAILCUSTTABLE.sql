CREATE     PROCEDURE [synapse_fo].[usp_Update_RETAILCUSTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:50
	Description: Update stored procedure for RETAILCUSTTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ACCOUNTNUM] = stg.[ACCOUNTNUM],
		tgt.[B2BCUSTOMERHIERARCHYNODE] = stg.[B2BCUSTOMERHIERARCHYNODE],
		tgt.[B2BUSERID] = stg.[B2BUSERID],
		tgt.[BLOCKCUSTOMERFORLOYALTYENROLLMENT] = stg.[BLOCKCUSTOMERFORLOYALTYENROLLMENT],
		tgt.[CUSTACCOUNTASYNC] = stg.[CUSTACCOUNTASYNC],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		--tgt.[FileName] = stg.[FileName],
		--tgt.[IMAGE] = stg.[IMAGE],
		tgt.[ISB2BADMIN] = stg.[ISB2BADMIN],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NONCHARGABLEACCOUNT] = stg.[NONCHARGABLEACCOUNT],
		tgt.[OPTOUTPERSONALIZATION] = stg.[OPTOUTPERSONALIZATION],
		tgt.[OPTOUTWEBACTIVITYTRACKING] = stg.[OPTOUTWEBACTIVITYTRACKING],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[POSTASSHIPMENT] = stg.[POSTASSHIPMENT],
		tgt.[RECEIPTEMAIL] = stg.[RECEIPTEMAIL],
		tgt.[RECEIPTOPTION] = stg.[RECEIPTOPTION],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[REQUIRESAPPROVAL] = stg.[REQUIRESAPPROVAL],
		tgt.[RETURNTAXGROUP_W] = stg.[RETURNTAXGROUP_W],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[USEORDERNUMBERREFERENCE] = stg.[USEORDERNUMBERREFERENCE]
	 FROM [synapse_fo].[RETAILCUSTTABLE] tgt
		INNER JOIN [staging_fo].[RETAILCUSTTABLE] stg
			ON  stg.[accountNum] = tgt.[accountNum] 
			AND stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END
