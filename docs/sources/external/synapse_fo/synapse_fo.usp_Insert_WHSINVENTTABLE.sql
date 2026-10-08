CREATE     PROCEDURE [synapse_fo].[usp_Insert_WHSINVENTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:04
	Description: Insert stored procedure for WHSINVENTTABLE from synapse finops datalake to BI
*/
BEGIN
	INSERT INTO [synapse_fo].[WHSINVENTTABLE]
	(
		[ALLOWMATERIALOVERPICK],
		[CATCHWEIGHTITEMHANDLINGPOLICYNAME],
		[DATAAREAID],
		[DataLakeModified_DateTime],
		[FileName],
		[FILTERCHANGED],
		[FILTERCODE],
		[FILTERCODE10_],
		[FILTERCODE2_],
		[FILTERCODE3_],
		[FILTERCODE4_],
		[FILTERCODE5_],
		[FILTERCODE6_],
		[FILTERCODE7_],
		[FILTERCODE8_],
		[FILTERCODE9_],
		[FILTERGROUP],
		[FILTERGROUP2_],
		[ITEMID],
		[LastProcessedChange_DateTime],
		[LSN],
		[MAXPICKQTY],
		[MODIFIEDBY],
		[MODIFIEDDATETIME],
		[PACKAGECLASSID],
		[PACKSIZECATEOGRYID],
		[PARTITION],
		[PHYSDIMID],
		[PICKWCNEG],
		[PRODQTY],
		[RECID],
		[RECVERSION],
		[RFDESCRIPTION1],
		[RFDESCRIPTION2],
		[SALESUNITRESTRICTED],
		[SysRowId],
		[UOMSEQGROUPID]
	)
	SELECT 
		stg.[ALLOWMATERIALOVERPICK],
		stg.[CATCHWEIGHTITEMHANDLINGPOLICYNAME],
		stg.[DATAAREAID],
		stg.[DataLakeModified_DateTime],
		stg.[FileName],
		stg.[FILTERCHANGED],
		stg.[FILTERCODE],
		stg.[FILTERCODE10_],
		stg.[FILTERCODE2_],
		stg.[FILTERCODE3_],
		stg.[FILTERCODE4_],
		stg.[FILTERCODE5_],
		stg.[FILTERCODE6_],
		stg.[FILTERCODE7_],
		stg.[FILTERCODE8_],
		stg.[FILTERCODE9_],
		stg.[FILTERGROUP],
		stg.[FILTERGROUP2_],
		stg.[ITEMID],
		stg.[LastProcessedChange_DateTime],
		stg.[LSN],
		stg.[MAXPICKQTY],
		stg.[MODIFIEDBY],
		stg.[MODIFIEDDATETIME],
		stg.[PACKAGECLASSID],
		stg.[PACKSIZECATEOGRYID],
		stg.[PARTITION],
		stg.[PHYSDIMID],
		stg.[PICKWCNEG],
		stg.[PRODQTY],
		stg.[RECID],
		stg.[RECVERSION],
		stg.[RFDESCRIPTION1],
		stg.[RFDESCRIPTION2],
		stg.[SALESUNITRESTRICTED],
		stg.[SysRowId],
		stg.[UOMSEQGROUPID]	
	FROM [staging_fo].[WHSINVENTTABLE] stg
		LEFT JOIN [synapse_fo].[WHSINVENTTABLE] tgt
			ON stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
	WHERE tgt.[RECID] IS NULL
END
