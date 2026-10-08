CREATE     PROCEDURE [synapse_fo].[usp_Update_WHSINVENTTABLE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:56
	Description: Update stored procedure for WHSINVENTTABLE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ALLOWMATERIALOVERPICK] = stg.[ALLOWMATERIALOVERPICK],
		tgt.[CATCHWEIGHTITEMHANDLINGPOLICYNAME] = stg.[CATCHWEIGHTITEMHANDLINGPOLICYNAME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[FileName] = stg.[FileName],
		tgt.[FILTERCHANGED] = stg.[FILTERCHANGED],
		tgt.[FILTERCODE] = stg.[FILTERCODE],
		tgt.[FILTERCODE10_] = stg.[FILTERCODE10_],
		tgt.[FILTERCODE2_] = stg.[FILTERCODE2_],
		tgt.[FILTERCODE3_] = stg.[FILTERCODE3_],
		tgt.[FILTERCODE4_] = stg.[FILTERCODE4_],
		tgt.[FILTERCODE5_] = stg.[FILTERCODE5_],
		tgt.[FILTERCODE6_] = stg.[FILTERCODE6_],
		tgt.[FILTERCODE7_] = stg.[FILTERCODE7_],
		tgt.[FILTERCODE8_] = stg.[FILTERCODE8_],
		tgt.[FILTERCODE9_] = stg.[FILTERCODE9_],
		tgt.[FILTERGROUP] = stg.[FILTERGROUP],
		tgt.[FILTERGROUP2_] = stg.[FILTERGROUP2_],
		tgt.[ITEMID] = stg.[ITEMID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LSN] = stg.[LSN],
		tgt.[MAXPICKQTY] = stg.[MAXPICKQTY],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[PACKAGECLASSID] = stg.[PACKAGECLASSID],
		tgt.[PACKSIZECATEOGRYID] = stg.[PACKSIZECATEOGRYID],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PHYSDIMID] = stg.[PHYSDIMID],
		tgt.[PICKWCNEG] = stg.[PICKWCNEG],
		tgt.[PRODQTY] = stg.[PRODQTY],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RFDESCRIPTION1] = stg.[RFDESCRIPTION1],
		tgt.[RFDESCRIPTION2] = stg.[RFDESCRIPTION2],
		tgt.[SALESUNITRESTRICTED] = stg.[SALESUNITRESTRICTED],
		tgt.[SysRowId] = stg.[SysRowId],
		tgt.[UOMSEQGROUPID] = stg.[UOMSEQGROUPID]
	 FROM [synapse_fo].[WHSINVENTTABLE] tgt
		INNER JOIN [staging_fo].[WHSINVENTTABLE] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END
