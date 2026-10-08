CREATE     PROCEDURE [synapse_fo].[usp_Update_ECORESCATEGORY]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-05-15 10:30:38
	Description: Update stored procedure for ECORESCATEGORY from synapse finops datalake to BI
*/
BEGIN
	UPDATE tgt SET 
		tgt.[CATEGORYHIERARCHY] = stg.[CATEGORYHIERARCHY],
		tgt.[CHANGESTATUS] = stg.[CHANGESTATUS],
		tgt.[CODE] = stg.[CODE],
		tgt.[CREATEDBY] = stg.[CREATEDBY],
		tgt.[CREATEDDATETIME] = stg.[CREATEDDATETIME],
		tgt.[DataLakeModified_DateTime] = stg.[DataLakeModified_DateTime],
		tgt.[DEFAULTPROJECTGLOBALCATEGORY] = stg.[DEFAULTPROJECTGLOBALCATEGORY],
		tgt.[DEFAULTTHRESHOLD_PSN] = stg.[DEFAULTTHRESHOLD_PSN],
		tgt.[DISPLAYORDER] = stg.[DISPLAYORDER],
		tgt.[EXEMPT_IN] = stg.[EXEMPT_IN],
		tgt.[EXTERNALID] = stg.[EXTERNALID],
		--tgt.[FileName] = stg.[FileName],
		tgt.[HSNCODETABLE_IN] = stg.[HSNCODETABLE_IN],
		tgt.[INSTANCERELATIONTYPE] = stg.[INSTANCERELATIONTYPE],
		tgt.[ISACTIVE] = stg.[ISACTIVE],
		tgt.[ISCATEGORYATTRIBUTESINHERITED] = stg.[ISCATEGORYATTRIBUTESINHERITED],
		tgt.[ISTANGIBLE] = stg.[ISTANGIBLE],
		tgt.[LastProcessedChange_DateTime] = stg.[LastProcessedChange_DateTime],
		--tgt.[LEVEL_] = stg.[LEVEL_],
		--tgt.[LSN] = stg.[LSN],
		tgt.[MODIFIEDBY] = stg.[MODIFIEDBY],
		tgt.[MODIFIEDDATETIME] = stg.[MODIFIEDDATETIME],
		tgt.[NAME] = stg.[NAME],
		tgt.[NESTEDSETLEFT] = stg.[NESTEDSETLEFT],
		tgt.[NESTEDSETRIGHT] = stg.[NESTEDSETRIGHT],
		tgt.[NONGST_IN] = stg.[NONGST_IN],
		tgt.[PARENTCATEGORY] = stg.[PARENTCATEGORY],
		tgt.[PARTITION] = stg.[PARTITION],
		tgt.[PKWIUCODE] = stg.[PKWIUCODE],
		tgt.[RECID] = stg.[RECID],
		tgt.[RECVERSION] = stg.[RECVERSION],
		--tgt.[RELATIONTYPE] = stg.[RELATIONTYPE],
		--tgt.[REUSEENABLED] = stg.[REUSEENABLED],
		tgt.[SERVICEACCOUNTINGCODETABLE_IN] = stg.[SERVICEACCOUNTINGCODETABLE_IN]
		--tgt.[SysRowId] = stg.[SysRowId]
	 FROM [synapse_fo].[ECORESCATEGORY] tgt
		INNER JOIN [staging_fo].[ECORESCATEGORY] stg
			ON  stg.[RECID] = tgt.[RECID] 
		
END
