CREATE      PROCEDURE [synapse_fo].[usp_Update_INVENTTABLEMODULE]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:44
	Description: Update stored procedure for INVENTTABLEMODULE from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[ALLOCATEMARKUP] = stg.[ALLOCATEMARKUP],
		tgt.[BASEPRICEPURCHASE] = stg.[BASEPRICEPURCHASE],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DATAAREAID] = stg.[DATAAREAID],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[ENDDISC] = stg.[ENDDISC],
		--tgt.[FileName] = stg.[FileName],
		tgt.[INTERCOMPANYBLOCKED] = stg.[INTERCOMPANYBLOCKED],
		tgt.[ITEMID] = stg.[ITEMID],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		tgt.[LINEDISC] = stg.[LINEDISC],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MARKUP] = stg.[MARKUP],
		tgt.[MARKUPGROUPID] = stg.[MARKUPGROUPID],
		tgt.[MARKUPSECCUR_RU] = stg.[MARKUPSECCUR_RU],
		tgt.[MAXIMUMRETAILPRICE_IN] = stg.[MAXIMUMRETAILPRICE_IN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[MODULETYPE] = stg.[MODULETYPE],
		tgt.[MULTILINEDISC] = stg.[MULTILINEDISC],
		tgt.[OVERDELIVERYPCT] = stg.[OVERDELIVERYPCT],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PDSPRICINGPRECISION] = stg.[PDSPRICINGPRECISION],
		tgt.[PRICE] = stg.[PRICE],
		tgt.[PRICEDATE] = stg.[PRICEDATE],
		tgt.[PRICEQTY] = stg.[PRICEQTY],
		tgt.[PRICESECCUR_RU] = stg.[PRICESECCUR_RU],
		tgt.[PRICEUNIT] = stg.[PRICEUNIT],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		tgt.[RETAILINVENTORYAVAILABILITYBUFFER] = stg.[RETAILINVENTORYAVAILABILITYBUFFER],
		tgt.[RETAILINVENTORYAVAILABILITYLEVELPROFILE] = stg.[RETAILINVENTORYAVAILABILITYLEVELPROFILE],
		tgt.[SUPPITEMGROUPID] = stg.[SUPPITEMGROUPID],
		--tgt.[SysRowId] = stg.[SysRowId],
		tgt.[TAXGSTRELIEFCATEGORY_MY] = stg.[TAXGSTRELIEFCATEGORY_MY],
		tgt.[TAXITEMGROUPID] = stg.[TAXITEMGROUPID],
		tgt.[TAXWITHHOLDCALCULATE_TH] = stg.[TAXWITHHOLDCALCULATE_TH],
		tgt.[TAXWITHHOLDITEMGROUPHEADING_TH] = stg.[TAXWITHHOLDITEMGROUPHEADING_TH],
		tgt.[UNDERDELIVERYPCT] = stg.[UNDERDELIVERYPCT],
		tgt.[UNITID] = stg.[UNITID]
	 FROM [synapse_fo].[INVENTTABLEMODULE] tgt
		INNER JOIN [staging_fo].[INVENTTABLEMODULE] stg
			ON  stg.[DataAreaId] = tgt.[DataAreaId] 
			AND stg.[ItemId] = tgt.[ItemId] 
			AND stg.[ModuleType] = tgt.[ModuleType] 
			AND stg.[PARTITION] = tgt.[PARTITION] 
		
END
