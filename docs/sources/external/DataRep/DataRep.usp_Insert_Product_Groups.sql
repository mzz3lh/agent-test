CREATE     PROCEDURE [DataRep].[usp_Insert_Product_Groups]
AS
BEGIN

	INSERT INTO [DataRep].[tblProductGroup]
	(
		[RICS_ProductGroupId],
		[ProductGroup],
		[TargetGroup],
		[State_Code],
		[Created_On],
		[Created_By],
		[Modified_On],
		[Modified_By],
		[Ricsv2_Type],
		[Ricsv2_Type_Description]
	)
	SELECT 
		wrk.[RICS_ProductGroupId],
		wrk.[ProductGroup],
		ISNULL(wrk.[ProductGroup], 'Unknown') AS [Target_Group],
		wrk.[StateCode_Description],
		TRY_CAST(wrk.[Created_On] AS DATETIME) AS [Created_On],
		wrk.[CreatedByName],
		TRY_CAST(wrk.[Modified_On] AS DATETIME) AS [Modified_On],
		wrk.[ModifiedByName],
		CAST(wrk.[Ricsv2_Type] AS INT) AS [Ricsv2_Type],
		wrk.[Ricsv2_Type_Description]
	FROM 
		(
			SELECT 
				pg.[apuk_productgroupid] AS [RICS_ProductGroupId],
				pg.[apuk_name] AS [ProductGroup],
				pg.[statecode] AS [State_Code],
				stStatecode.[LocalizedLabel] AS [StateCode_Description],
				pg.[createdon] AS [Created_On],
				pg.[createdby] AS [Created_By],
				usrcreatedby.[fullname] AS [CreatedByName],
				pg.[modifiedon] AS [Modified_On],
				pg.[modifiedby] AS [Modified_By],
				usrmodifiedby.[fullname] AS [ModifiedByName],
				pg.[apuk_type] AS [Ricsv2_Type],
				ricstype.[LocalizedLabel] AS [Ricsv2_Type_Description]
			FROM [synapse_ce].[apuk_productgroup] pg
				LEFT JOIN [synapse_ce].[systemuser] usrcreatedby
					ON pg.[createdby] = usrcreatedby.[systemuserid]
				LEFT JOIN [synapse_ce].[systemuser] usrmodifiedby
					ON pg.[modifiedby] = usrmodifiedby.[systemuserid]
				LEFT JOIN [synapse_ce].[OptionSetMetadata] ricstype
					ON pg.[apuk_type] = ricstype.[Option]
						AND ricstype.[EntityName] = 'apuk_productgroup'
						AND ricstype.[OptionSetName] = 'apuk_type'
				LEFT JOIN [synapse_ce].[StateMetadata] stStatecode
					ON pg.[statecode] = stStatecode.[State]
						AND stStatecode.[EntityName] = 'apuk_productgroup'
			) wrk
			LEFT JOIN [DataRep].[tblProductGroup] tgt
				ON wrk.[RICS_ProductGroupId] = tgt.[RICS_ProductGroupId]
	WHERE tgt.[RICS_ProductGroupId] IS NULL

END
