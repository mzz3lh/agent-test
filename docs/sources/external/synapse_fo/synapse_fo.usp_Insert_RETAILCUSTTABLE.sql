CREATE     PROCEDURE [synapse_fo].[usp_Insert_RETAILCUSTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:29:58
	Description: Insert stored procedure for RETAILCUSTTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[RETAILCUSTTABLE]
	(
		[ACCOUNTNUM],
		[B2BCUSTOMERHIERARCHYNODE],
		[B2BUSERID],
		[BLOCKCUSTOMERFORLOYALTYENROLLMENT],
		[CUSTACCOUNTASYNC],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		--[FileName],
		--[IMAGE],
		[ISB2BADMIN],
		[LastProcessedChange_DateTime],
		--[LSN],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[NONCHARGABLEACCOUNT],
		[OPTOUTPERSONALIZATION],
		[OPTOUTWEBACTIVITYTRACKING],
		[PARTITION],
		[POSTASSHIPMENT],
		[RECEIPTEMAIL],
		[RECEIPTOPTION],
		[RECID],
		[RECVERSION],
		[REQUIRESAPPROVAL],
		[RETURNTAXGROUP_W],
		--[SysRowId],
		[USEORDERNUMBERREFERENCE]
	)
	SELECT 
		stg.[ACCOUNTNUM],
		stg.[B2BCUSTOMERHIERARCHYNODE],
		stg.[B2BUSERID],
		stg.[BLOCKCUSTOMERFORLOYALTYENROLLMENT],
		stg.[CUSTACCOUNTASYNC],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		--stg.--[FileName],
		--stg.[IMAGE],
		stg.[ISB2BADMIN],
		stg.[LastProcessedChange_DateTime],
		--stg.--[LSN],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[NONCHARGABLEACCOUNT],
		stg.[OPTOUTPERSONALIZATION],
		stg.[OPTOUTWEBACTIVITYTRACKING],
		stg.[PARTITION],
		stg.[POSTASSHIPMENT],
		stg.[RECEIPTEMAIL],
		stg.[RECEIPTOPTION],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[REQUIRESAPPROVAL],
		stg.[RETURNTAXGROUP_W],
		--stg.--[SysRowId],
		stg.[USEORDERNUMBERREFERENCE]	
	FROM [staging_fo].[RETAILCUSTTABLE] stg
		LEFT JOIN [synapse_fo].[RETAILCUSTTABLE] tgt
			ON stg.[accountNum] = tgt.[accountNum] 
			AND stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END
